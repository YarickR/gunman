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
    public float MaxHealth;

    [Range(0.0f, 1.0f)]
    public float HealthStepDecreasePercent;
    [Range(0.0f, 1.0f)]
    public float HealthMoveSpeedDecreasePercentPerStep;
    [Range(0.0f, 1.0f)]
    public float HealthRotateSpeedDecreasePercentPerStep;
    [Range(0.0f, 1.0f)]
    public float HealthLootDecreasePercentPerStep;

    [Header("RPG Move params")]
    public float baseMoveSpeed;
    public float baseRotateSpeed;

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
            name = "Player_" + playerControllerId.ToString();
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

            #if UNITY_EDITOR
            if (Input.GetKeyDown(KeyCode.Y))
            {
                CmdSendDamageToServer(20.0f);
            }
            #endif
        }
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
        var percentMissingHealth = 1.0f - (_currentHealth / MaxHealth);
        var steps = Mathf.FloorToInt(percentMissingHealth / HealthStepDecreasePercent);
        var actualPercent = 1.0f - steps * HealthMoveSpeedDecreasePercentPerStep;

        return baseMoveSpeed * actualPercent;
    }

    private float CalcRotateSpeed()
    {
        var percentMissingHealth = 1.0f - (_currentHealth / MaxHealth);
        var steps = Mathf.FloorToInt(percentMissingHealth / HealthStepDecreasePercent);
        var actualPercent = 1.0f - steps * HealthRotateSpeedDecreasePercentPerStep;

        return baseRotateSpeed * actualPercent;
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
        _currentHealth = MaxHealth;
    }

    private void ReceiveDamage(float damageValue)
    {
        _currentHealth -= damageValue;
    }
    #endregion

    #region network hooks
    private void OnChangeHealth(float value)
    {
        bool isDead = value <= 0.0f;

        _isDead = isDead;
        animator.SetDeadState(isDead);
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
