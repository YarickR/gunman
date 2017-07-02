using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using System;

public class GameHUD : MonoBehaviour
{
    private enum HUDState
    {
        Alive,
        Dead,
    }

    [Header("Base elements")]
    public GameObject BaseContainer;
    public Text InfoPanel;
    public Text LeftAlive;
    public ZoneWidget ZoneProgress;

    [Header("Alive elements")]
    public GameObject AliveContainer;
    public JoystickPlayerInput Joystick;
    public Slider HP;
    public Slider Timer;
    public Text AmmoValue;
    public Button UseButton;

    [Header("Death screen elements")]
    public GameObject DeathContainer;
    public EndScreen EndScreen;
    
    [Header("Runtime element")]
    public PlayerController LocalPlayer;
    
	private float _addLineTS;

    public void Start()
    {
        LocalPlayer = null;
        _addLineTS = 0;
        UseButton.onClick.AddListener(OnUseButtonClicked);
    }

    private void SwitchToState(HUDState newState)
    {
        switch (newState)
        {
            case HUDState.Alive:
                AliveContainer.SetActive(true);
                DeathContainer.SetActive(false);
                break;

            case HUDState.Dead:
            default:
                AliveContainer.SetActive(false);
                DeathContainer.SetActive(true);
                break;
        }
    }

    public void SwitchToEnd(bool isVictory, int playerPlace, int maxPlayers)
    {
        EndScreen.SetEndStatus(isVictory, playerPlace, maxPlayers);

        SwitchToState(HUDState.Dead);
    }

    public void SwitchToLive()
    {
        SwitchToState(HUDState.Alive);
    }

    public void SetHP(float newHP, float maxHP) {
    	GCTX.Log("Changing HP to " + newHP);
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
    	_addLineTS = Time.time;
    }

    public void SetLeftAlive(int alive)
    {
    	LeftAlive.text = alive.ToString();
    }

    public void UpdateHUD(PlayerController player = null) {
    	if (player == null ) {
    		player = LocalPlayer;
    	};
    	if (player) {
    		
    	}
    }

    public void Update() {
    	if (_addLineTS > 0) {
    		if (Time.time - _addLineTS < 3) {
				Color __temp =  new Color(InfoPanel.color.r, InfoPanel.color.g, InfoPanel.color.b,1.0f - ((Time.time - _addLineTS) / 3.0f) );
				InfoPanel.color = __temp;	
    		} else {
    			_addLineTS = 0;
    			InfoPanel.text = "";
    		};
    	}
    }

    public void SetAmmo(string name, int current, int backpack)
    {
        if (AmmoValue != null)
        {
            AmmoValue.text = string.Format("{0}\nAmmo:{1}\nBackpack:{2}", name, current, backpack);
        }
    }

    public void SetShowUseButton(bool enabled)
    {
        UseButton.gameObject.SetActive(enabled);
    }

    public void SetUseButtonInteractable(bool enabled)
    {
        UseButton.interactable = enabled;
    }

    private void OnUseButtonClicked()
    {
        Debug.LogFormat("USE BUTTON CLICKED");
        if (LocalPlayer != null)
        {
            LocalPlayer.StartUse();
        }
    }

    //+++ zone widget
    public void SetZoneStageData(float startTime, float endTime, ZoneState state)
    {
        ZoneProgress.SetFireSystemData(startTime, endTime, state);
    }
    //--- zone widget
}
