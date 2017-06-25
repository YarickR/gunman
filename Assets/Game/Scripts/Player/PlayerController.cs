using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Networking;
using Prototype.NetworkLobby;
public class PlayerController : NetworkBehaviour
{
    private static float LOCATION_RANGE = 20.0f;
    private static float LOCATION_RANGE_SQR = LOCATION_RANGE * LOCATION_RANGE;

    private static PlayerController LocalClientController;

    public Transform cameraPlaceHolder;

    public PlayerCamera cam;
    public PlayerInput input;
    public PlayerAnimator animator;
    public WeaponController weaponController;
    public ProcessLineOfSights LineOfSights;
    public bool IsMoving
    {
        get
        {
            return _isMoving;
        }
    }

    private CharacterController characterController;
    private Targetable selfTargetable;

    private Collider[] colliders;

    [Header("RPG parameters")]
    public PlayerParams rpgParams;

    [Header("Current weapon params")]
    public WeaponParams weaponParams;

    public InteractSystem InteractSystem;

    //+++++ net params
    [SyncVar(hook = "OnChangeHealth")]
    private float _currentHealth;
    [SyncVar(hook = "OnChangeName")]
    private string _playerName;
    //----- net params

    private bool _isDead = false;
    private bool _isReloading = false;
    private bool _isMoving = false;

    private bool _isInteracting = false;
    private float _interactStartTime = -1;

    private bool _isDropedWeapon = false;

    void Awake()
    {
        characterController = GetComponent<CharacterController>();
        selfTargetable = GetComponent<Targetable>();

        colliders = GetComponents<Collider>();
    }

    public override void OnStartServer()
    {
        base.OnStartServer();
        notifyLogicAboutSpawn();
        InitRPGParams();
        _playerName = name;
    }

    public override void OnStartClient()
    {
        base.OnStartClient();

        if (!isLocalPlayer)
        {
            SetWeaponById(rpgParams.StartWeapon.WeaponId, rpgParams.StartWeapon.ClipSize, rpgParams.StartWeapon.MaxAmmo);
        }
    }

