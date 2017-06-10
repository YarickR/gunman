﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using System;
public class GameHUD : MonoBehaviour {
    public JoystickPlayerInput Joystick;
    public Slider HP, Timer;
    public GameObject Weap1, Cons1, Ammo1;
    public Text InfoPanel, LeftAlive;
    public EndScreen EndScreen;
    public PlayerController LocalPlayer;

    public void SwitchToEnd(bool isVictory, int playerPlace, int maxPlayers) {
        Joystick.gameObject.SetActive(false);
        EndScreen.SetEndStatus(isVictory, playerPlace, maxPlayers);
        EndScreen.gameObject.SetActive(true);
    }
	public void Start() {
		LocalPlayer = null;
	}
    public void SwitchToLive() {
        Joystick.gameObject.SetActive(true);
        EndScreen.gameObject.SetActive(false);
    }
    public void SetHP(float newHP, float maxHP) {
    	HP.value = (Mathf.Min(Mathf.Max((newHP * 100)/maxHP, 0), 100));
    }
    public void SetTimer(float currValue, float maxValue) {
		Timer.value = (Mathf.Min(Mathf.Max((currValue * 100)/maxValue, 0), 100));
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
