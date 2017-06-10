using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Networking;

public class PlayerController : NetworkBehaviour
{
    private static float LOCATION_RANGE = 20.0f;
    private static float LOCATION_RANGE_SQR = LOCATION_RANGE * LOCATION_RANGE;

    private static PlayerController LocalClientController;

    private Dictionary<NetworkInstanceId, GameObject> _cachedControllers = new Dictionary<NetworkInstanceId, GameObject>();

    public Transform cameraPlaceHolder;

    public PlayerCamera cam;
    public PlayerInput input;
    public PlayerAnimator animator;
    public WeaponController weaponController;
    public MuzzleFlash muzzleFlash;
    public ProcessLineOfSights LineOfSights;
    public List<Container> MapContainers;
    public bool IsMoving
    {
        get
        {
            return _isMoving;
        }
    }

    private CharacterController characterController;
    private Targetable selfTargetable;

    [Header("RPG parameters")]
    public PlayerParams rpgParams;

    [Header("Current weapon params")]
    public WeaponParams weaponParams;

    public InteractSystem InteractSystem;

    //+++++ net params
    [SyncVar(hook = "OnChangeHealth")]
    private float _currentHealth;
    //----- net params

    private bool _isDead = false;

    private bool _isMoving = false;

    private bool _isInteracting = false;
    private float _interactStartTime = -1;

    void Awake()
    {
        characterController = GetComponent<CharacterController>();
        selfTargetable = GetComponent<Targetable>();
    }

    public override void OnStartServer()
    {
        base.OnStartServer();

        notifyLogicAboutSpawn();
        InitRPGParams();
    }

    public override void OnStartLocalPlayer()
    {
        name = "Player_" + playerControllerId.ToString();

        if (isLocalPlayer)
        {
            LocalClientController = this;

            cam = PlayerCamera.instance;
            cam.SetFollowTransform(cameraPlaceHolder);
            LineOfSights.gameObject.SetActive(true);
            LineOfSights.IgnoreTarget = selfTargetable;
            LineOfSights.VisibilityLineOfSight.MaxAngle = rpgParams.RangeOfView;
            LineOfSights.VisibilityLineOfSight.MaxDistance = rpgParams.ViewDistance;

            //--- remove after net init
            weaponController.InitWithParams(rpgParams.StartWeapon, rpgParams.StartWeapon.ClipSize, rpgParams.StartWeapon.MaxAmmo);
            LineOfSights.TargetingLineOfSight.MaxAngle = rpgParams.StartWeapon.RangeOfAiming;
            LineOfSights.TargetingLineOfSight.MaxDistance = rpgParams.StartWeapon.FireDistance;
            //---

            if (InteractSystem == null)
            {
                InteractSystem = gameObject.AddComponent<InteractSystem>();
            }
            InteractSystem.enabled = true;

            GameLogic.Instance.HUD.LocalPlayer = this;
            GameLogic.Instance.HUD.SwitchToLive();
            GameLogic.Instance.HUD.SetHP(_currentHealth, rpgParams.MaxHealth);
            Container[] __cnt = FindObjectsOfType(typeof(Container)) as Container[];
            for (int i = 0; i < __cnt.Length; i++) {
            	MapContainers.Add(__cnt[i]);
            };
        }
        else
        {
            LineOfSights.gameObject.SetActive(false);
            if (InteractSystem != null)
            {
                InteractSystem.enabled = false;
            }
        }
    }

    public void UpdateTimer(float currValue, float maxValue) {
    	GameLogic.Instance.HUD.SetTimer(currValue, maxValue);
    }
    private void Update()
    {
        if (IsInputAvalible())
        {
            ApplyMove();

#if UNITY_EDITOR || UNITY_STANDALONE
            if (Input.GetKeyDown(KeyCode.Y))
            {
                CmdSendDamageToServer(20.0f);
            }
#endif
        }

        if (isLocalPlayer)
        {
            SetUseButtonEnabled(!(_isMoving || weaponController.IsReloading));
            if (_isInteracting)
            {
                if (InteractSystem.CurrentInteractable == null)
                {
                    StopUse();
                }
                else
                {
                    float time = Time.time - _interactStartTime;
                    float maxTime = InteractSystem.CurrentInteractable.InteractionTime;
                    UpdateTimer(time, maxTime);
                    if (time > maxTime)
                    {
                        UseItem(InteractSystem.CurrentInteractable);
                    }
                }
            }
            else
            {
                UpdateTimer(weaponController.AimProgress, 1);
            }
        }
    }