    public override void OnStartLocalPlayer()
    {
        base.OnStartLocalPlayer();
        if (isLocalPlayer) {
            LocalClientController = this;

            cam = PlayerCamera.instance;
            cam.SetFollowTransform(cameraPlaceHolder);
            LineOfSights.gameObject.SetActive(true);
            LineOfSights.IgnoreTarget = selfTargetable;
            LineOfSights.VisibilityLineOfSight.MaxAngle = rpgParams.RangeOfView;
            LineOfSights.VisibilityLineOfSight.MaxDistance = rpgParams.ViewDistance;

            //--- remove after net init (-:
            //weaponController.InitWithParams(rpgParams.StartWeapon, rpgParams.StartWeapon.ClipSize, rpgParams.StartWeapon.MaxAmmo);
            //LineOfSights.TargetingLineOfSight.MaxAngle = rpgParams.StartWeapon.RangeOfAiming;
            //LineOfSights.TargetingLineOfSight.MaxDistance = rpgParams.StartWeapon.FireDistance;
            SetWeaponById(rpgParams.StartWeapon.WeaponId, rpgParams.StartWeapon.ClipSize, rpgParams.StartWeapon.MaxAmmo);
            //---

            if (InteractSystem == null)
            {
                InteractSystem = GetComponent<InteractSystem>();
                if (InteractSystem == null)
                {
                    InteractSystem = gameObject.AddComponent<InteractSystem>();
                }
            }
            InteractSystem.enabled = true;

            GameLogic.Instance.HUD.LocalPlayer = this;
            GameLogic.Instance.HUD.SwitchToLive();
            GameLogic.Instance.HUD.SetHP(_currentHealth, rpgParams.MaxHealth);
        }
        else
        {
            LineOfSights.gameObject.SetActive(false);
            if (InteractSystem != null)
            {
                InteractSystem.enabled = false;
            }
        }
        CmdGetMyName();
        SetWeaponById(rpgParams.StartWeapon.WeaponId, rpgParams.StartWeapon.ClipSize, rpgParams.StartWeapon.MaxAmmo);
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
            bool currentReloadingState = weaponController.IsReloading;
            if (currentReloadingState != _isReloading)
            {
                CmdSetReloadingState(currentReloadingState);
                _isReloading = currentReloadingState;
            }

            SetUseButtonEnabled(!(_isMoving || currentReloadingState));
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

        if (transform.position.y > 0.01f)
        {
            moveDelta.y = -transform.position.y;
        }

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
    [Server]
    public void Heal(float healValue)
    {
        _currentHealth += healValue;

        _currentHealth = Mathf.Clamp(_currentHealth, 0.0f, rpgParams.MaxHealth);
    }

    private void InitRPGParams()
    {
        _currentHealth = rpgParams.MaxHealth;
    }

    void ReceiveDamage(float damageValue)
    {
        _currentHealth -= damageValue;

        _currentHealth = Mathf.Clamp(_currentHealth, 0.0f, rpgParams.MaxHealth);

        notifyLogicAboutDeath(_currentHealth <= 0);
        // notifyLogicAboutDeath();
    }

    public void FireDamage(float damageValue, NetworkInstanceId fireID)
    {
        ReceiveDamage(damageValue);
        RpcShotAct(fireID, damageValue);
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
    private void OnChangeName(string newName) {
    	GCTX.Log("OnChangeName: " + newName);
    	name = newName;
    }
    
    private IEnumerator DelayedHide()
    {
        yield return new WaitForSeconds(3.0f);

        this.gameObject.SetActive(false);
    }
    
    private void OnChangeHealth(float value)
    {
        Debug.LogFormat("ONCHANGE HEALTH:" + value);

        _currentHealth = value;
        bool isDead = value <= 0.0f;

        _isDead = isDead;
        animator.SetDeadState(isDead);
        if (isDead)
        {
            StartCoroutine(DelayedHide());
        }

        selfTargetable.isVisibleOnly = isDead;

        if (colliders != null)
        {
            foreach (var col in colliders)
            {
                col.enabled = !isDead;
            }
        }

        if (isLocalPlayer)
        {
            if (_isDead && !_isDropedWeapon)
            {
                _isDropedWeapon = true;
                TrySpawnMainWeapon();
            }

            Debug.LogFormat("ONCHANGE HEALTH(local):" + value);
            GameLogic.Instance.HUD.SetHP(value, rpgParams.MaxHealth);
        }
    }
    #endregion

    #region Client rpc
	[ClientRpc]
	public void RpcSetName(string newName)
    {
		GCTX.Log("RpcSetName");
		gameObject.name = newName;
		name = newName;
	}

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
    private void RpcShotAct(NetworkInstanceId DamagerNetId, float damage) {

    	Debug.LogFormat("RpcShotAct: target: {0}, shooter {1}", netId, DamagerNetId);
        GameObject attackerGO = ClientScene.FindLocalObject(DamagerNetId);
        if (attackerGO == null) {
        	Debug.LogFormat("Can't find attacker with id {0}", DamagerNetId);
            return;
        }
		
		GameLogic.Instance.HUD.AddInfoLine(attackerGO.name + " deals damage to " + name);
        if (_currentHealth <= 0f) {
			GameLogic.Instance.HUD.AddInfoLine(attackerGO.name + " killed " + name);
        }

        if (isLocalPlayer || (LocalClientController.netId == DamagerNetId)) {
            //show hit on self
            spawnHit();
        }

        var attackerController = attackerGO.GetComponent<PlayerController>();
        if (attackerController != null) {
            var isVisible = attackerController.selfTargetable.Visible;
            if (isVisible) {
                return;
            }

            if (LocalClientController == null) {
                return;
            }

            var localClientPosition = LocalClientController.transform.position;
            if ((localClientPosition - attackerController.transform.position).sqrMagnitude < LOCATION_RANGE_SQR)
            {
                WorldFlashes.Instance.ShowFire(attackerController.transform.position);
            }
        }
    }

    [ClientRpc]
    public void RpcSetWeaponById(int weaponId, int clipAmmo, int backpackAmmo, bool isSwitch)
    {
        SetWeaponById(weaponId, clipAmmo, backpackAmmo, isSwitch);
    }

    private void SetWeaponById(int weaponId, int clipAmmo, int backpackAmmo, bool isSwitch = false)
    {
        WeaponParams targetWeaponParams = WeaponsList.Instance.GetParamsByID(weaponId);
        if (targetWeaponParams == null)
        {
            return;
        }

        weaponController.InitWithParams(targetWeaponParams, clipAmmo, backpackAmmo, isSwitch);

        if (isLocalPlayer)
        {
            LineOfSights.TargetingLineOfSight.MaxAngle = targetWeaponParams.RangeOfAiming;
            LineOfSights.TargetingLineOfSight.MaxDistance = targetWeaponParams.FireDistance;
        }
    }

    [ClientRpc]
    public void RpcSetReloadingState(bool isActive)
    {
        animator.SetReloadingState(isActive);
    }

    [ClientRpc]
    public void RpcAddAmmoToMainWeapon(int count)
    {
        weaponController.AddMainWeaponAmmo(count);
    }

    [ClientRpc]
    public void RpcFireAnimationTrigger(int type)
    {
        weaponController.ShowFireMuzzle();
        animator.SetShootTrigger((ShotAnimationType)type);
    }

    [ClientRpc]
    public void RpcSetInteractingState(bool isActive)
    {
        animator.SetInteractingState(isActive);
    }

    [ClientRpc]
    public void RpcAnnounceFire(float announceInterval, int fireStep)
    {
		GameLogic.Instance.HUD.AddInfoLine(String.Format("Fire step {1} will be in {0} seconds", announceInterval, fireStep));
    }
    #endregion

    #region Client commands
    [Command]
    public void CmdGetMyName()
    {
    	RpcSetName(name);
    }

    [Command]
    public void CmdSendDamageToServer(float damageValue)
    {
        ReceiveDamage(damageValue);
    }

    [Command]
    public void CmdSendDamageToPlayer(float damageValue, NetworkInstanceId netId, int animationType)
    {
        if (_currentHealth <= 0.0f)
        {
            return;
        }

        RpcFireAnimationTrigger(animationType);

        var playerGO = NetworkServer.FindLocalObject(netId);
        if (playerGO != null)
        {
            var targetController = playerGO.GetComponent<PlayerController>();
            targetController.ReceiveDamage(damageValue);
			targetController.RpcShotAct(this.netId, damageValue);
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

    [Command]
    public void CmdSetWeapon(int weaponId, int clipAmmo, int backpackAmmo, bool isSwitch)
    {
        RpcSetWeaponById(weaponId, clipAmmo, backpackAmmo, isSwitch);
    }

    [Command]
    public void CmdSetReloadingState(bool isActive)
    {
        RpcSetReloadingState(isActive);
    }

    [Command]
    public void CmdSetInteractingState(bool isActive)
    {
        RpcSetInteractingState(isActive);
    }

    [Command]
    public void CmdSpawnSelfWeapon(int weaponId, int clipCount, int backpackCount)
    {
        var weaponParams = WeaponsList.Instance.GetParamsByID(weaponId);
        var targetObj = GameObject.Instantiate(weaponParams.PicablePrefab, transform.position, weaponParams.PicablePrefab.transform.rotation);
        Weapon targetWeapon = targetObj.GetComponent<Weapon>();
        targetWeapon.ClipAmmo = clipCount;
        targetWeapon.BackpackAmmo = backpackCount;
        NetworkServer.Spawn(targetObj);
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

        CmdSetInteractingState(true);
    }

    public void StopUse()
    {
        _isInteracting = false;
        weaponController.IsCanFire = true;

        CmdSetInteractingState(false);
    }

    public void UseItem(Interactable interactable)
    {
        CmdActivateInteractable(interactable.netId);
        InteractSystem.ClearInteractable();
        StopUse();
    }
    #endregion

    void spawnHit()
    {
        var prefab = Resources.Load<GameObject>("HitEffect");
        var go = Instantiate<GameObject>(prefab, transform.position, prefab.transform.rotation);
        go.transform.SetParent(transform, true);
    }

    private bool IsInputAvalible()
    {
        return isLocalPlayer && !_isDead;
    }

    public void RegisterAdditionalRenderPart(VisiblePart additionalPart)
    {
        if (additionalPart != null &&
            !selfTargetable.additionalParts.Contains(additionalPart))
        {
            selfTargetable.additionalParts.Add(additionalPart);
            additionalPart.SetVisible(selfTargetable.Visible);
        }
    }

    public void TrySpawnMainWeapon()
    {
        int weaponId = 0;
        int clipAmmo = 0;
        int backpackAmmo = 0;

        if (!weaponController.GetMainWeaponParams(ref weaponId, ref clipAmmo, ref backpackAmmo))
        {
            return;
        }

        CmdSpawnSelfWeapon(weaponId, clipAmmo, backpackAmmo);
    }
}
