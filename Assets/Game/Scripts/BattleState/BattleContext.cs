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
            if (isRealPlayerController(player))
            {
                battleState.RegisterAlivePlayer(player);
            }
        }

        public void UnregisterPlayerController(PlayerController player)
        {
            if (isRealPlayerController(player))
            {
                battleState.UnregisterAlivePlayer(player);
            }
        }

        public void Dispose()
        {
            NetworkServer.Destroy(_battleState.gameObject);
        }

        private bool isRealPlayerController(PlayerController player)
        {
            return player.netId != NetworkInstanceId.Invalid && player.playerControllerId != -1;
        }
    }

    /// <summary>
    /// create on replicate battle state object from server
    /// </summary>
    public class BattleClientContext
    {
        public IClientBattleState battleState { get { return _battleState; } }
        private readonly BattleState _battleState;

        public readonly GameHUDProvider gameHUDProvider;
        public readonly GameHUD gameHUD;

        public BattleClientContext(GameHUD hud, BattleState state, short targetPlayerId)
        {
            gameHUD = hud;
            gameHUDProvider = new GameHUDProvider(gameHUD, targetPlayerId);

            _battleState = state;
        }
    }
}