    private void OnDestroy()
    {
        notifyLogicAboutDeath(true);
    }

    #region Movement
    private void ApplyMove()
    {
        var moveDirection = computeDirection(input.GetMoveDirection());
        Vector3 moveDelta = moveDirection * Time.deltaTime * CalcMoveSpeed();

        characterController.Move(moveDelta);

        var lookDirection = computeDirection(input.GetLookDirection());
        if (lookDirection.sqrMagnitude < 0.01f)
        {
            lookDirection = transform.forward;
        }

        transform.rotation = Quaternion.RotateTowards(transform.rotation, Quaternion.LookRotation(lookDirection, Vector3.up), CalcRotateSpeed() * Time.deltaTime);

        //applyToAnimation
        _isMoving = moveDelta.sqrMagnitude > Mathf.Epsilon;
        animator.SetMoveState(_isMoving);
        if (_isMoving)
        {
            var cosForward = Vector3.Dot(transform.forward, moveDelta.normalized);
            var cosRight = Vector3.Dot(transform.right, moveDelta.normalized);

            float angle = Mathf.Acos(cosForward) * Mathf.Rad2Deg;
            angle = cosRight > 0 ? angle : -angle;

            animator.SetMoveAngleFromView(angle);
        };
    }

    private float CalcMoveSpeed()
    {
        var percentMissingHealth = 1.0f - (_currentHealth / rpgParams.MaxHealth);
        var steps = Mathf.FloorToInt(percentMissingHealth / rpgParams.HealthStepDecreasePercent);
        var actualPercent = 1.0f - steps * rpgParams.HealthMoveSpeedDecreasePercentPerStep;

        return rpgParams.baseMoveSpeed * actualPercent;
    }

    private float CalcRotateSpeed()
    {
        var percentMissingHealth = 1.0f - (_currentHealth / rpgParams.MaxHealth);
        var steps = Mathf.FloorToInt(percentMissingHealth / rpgParams.HealthStepDecreasePercent);
        var actualPercent = 1.0f - steps * rpgParams.HealthRotateSpeedDecreasePercentPerStep;

        return rpgParams.baseRotateSpeed * actualPercent;
    }
    #endregion

    Vector3 computeDirection(Vector2 rawInput)
    {
        Vector3 upVector = Vector3.ProjectOnPlane(cam.transform.forward, Vector3.up).normalized;
        Vector3 rightVector = new Vector3(upVector.z, 0, -upVector.x).normalized;
        return rightVector * rawInput.x + upVector * rawInput.y;
    }

    #region RPG parameters methods
    private void InitRPGParams()
    {
        _currentHealth = rpgParams.MaxHealth;
    }

    private void ReceiveDamage(float damageValue)
    {
        _currentHealth -= damageValue;
        notifyLogicAboutDeath(_currentHealth <= 0);
        // notifyLogicAboutDeath();
    }

    private void notifyLogicAboutSpawn()
    {
        GameLogic.Instance.OnPlayerAlive(this, isLocalPlayer);
    }

    private void notifyLogicAboutDeath(bool isDead)
    {
        if (isDead)
        {
            GameLogic.Instance.OnPlayerDeath(this, isLocalPlayer);
        }
    }
    #endregion

    #region network hooks
    private void OnChangeHealth(float value)
    {
        Debug.LogFormat("ONCHANGE HEALTH:" + value);

        _currentHealth = value;
        bool isDead = value <= 0.0f;

        _isDead = isDead;
        animator.SetDeadState(isDead);
        selfTargetable.isVisibleOnly = isDead;

        if (isLocalPlayer)
        {
            Debug.LogFormat("ONCHANGE HEALTH(local):" + value);
            GameLogic.Instance.HUD.SetHP(value, rpgParams.MaxHealth);
        }
    }
    #endregion

    #region Server actions
    #endregion

