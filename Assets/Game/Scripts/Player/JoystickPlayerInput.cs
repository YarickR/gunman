using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class JoystickPlayerInput : PlayerInput {
    public Joystick Left, Right;
	
    public override Vector2 GetMoveDirection()
    {
        return new Vector2(Left.virtualAxes.x, Left.virtualAxes.y);
    }

    public override Vector2 GetLookDirection()
    {
        return new Vector2(Right.virtualAxes.x, Right.virtualAxes.y);
    }
}
