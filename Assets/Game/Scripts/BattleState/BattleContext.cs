using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Networking;

namespace Battle
{
    /// <summary>
    /// create on server lobby start countdown
    /// need to dispose after battle
    /// </summary>
    public class BattleServerContext : IDisposable
    {
        public IServerBattleState battleState { get { return _battleState; } }
        private readonly BattleState _battleState;

        public BattleServerContext(BattleState state)
        {
            _battleState = state;
        }

        public void RegisterPlayerController(PlayerController player)
        {
            battleState.RegisterPlayer(player);
        }

        public void UnregisterPlayerController(PlayerController player)
        {
            battleState.UnregisterPlayer(player);
        }

        public void Dispose()
        {
            NetworkServer.Destroy(_battleState.gameObject);
        }
    }

    /// <summary>
    /// create on replicate battle state object from server
    /// </summary>
    public class BattleClientContext
    {
        public IClientBattleState battleState { get { return _battleState; } }
        private readonly BattleState _battleState;

        public readonly GameHUD gameHUD;

        public BattleClientContext(GameHUD hud, BattleState state)
        {
            gameHUD = hud;
            _battleState = state;
        }
    }
}
