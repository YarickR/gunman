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

        public void AnnounceFire(float announceInterval, int fireStep)
        {
            _gameHUD.AddInfoLine(string.Format("Fire step {1} will be in {0} seconds", announceInterval, fireStep));
        }

        public void SetZoneStageData(float startTime, float endTime, ZoneState state)
        {
            //Debug.LogErrorFormat("Set state:{0}", state);

            _gameHUD.SetZoneStageData(startTime, endTime, state);
        }
    }
}
