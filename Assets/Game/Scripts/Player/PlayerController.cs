using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Networking;

public class PlayerController : NetworkBehaviour
{
    public Transform cameraPlaceHolder;

    public PlayerCamera cam;
    public PlayerInput input;

    private CharacterController characterController;

    [Header("Move params")]
    public float targetMoveSpeed;
    public float targetRotateSpeed;

    void Awake()
    {
        characterController = GetComponent<CharacterController>();

    }

    public override void OnStartLocalPlayer()
    {
    	Debug.Log("OnStartLocalPlayer");
        if (isLocalPlayer)
        {
            cam = PlayerCamera.instance;
            cam.SetFollowTransform(cameraPlaceHolder);
            input = GetComponent<JoystickPlayerInput>();
        }
    }

    private void Update()
    {
        if (isLocalPlayer)
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
    }

    Vector3 computeDirection(Vector2 rawInput)
    {
        Vector3 upVector = Vector3.ProjectOnPlane(cam.transform.forward, Vector3.up).normalized;
        Vector3 rightVector = new Vector3(upVector.z, 0, -upVector.x).normalized;
        return rightVector * rawInput.x + upVector * rawInput.y;
    }
}
