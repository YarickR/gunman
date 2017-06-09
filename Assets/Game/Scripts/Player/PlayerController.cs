using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerController : MonoBehaviour
{
    public PlayerCamera cam;
    public PlayerInput input;

    [Header("Move params")]
    public float targetMoveSpeed;
    public float targetRotateSpeed;

    private void Update()
    {
        ApplyMove(); 
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
