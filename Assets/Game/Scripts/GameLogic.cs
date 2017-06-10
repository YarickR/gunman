using Prototype.NetworkLobby;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Networking;
using UnityEngine.SceneManagement;

public class GameLogic : NetworkBehaviour {
    public GameHUD HUD;

    public static GameLogic Instance
    {
        get
        {
            return LobbyManager.s_Singleton.GameLogic;
        }
    }

    void Start()
    {
        SceneManager.activeSceneChanged += sceneChanged;
    }

    void OnDestroy()
    {
        SceneManager.activeSceneChanged -= sceneChanged;
    }

    private void sceneChanged(Scene oldScene, Scene newScene)
    {
        if (newScene.name == "Main")
        {
            OnEnterLobby();
        }
        else
        {
            OnEnterGame();
        }
    }

    public void OnEnterGame()
    {
        HUD.gameObject.SetActive(true);
        Debug.LogFormat("ON ENTER GAME");
    }

    public void OnEnterLobby()
    {
        HUD.gameObject.SetActive(false);
        Debug.LogFormat("ON ENTER LOBBY");
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
