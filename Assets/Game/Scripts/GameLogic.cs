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

    int playersCount = 0;

    Dictionary<NetworkInstanceId, PlayerController> activePlayers = new Dictionary<NetworkInstanceId, PlayerController>();
    public PlayerController LocalPlayer;
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
        playersCount = 0;
        HUD.gameObject.SetActive(false);
        Debug.LogFormat("ON ENTER LOBBY");
    }

    public void OnPlayerAlive(PlayerController player, bool localPlayer)
    {
        if (player.netId != NetworkInstanceId.Invalid && player.playerControllerId != -1)
        {
            PlayerSpawned(player);
        }
        if (localPlayer) {
        	LocalPlayer = player;
        };
    }

    public void OnPlayerDeath(PlayerController player, bool localPlayer)
    {
        Debug.LogFormat("player death {0}", localPlayer);
        if (player.netId != NetworkInstanceId.Invalid)
        {  
            PlayerKilled(player);
        }
    }

    [Server]
    void PlayerSpawned(PlayerController player)
    {
        if (!activePlayers.ContainsKey(player.netId))
        {
            playersCount += 1;
            activePlayers[player.netId] = player;

            Debug.LogFormat("SPAWN PLAYER {0}/{1}", activePlayers.Count, playersCount);
        }
    }

    [Server]
    void PlayerKilled(PlayerController player)
    {
        if (activePlayers.ContainsKey(player.netId))
        {

            Debug.LogFormat("KILL PLAYER {0}/{1}", activePlayers.Count, playersCount);
            player.RpcEnd(false, activePlayers.Count, playersCount);
            activePlayers.Remove(player.netId);
            
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

        foreach (var player in activePlayers)
        {
            player.Value.RpcEnd(true, 1, playersCount);
        }
        activePlayers.Clear();

        StartCoroutine(waitAndRestart());
    }

    [Server]
    IEnumerator waitAndRestart()
    {
        yield return new WaitForSeconds(EndGameDuration);
        LobbyManager.s_Singleton.ServerReturnToLobby();
    }
}
