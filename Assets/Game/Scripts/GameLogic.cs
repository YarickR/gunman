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
        if (player.playerControllerId != -1)
        {
            Debug.LogFormat("OnPlayerAlive {0} {1}", player.playerControllerId, localPlayer);

            PlayerSpawned(player);

            if (localPlayer)
            {
                HUD.SwitchToLive();
            }
        }
    }

    public void OnPlayerDeath(PlayerController player, bool localPlayer)
    {   
        if (player.playerControllerId != -1)
        {
            Debug.LogFormat("OnPlayerDeath {0} {1}", player.playerControllerId, localPlayer);
            PlayerKilled(player);

            if (localPlayer)
            {
                HUD.SwitchToDeath();
            }
        }
    }

    [Server]
    void PlayerSpawned(PlayerController player)
    {
        activePlayers[player.playerControllerId] = player;
    }

    [Server]
    void PlayerKilled(PlayerController player)
    {
        activePlayers.Remove(player.playerControllerId);
        checkWinConditions();
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