    #region Client rpc
    [ClientRpc]
    public void RpcEnd(bool isVictory, int place, int maxPlayersCount)
    {
        if (isLocalPlayer)
        {
            Debug.LogFormat("RpcEnd {0}/{1}", isVictory, place, maxPlayersCount);
            GameLogic.Instance.HUD.SwitchToEnd(isVictory, place, maxPlayersCount);
        }
    }

    [ClientRpc]
    private void RpcShotAct(NetworkInstanceId DamagerNetId)
    {
        GameObject playerGO = null;
        if (_cachedControllers.ContainsKey(DamagerNetId))
        {
            playerGO = _cachedControllers[DamagerNetId];
        }
        else
        {
            NetworkIdentity[] identities = NetworkIdentity.FindObjectsOfType<NetworkIdentity>();
            for (int i = 0, l = identities.Length; i < l; ++i)
            {
                if (!_cachedControllers.ContainsKey(identities[i].netId))
                {
                    _cachedControllers[identities[i].netId] = identities[i].gameObject;
                }

                if (identities[i].netId == DamagerNetId)
                {
                    playerGO = identities[i].gameObject;
                }
            }
        }

        if (playerGO == null)
        {
            return;
        }

        if (isLocalPlayer)
        {
            //show hit on self
        }

        var targetController = playerGO.GetComponent<PlayerController>();
        var isVisible = targetController.selfTargetable.Visible;
        if (isVisible)
        {
            return;
        }

        if (LocalClientController == null)
        {
            return;
        }

        var localClientPosition = LocalClientController.transform.position;
        if ((localClientPosition - targetController.transform.position).sqrMagnitude < LOCATION_RANGE_SQR)
        {
            WorldFlashes.Instance.ShowFire(targetController.transform.position);
        }
    }

    [ClientRpc]
    private void RpcSetWeaponById(int weaponId, int clipAmmo, int backpackAmmo)
    {
        WeaponParams targetWeaponParams = WeaponsList.Instance.GetParamsByID(weaponId);
        if (targetWeaponParams == null)
        {
            return;
        }

        weaponController.InitWithParams(targetWeaponParams, clipAmmo, backpackAmmo);

        if (isLocalPlayer)
        {

            LineOfSights.TargetingLineOfSight.MaxAngle = targetWeaponParams.RangeOfAiming;
            LineOfSights.TargetingLineOfSight.MaxDistance = targetWeaponParams.FireDistance;
        }
    }
    #endregion

    #region Client commands
    [Command]
    public void CmdSendDamageToServer(float damageValue)
    {
        ReceiveDamage(damageValue);
    }

    [Command]
    public void CmdSendDamageToPlayer(float damageValue, NetworkInstanceId netId)
    {
        if (_currentHealth <= 0.0f)
        {
            return;
        }

        var playerGO = NetworkServer.FindLocalObject(netId);
        if (playerGO != null)
        {
            var targetController = playerGO.GetComponent<PlayerController>();
            targetController.ReceiveDamage(damageValue);
            targetController.RpcShotAct(this.netId);
        }
    }

    [Command]
    public void CmdActivateInteractable(NetworkInstanceId interactableID)
    {
        var interactableGO = NetworkServer.FindLocalObject(interactableID);
        if (interactableGO != null)
        {
            Debug.LogFormat("interactableGO {0}", interactableGO);
            
            interactableGO.GetComponent<Interactable>().Interact(this);
        }
    }
    #endregion

    #region Interact
    public void SetUseButtonEnabled(bool enabled)
    {
        GameLogic.Instance.HUD.SetUseButtonInteractable(enabled);
    }

    public void SetShowUseButtonState(bool visible)
    {
        GameLogic.Instance.HUD.SetShowUseButton(visible);
    }

    public void StartUse()
    {
        Debug.LogFormat("START USE");
        weaponController.IsCanFire = false;
        _isInteracting = true;
        _interactStartTime = Time.time;
    }

    public void StopUse()
    {
        _isInteracting = false;
        weaponController.IsCanFire = true;
    }

    public void UseItem(Interactable interactable)
    {
        CmdActivateInteractable(interactable.netId);
        InteractSystem.ClearInteractable();
        StopUse();
    }
    #endregion

    #region Client weapon

    #endregion

    private bool IsInputAvalible()
    {
        return isLocalPlayer && !_isDead;
    }
}
