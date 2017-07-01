using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Battle
{
    public class GameHUDProvider
    {
        private readonly GameHUD _gameHUD;

        private short _targetPlayerID;

        public GameHUDProvider(GameHUD hud, short targetPlayerID)
        {
            _gameHUD = hud;
            _targetPlayerID = targetPlayerID;
        }

        public void SetAliveCount(int aliveCount)
        {
            _gameHUD.SetLeftAlive(aliveCount);
        }
    }
}
