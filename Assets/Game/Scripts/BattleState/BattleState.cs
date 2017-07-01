using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Networking;
using Prototype.NetworkLobby;

namespace Battle
{
    public interface IClientBattleState
    {

    }

    public interface IServerBattleState
    {
        void RegisterPlayer(PlayerController player);
        void UnregisterPlayer(PlayerController player);
    }

    public class BattleState : NetworkBehaviour, IServerBattleState, IClientBattleState
    {
        public static BattleState Create()
        {
            GameObject prefab = Resources.Load<GameObject>("NetHelpers/BattleState");
            GameObject go = Instantiate<GameObject>(prefab);
            GameObject.DontDestroyOnLoad(go);

            return go.GetComponent<BattleState>();
        }

        private Dictionary<NetworkInstanceId, PlayerController> _allPlayers = new Dictionary<NetworkInstanceId, PlayerController>();

        private Dictionary<NetworkInstanceId, PlayerController> activePlayers = new Dictionary<NetworkInstanceId, PlayerController>();
        public Dictionary<NetworkInstanceId, PlayerController> ActivePlayers
        {
            get { return activePlayers; }
        }

        public override void OnStartServer()
        {
            base.OnStartServer();

            var allNetObjects = NetworkServer.objects;
            foreach (var element in allNetObjects)
            {
                var controller = element.Value.gameObject.GetComponent<PlayerController>();
                if (controller != null)
                {
                    RegisterPlayer(controller);
                }
            }
        }

        public override void OnStartClient()
        {
            base.OnStartClient();

            LobbyManager.Instance.CreateBattleClientContext(this);
        }

        public void RegisterPlayer(PlayerController player)
        {
            if (player.netId == NetworkInstanceId.Invalid || player.playerControllerId == -1)
            {
                return;
            }

            if (!_allPlayers.ContainsKey(player.netId))
            {
                _allPlayers[player.netId] = player;
            }
        }

        public void UnregisterPlayer(PlayerController player)
        {
            if(player.netId == NetworkInstanceId.Invalid || player.playerControllerId == -1)
            {
                return;
            }

            if (_allPlayers.ContainsKey(player.netId))
            {
                _allPlayers.Remove(player.netId);
            }
        }
    }
}
