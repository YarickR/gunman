using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerInput : MonoBehaviour
{
    public Vector2 GetMoveDirection()
    {
        return new Vector2(Input.GetAxisRaw("Horizontal"), Input.GetAxisRaw("Vertical"));
    }

    public Vector2 GetLookDirection()
    {
        return new Vector2(Input.mousePosition.x, Input.mousePosition.y) - new Vector2(Screen.width / 2, Screen.height / 2);
    }
}
