﻿using Prototype.NetworkLobby;
using System.Collections;
using System.Collections.Generic;
using System;
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
    public Dictionary<NetworkInstanceId, PlayerController> ActivePlayers
    {
        get { return activePlayers; }
    }

    public static GameLogic Instance
    {
        get
        {
            return LobbyManager.Instance.GameLogic;
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
    }

    public void OnPlayerDeath(PlayerController player, bool localPlayer)
    {
        Debug.LogFormat("player death {0}", localPlayer);
        if (player.netId != NetworkInstanceId.Invalid)
        {  
            PlayerKilled(player);
        }
    }

    #region Server only
    [Server]
    void PlayerSpawned(PlayerController player)
    {
        if (!activePlayers.ContainsKey(player.netId))
        {
            playersCount += 1;
            activePlayers[player.netId] = player;

            player.RpcUpdateAliveCount(activePlayers.Count);

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

            if (PlayerController.LocalClientController != null)
            {
                PlayerController.LocalClientController.RpcUpdateAliveCount(activePlayers.Count);
            }

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

        var fs = GameObject.FindObjectOfType<FireSystem>();
        if (fs != null)
        {
            fs.enabled = false;
            GameObject.Destroy(fs);
        }

        foreach (var player in activePlayers)
        {
            player.Value.RpcEnd(true, 1, playersCount);
        }
        activePlayers.Clear();

        if (this != null)
        {
            StartCoroutine(waitAndRestart());
        }
    }

    [Server]
    IEnumerator waitAndRestart()
    {
        yield return new WaitForSeconds(EndGameDuration);
        LobbyManager.Instance.ServerReturnToLobby();
    }

    public void SendAlivePlayerCount(PlayerController player)
    {
        player.RpcUpdateAliveCount(activePlayers.Count);
        if (NetworkServer.localClientActive)
        {
            player.UpdateAliveCount(activePlayers.Count);
        }
    }
    #endregion
}
