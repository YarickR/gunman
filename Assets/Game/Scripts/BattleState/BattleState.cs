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
        IEnumerable<KeyValuePair<NetworkInstanceId, PlayerController>> alivePlayers { get; }

        void RegisterAlivePlayer(PlayerController player);
        void UnregisterAlivePlayer(PlayerController player);
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

        //server only data
        private Dictionary<NetworkInstanceId, PlayerController> _alivePlayers = new Dictionary<NetworkInstanceId, PlayerController>();
        public IEnumerable<KeyValuePair<NetworkInstanceId, PlayerController>> alivePlayers
        {
            get
            {
                return _alivePlayers;
            }
        }

        //server->client data
        [SyncVar(hook = "OnChangeAlivePlayersCount")]
        public int _alivePlayersCount = 0;

        //client only data
        private GameHUDProvider _gameHUDProvider = null;

        public override void OnStartClient()
        {
            base.OnStartClient();

            var clientContext = LobbyManager.Instance.CreateBattleClientContext(this);
            _gameHUDProvider = clientContext.gameHUDProvider;

            OnChangeAlivePlayersCount(_alivePlayersCount);
        }

        public void RegisterAlivePlayer(PlayerController player)
        {
            if (player.netId == NetworkInstanceId.Invalid || player.playerControllerId == -1)
            {
                return;
            }

            if (!_alivePlayers.ContainsKey(player.netId))
            {
                _alivePlayers[player.netId] = player;
                _alivePlayersCount = _alivePlayers.Count;
            }
        }

        public void UnregisterAlivePlayer(PlayerController player)
        {
            if(player.netId == NetworkInstanceId.Invalid || player.playerControllerId == -1)
            {
                return;
            }

            if (_alivePlayers.ContainsKey(player.netId))
            {
                _alivePlayers.Remove(player.netId);
                _alivePlayersCount = _alivePlayers.Count;
            }
        }

        #region SyncVar
        private void OnChangeAlivePlayersCount(int newCount)
        {
            _alivePlayersCount = newCount;
            _gameHUDProvider.SetAliveCount(_alivePlayersCount);
        }
        #endregion
    }
}
