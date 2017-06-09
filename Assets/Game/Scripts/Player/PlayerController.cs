using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Networking;

public class PlayerController : NetworkBehaviour
{
    public Transform cameraPlaceHolder;

    public PlayerCamera cam;
    public PlayerInput input;

    [Header("Move params")]
    public float targetMoveSpeed;
    public float targetRotateSpeed;

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
        var inputDirection = new Vector3(inputRaw.x, 0f, inputRaw.y).normalized;
        newPos += inputDirection * Time.deltaTime * targetMoveSpeed;

        transform.position = transform.position + newPos;
    }
}
