using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class GameHUD : MonoBehaviour {
    public JoystickPlayerInput Joystick;
    public Slider HP;
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
    public void SetHP(float newHP, float maxHP) {
    	HP.value = (Mathf.Max((newHP * 100)/maxHP, 100));
    }
}
