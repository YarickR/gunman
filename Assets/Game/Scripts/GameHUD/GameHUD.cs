using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameHUD : MonoBehaviour {
    public JoystickPlayerInput Joystick;
    public GameObject DeathScreen;

    public void SwitchToDeath()
    {
        Joystick.gameObject.SetActive(false);
        DeathScreen.gameObject.SetActive(true);
    }

    public void SwitchToLive()
    {
        Joystick.gameObject.SetActive(true);
        DeathScreen.gameObject.SetActive(false);
    }
}
