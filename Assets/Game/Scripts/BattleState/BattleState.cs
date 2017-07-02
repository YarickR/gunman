using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Networking;
using Prototype.NetworkLobby;

namespace Battle
{
    public interface IClientBattleState
    {
        float GetServerTime();
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
        private bool _isServerWithLocalPlayer = false;

        private Dictionary<NetworkInstanceId, PlayerController> _alivePlayers = new Dictionary<NetworkInstanceId, PlayerController>();
        

        //server->client data
        [SyncVar(hook = "OnChangeAlivePlayersCount")]
        private int _alivePlayersCount = 0;

        [SyncVar(hook = "OnSetStartServerTime")]
        private float _startServerTime;

        //client only data
        private bool _isClientInited = false;
        private GameHUDProvider _gameHUDProvider = null;
        private float _serverTimeDelta = 0.0f;

        public override void OnStartServer()
        {
            base.OnStartServer();

            _startServerTime = Time.time;

            //workaround for support client+server on one instance
            _isServerWithLocalPlayer = NetworkServer.localClientActive;
        }

        public override void OnStartClient()
        {
            base.OnStartClient();

            var clientContext = LobbyManager.Instance.CreateBattleClientContext(this, _isServerWithLocalPlayer);
            _isClientInited = clientContext != null;

            if (_isClientInited)
            {
                _gameHUDProvider = clientContext.gameHUDProvider;

                OnChangeAlivePlayersCount(_alivePlayersCount);
                OnSetStartServerTime(_startServerTime);
            }
        }

        #region IServerBattleState
        IEnumerable<KeyValuePair<NetworkInstanceId, PlayerController>> IServerBattleState.alivePlayers
        {
            get
            {
                return _alivePlayers;
            }
        }

        void IServerBattleState.RegisterAlivePlayer(PlayerController player)
        {
            if (!_alivePlayers.ContainsKey(player.netId))
            {
                _alivePlayers[player.netId] = player;
                _alivePlayersCount = _alivePlayers.Count;
            }
        }

        void IServerBattleState.UnregisterAlivePlayer(PlayerController player)
        {
            if (_alivePlayers.ContainsKey(player.netId))
            {
                _alivePlayers.Remove(player.netId);
                _alivePlayersCount = _alivePlayers.Count;
            }
        }
        #endregion

        #region SyncVar
        private void OnChangeAlivePlayersCount(int newCount)
        {
            _alivePlayersCount = newCount;

            if (_isClientInited)
            {
                _gameHUDProvider.SetAliveCount(_alivePlayersCount);
            }
        }

        private void OnSetStartServerTime(float startServerTime)
        {
            _startServerTime = startServerTime;

            _serverTimeDelta = Time.time - _startServerTime;
        }
        #endregion

        #region IClientBattleState
        float IClientBattleState.GetServerTime()
        {
            return Time.time + _serverTimeDelta;
        }
        #endregion
    }
}
