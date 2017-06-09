using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MultiPlayerInput : PlayerInput {
    public PlayerInput Input1;
    public PlayerInput Input2;

    public override Vector2 GetLookDirection()
    {
        var ld1 = Input1.GetLookDirection();
        var ld2 = Input2.GetLookDirection();

        if (ld1.sqrMagnitude > ld2.sqrMagnitude)
        {
            return ld1;
        }
        else
        {
            return ld2;
        }
    }

    public override Vector2 GetMoveDirection()
    {
        var md1 = Input1.GetMoveDirection();
        var md2 = Input2.GetMoveDirection();

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
