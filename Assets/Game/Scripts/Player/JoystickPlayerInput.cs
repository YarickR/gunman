using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class JoystickPlayerInput : PlayerInput {
	private Joystick __leftJ, __rightJ;
	public void Start() {
		if ((GameObject.Find("/HUD/Panel/leftJ") == null) || (GameObject.Find("/HUD/Panel/rightJ") == null)) {
			Debug.Log("Joystick not found");
		} else {
			__leftJ = GameObject.Find("/HUD/Panel/leftJ").GetComponent<Joystick>();
			__rightJ = GameObject.Find("/HUD/Panel/rightJ").GetComponent<Joystick>() as Joystick;
		}
	}
    public override Vector2 GetMoveDirection()
    {
		return new Vector2( __leftJ.virtualAxes.x,  __leftJ.virtualAxes.y );
    }

    public override Vector2 GetLookDirection()
    {
		return new Vector2(__rightJ.virtualAxes.x, __rightJ.virtualAxes.y);
    }
}
