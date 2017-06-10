using Prototype.NetworkLobby;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameLogic : MonoBehaviour {
    public GameHUD HUD;

    public static GameLogic Instance
    {
        get
        {
            return LobbyManager.s_Singleton.GameLogic;
        }
    }

    public void OnPlayerAlive()
    {
        HUD.SwitchToLive();
    }

    public void OnPlayerDeath()
    {
        HUD.SwitchToDeath();
    }
}
