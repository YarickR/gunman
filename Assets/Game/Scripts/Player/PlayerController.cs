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

    private CharacterController characterController;

    [Header("Move params")]
    public float targetMoveSpeed;
    public float targetRotateSpeed;

    [Header("RPG parameters")]
    public float MaxHealth;

    //+++++ net params
    [SyncVar(hook = "OnChangeHealth")]
    private float _currentHealth;
    //----- net params

    private bool _isDead = false;

    void Awake()
    {
        characterController = GetComponent<CharacterController>();
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
        }
    }

    private void Update()
    {
        if (IsInputAvalible())
        {
            ApplyMove();
        }
    }

    private void ApplyMove()
    {
        var moveDirection = computeDirection(input.GetMoveDirection());
        Vector3 moveDelta = moveDirection * Time.deltaTime * targetMoveSpeed;

        characterController.Move(moveDelta);

        var lookDirection = computeDirection(input.GetLookDirection());
        if (lookDirection.sqrMagnitude < 0.01f)
        {
            lookDirection = transform.forward;
        }

        transform.rotation = Quaternion.RotateTowards(transform.rotation, Quaternion.LookRotation(lookDirection, Vector3.up), targetRotateSpeed * Time.deltaTime);

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


    #endregion

    #region network hooks
    private void OnChangeHealth(float value)
    {
        bool isDead = value <= 0.0f;

        _isDead = isDead;
        animator.SetDeadState(isDead);
    }
    #endregion

    private bool IsInputAvalible()
    {
        return isLocalPlayer && !_isDead;
    }
}
