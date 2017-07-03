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
        float SetverTimeToLocal(float serverTime);
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

        //battle settings
        [Range(0, 60)]
        public float EndGameDuration = 10f;

        //server only data
        private bool _isServerWithLocalPlayer = false;

        private Dictionary<NetworkInstanceId, PlayerController> _alivePlayers = new Dictionary<NetworkInstanceId, PlayerController>();
        private int _overallPlayers = 0;

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

            Debug.LogError("OnStartClient");

            var clientContext = LobbyManager.Instance.CreateBattleClientContext(this, _isServerWithLocalPlayer);
            _isClientInited = clientContext != null;

            if (_isClientInited)
            {
                Debug.LogError("OnStartClient GOOD");
                _gameHUDProvider = clientContext.gameHUDProvider;

                OnChangeAlivePlayersCount(_alivePlayersCount);
                OnSetStartServerTime(_startServerTime);
            }
        }

        [Server]
        private void EndBattle()
        {
            //need valid hierarhi
            var fs = GameObject.FindObjectOfType<FireSystem>();
            if (fs != null)
            {
                fs.StopAllCoroutines();
                fs.enabled = false;
            }

            if (_alivePlayersCount > 0)
            {
                var enumeraor = _alivePlayers.GetEnumerator();
                if (enumeraor.MoveNext())
                {
                    enumeraor.Current.Value.RpcEnd(true, _alivePlayersCount, _overallPlayers);
                }
            }

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
                _overallPlayers += 1;
                _alivePlayers[player.netId] = player;
                _alivePlayersCount = _alivePlayers.Count;
            }
        }

        void IServerBattleState.UnregisterAlivePlayer(PlayerController player)
        {
            if (_alivePlayers.ContainsKey(player.netId))
            {
                player.RpcEnd(false, _alivePlayersCount, _overallPlayers);

                _alivePlayers.Remove(player.netId);
                _alivePlayersCount = _alivePlayers.Count;

                if (_alivePlayersCount <= 1)
                {
                    EndBattle();
                } 
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

        float IClientBattleState.SetverTimeToLocal(float serverTime)
        {
            return serverTime + _serverTimeDelta;
        }
        #endregion
    }
}
