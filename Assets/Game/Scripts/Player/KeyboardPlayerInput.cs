using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class KeyboardPlayerInput : PlayerInput
{
    public override Vector2 GetMoveDirection()
    {
        return new Vector2(Input.GetAxisRaw("Horizontal"), Input.GetAxisRaw("Vertical"));
    }

    public override Vector2 GetLookDirection()
    {
        return Input.GetMouseButton(0) ? new Vector2(Input.mousePosition.x, Input.mousePosition.y) - new Vector2(Screen.width / 2, Screen.height / 2) : Vector2.zero;
    }
}
