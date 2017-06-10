using Prototype.NetworkLobby;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Networking;
using UnityEngine.SceneManagement;

public class GameLogic : NetworkBehaviour
{
    public GameHUD HUD;
    [Range(0, 60)]
    public float EndGameDuration = 10f;

    int currentPlayerCount = 0;

    Dictionary<short, PlayerController> activePlayers = new Dictionary<short, PlayerController>();

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
        activePlayers.Clear();
        HUD.gameObject.SetActive(false);
        Debug.LogFormat("ON ENTER LOBBY");
    }

    public void OnPlayerAlive(PlayerController player, bool localPlayer)
    {
        Debug.LogFormat("player alive {0}", localPlayer);
        if (player.playerControllerId != -1)
        {
            PlayerSpawned(player);
        }
    }

    public void OnPlayerDeath(PlayerController player, bool localPlayer)
    {
        Debug.LogFormat("player death {0}", localPlayer);
        if (player.playerControllerId != -1)
        {  
            PlayerKilled(player);
        }
    }

    [Server]
    void PlayerSpawned(PlayerController player)
    {
        activePlayers[player.playerControllerId] = player;
        Debug.LogFormat("OnPlayerAlive {0}", player.playerControllerId);
    }

    [Server]
    void PlayerKilled(PlayerController player)
    {
        if (activePlayers.ContainsKey(player.playerControllerId))
        {
            Debug.LogFormat("OnPlayerDeath {0}", player.playerControllerId);
            activePlayers.Remove(player.playerControllerId);
            checkWinConditions();
        }
    }

    [Server]
    void checkWinConditions()
    {
        if (activePlayers.Count <= 1)
        {
            endGame();
        }
    }

    [Server]
    void endGame()
    {
        Debug.LogFormat("END GAME");

        StartCoroutine(waitAndRestart());
    }

    [Server]
    IEnumerator waitAndRestart()
    {
        yield return new WaitForSeconds(EndGameDuration);
        LobbyManager.s_Singleton.ServerReturnToLobby();
    }
}
