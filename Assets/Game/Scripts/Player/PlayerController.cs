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
        if (isLocalPlayer)
        {
            cam = PlayerCamera.instance;
            cam.SetFollowTransform(cameraPlaceHolder);
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
        Vector3 newPos = Vector3.zero;

        var inputRaw = input.GetInput();
        var inputDirection = computeDirection(inputRaw);
        newPos += inputDirection * Time.deltaTime * targetMoveSpeed;

        characterController.Move(newPos);
    }

    Vector3 computeDirection(Vector2 rawInput)
    {
        Vector3 upVector = Vector3.ProjectOnPlane(cam.transform.forward, Vector3.up).normalized;
        Vector3 rightVector = new Vector3(upVector.z, 0, -upVector.x).normalized;
        return rightVector * rawInput.x + upVector * rawInput.y;
    }
}
