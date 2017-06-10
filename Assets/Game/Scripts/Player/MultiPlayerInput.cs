using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MultiPlayerInput : PlayerInput {
    public PlayerInput Input1;
    public PlayerInput Input2;

    void Awake()
    {
        if (Input2 == null)
        {
            Input2 = Object.FindObjectOfType<JoystickPlayerInput>();
        }
    }

    public override Vector2 GetLookDirection()
    {
        var ld1 = Input1.GetLookDirection();
        if (Input2 == null) return ld1;
        var ld2 = Input2.GetLookDirection();
        if (Application.isMobilePlatform)
        {
            return ld2;
        }
        if (ld2.sqrMagnitude > 0)
        {
            return ld2;
        }
        else
        {
            return ld1;
        }
    }

    public override Vector2 GetMoveDirection()
    {
        var md1 = Input1.GetMoveDirection();
        if (Input2 == null) return md1;
        var md2 = Input2.GetMoveDirection();
        if (Application.isMobilePlatform)
        {
            return md2;
        }

        if (md1.sqrMagnitude > md2.sqrMagnitude)
        {
            return md1;
        }
        else
        {
            return md2;
        }
    }
}
