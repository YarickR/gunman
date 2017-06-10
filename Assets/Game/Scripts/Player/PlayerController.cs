using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Networking;

public class PlayerController : NetworkBehaviour
{
    public Transform cameraPlaceHolder;

    public PlayerCamera cam;
    public PlayerInput input;
    public PlayerAnimator animator;

    public ProcessLineOfSights LineOfSights;

    private CharacterController characterController;
    private Targetable selfTargetable;

    [Header("RPG parameters")]
    public PlayerParams rpgParams;

    [Header("Current weapon params")]
    public WeaponParams weaponParams;

    //+++++ net params
    [SyncVar(hook = "OnChangeHealth")]
    private float _currentHealth;
    //----- net params

    private bool _isDead = false;

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
        if (isLocalPlayer)
        {
            cam = PlayerCamera.instance;
            cam.SetFollowTransform(cameraPlaceHolder);
            LineOfSights.gameObject.SetActive(true);
            LineOfSights.IgnoreTarget = selfTargetable;
            LineOfSights.VisibilityLineOfSight.MaxAngle = rpgParams.RangeOfView;
            name = "Player_" + playerControllerId.ToString();

            //weapon tmp
            var weapon = this.gameObject.AddComponent<WeaponController>();
            weapon.weaponParams = weaponParams;
            weapon.playerController = this;
            weapon.Init(weaponParams.ClipSize, weaponParams.MaxAmmo);

            LineOfSights.TargetingLineOfSight.MaxAngle = weaponParams.RangeOfAiming;
            LineOfSights.TargetingLineOfSight.MaxDistance = weaponParams.FireDistance;

            GameLogic.Instance.HUD.SwitchToLive();
        }
        else
        {
            LineOfSights.gameObject.SetActive(false);
        }
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
    }

    private void OnDestroy()
    {
        notifyLogicAboutDeath(_isDead);
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
        bool isMoving = moveDelta.sqrMagnitude > Mathf.Epsilon;
        animator.SetMoveState(isMoving);
        if (isMoving)
        {
            var cosForward = Vector3.Dot(transform.forward, moveDelta.normalized);
            var cosRight = Vector3.Dot(transform.right, moveDelta.normalized);

            float angle = Mathf.Acos(cosForward) * Mathf.Rad2Deg;
            angle = cosRight > 0 ? angle : -angle;

            animator.SetMoveAngleFromView(angle);
        }
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
        Debug.LogFormat("ONCHANGE HEALTH");
        bool isDead = value <= 0.0f;

        _isDead = isDead;
        animator.SetDeadState(isDead);

        if (isLocalPlayer)
        {
            GameLogic.Instance.HUD.SetHP(value, rpgParams.MaxHealth);

            if (_isDead)
            {
                GameLogic.Instance.HUD.SwitchToDeath();
            }
        }

        notifyLogicAboutDeath(_isDead);
    }
    #endregion

    #region Server actions
    #endregion

    #region Client commands
    [Command]
    public void CmdSendDamageToServer(float damageValue)
    {
        ReceiveDamage(damageValue);
    }
    #endregion

    private bool IsInputAvalible()
    {
        return isLocalPlayer && !_isDead;
    }
}
