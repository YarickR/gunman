using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using System;
public class GameHUD : MonoBehaviour {
    public JoystickPlayerInput Joystick;
    public Slider HP;
    public GameObject Weap1, Cons1, Ammo1;
    public Text InfoPanel, LeftAlive;
    public GameObject DeathScreen;
    public PlayerController LocalPlayer;
    public void SwitchToDeath() {
        Joystick.gameObject.SetActive(false);
        DeathScreen.gameObject.SetActive(true);
    }
	public void Start() {
		LocalPlayer = null;
	}
    public void SwitchToLive() {
        Joystick.gameObject.SetActive(true);
        DeathScreen.gameObject.SetActive(false);
    }
    public void SetHP(float newHP, float maxHP) {
    	Debug.Log(String.Format("SetHP {0}/{1}", newHP, maxHP));
    	HP.value = (Mathf.Min(Mathf.Max((newHP * 100)/maxHP, 0), 100));
    }
    public void ClearText() { 
		InfoPanel.text = "";
    }
    public void AddInfoLine(string newLine) {
    	string[] parts = InfoPanel.text.Split('\n');
    	InfoPanel.text = parts[parts.Length - 1] + '\n' + newLine;
    }
    public void SetLeftAlive(int alive, int total) {
    	LeftAlive.text = alive + "/" + total;
    }
    public void UpdateHUD(PlayerController player = null) {
    	if (player == null ) {
    		player = LocalPlayer;
    	};
    	if (player) {
    		
    	}
    }
    public void UpdateInventory(PlayerController player = null) {
    	
    }
}
