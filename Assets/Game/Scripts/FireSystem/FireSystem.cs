using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Networking;
using Prototype.NetworkLobby;
using Battle;

[System.Serializable]
public struct FireSystemStep
{   
    public float StartTime;
    public float Duration; 
    public float Scale;

    public float OverallStageTime { get { return StartTime + Duration; } }
}

public enum ZoneState
{
    Wait,
    Movihg,
}

public class FireSystem : NetworkBehaviour
{
    public FireSystemStep[] Steps;

    public float DamagePeriod = 1;
    public float Damage = 15;

    public float AnnounceInterval = 5;

    int activatedStep = -1;

    // +++ workaround for start initit on clients
    [SyncVar]
    private float _startStageTime;
    [SyncVar]
    private float _endStageTime;
    [SyncVar]
    private ZoneState _stageState;
    // --- workaround for start initit on clients

    private float _startTime;
    private float _startStepTime;
    private int _currentStepIndex;

    private HashSet<PlayerController> _safePlayers = new HashSet<PlayerController>();

    private BattleServerContext _serverContext;
    private BattleClientContext _clientContext;

    public override void OnStartServer()
    {
        base.OnStartServer();

        _serverContext = LobbyManager.Instance.battleServerContext;

        _currentStepIndex = -1;
        _startTime = Time.time;
        
        StartCoroutine(DamageAll());

        StartNextStep();
    }

    public override void OnStartClient()
    {
        base.OnStartClient();

        _clientContext = LobbyManager.Instance.battleClientContext;

        var clientStartTime = _clientContext.battleState.SetverTimeToLocal(_startStageTime);
        var clientEndTime = _clientContext.battleState.SetverTimeToLocal(_endStageTime);
        _clientContext.gameHUDProvider.SetZoneStageData(clientStartTime, clientEndTime, _stageState);
    }

    [Server]
    public void SendStateDataToClients(float startTime, float endTime, ZoneState state)
    {
        _startStageTime = startTime;
        _endStageTime = endTime;
        _stageState = state;

        RpcStartStage(startTime, endTime, state);
    }

    #region ClientRpc
    [ClientRpc]
    private void RpcSetScale(float scaleToSet)
    {
        transform.localScale = new Vector3(scaleToSet, transform.localScale.y, scaleToSet);
    }

    [ClientRpc]
    private void RpcStartStage(float startTime, float endTime, ZoneState state)
    {
        var clientStartTime = _clientContext.battleState.SetverTimeToLocal(startTime);
        var clientEndTime = _clientContext.battleState.SetverTimeToLocal(endTime);

        _clientContext.gameHUDProvider.SetZoneStageData(clientStartTime, clientEndTime, state);
    }

    [ClientRpc]
    private void RpcAnnounceFire(float announceInterval, int fireStep)
    {
        _clientContext.gameHUDProvider.AnnounceFire(announceInterval, fireStep);
    }
    #endregion

    private void AnnounceFire()
    {
        RpcAnnounceFire(AnnounceInterval, _currentStepIndex + 2);
    }

    void OnDestroy()
    {
        StopAllCoroutines();
    }

    private void StartNextStep()
    {
        if (_currentStepIndex > -1)
        {
            _startStepTime += Steps[_currentStepIndex].OverallStageTime;
        }
        else
        {
            _startStepTime = _startTime;
        }

        _currentStepIndex += 1;

        if (_currentStepIndex < Steps.Length)
        {
            StartCoroutine(WaitStage(_currentStepIndex));
        }
    }

    IEnumerator WaitStage(int targetStepIndex)
    {
        FireSystemStep targetStep = Steps[targetStepIndex];
        float time = Time.time - _startTime;

        //to do спорно мб переписить
        var delay = targetStep.StartTime;
        if (targetStepIndex > 0)
        {
            delay -= Steps[targetStepIndex - 1].OverallStageTime;
        }

        SendStateDataToClients(_startStepTime, _startStepTime + delay, ZoneState.Wait);

        bool shouldDoAnnounce = true;

        while (time < targetStep.StartTime)
        {
            if (shouldDoAnnounce && targetStep.StartTime <= time + AnnounceInterval)
            {
                AnnounceFire();
                shouldDoAnnounce = false;
            }

            yield return new WaitForSecondsRealtime(0.5f);
            time = Time.time - _startTime;
        }

        StartCoroutine(MoveStage(targetStepIndex));
    }

    IEnumerator MoveStage(int targetStepIndex)
    {
        FireSystemStep targetStep = Steps[targetStepIndex];
        float time = Time.time - _startTime;

        SendStateDataToClients(_startTime + targetStep.StartTime, _startTime + targetStep.OverallStageTime, ZoneState.Movihg);

        float fromScale = transform.localScale.x;

        while (time <= targetStep.OverallStageTime)
        {
            var normalizedTime = Mathf.Clamp01((time - targetStep.StartTime) / targetStep.Duration);
            var scaleToSet = Mathf.Lerp(fromScale, targetStep.Scale, normalizedTime);

            if (transform.localScale.x != scaleToSet)
            {
                transform.localScale = new Vector3(scaleToSet, transform.localScale.y, scaleToSet);
                RpcSetScale(scaleToSet);
            }

            yield return null;
            time = Time.time - _startTime;
        }

        transform.localScale = new Vector3(targetStep.Scale, transform.localScale.y, targetStep.Scale);
        RpcSetScale(targetStep.Scale);

        StartNextStep();
    }

    IEnumerator DamageAll()
    {
        while (enabled)
        {
            yield return new WaitForSeconds(DamagePeriod);
            if (enabled)
            {
                foreach (var p in _serverContext.battleState.alivePlayers)
                {
                    if (!_safePlayers.Contains(p.Value))
                    {
                        p.Value.FireDamage(Damage, netId);
                    }
                }
            }
        }
    }

    void OnTriggerEnter(Collider other)
    {
        var pc = other.GetComponent<PlayerController>();
        if (pc != null)
        {
            _safePlayers.Add(pc);
        }
    }

    void OnTriggerExit(Collider other)
    {
        var pc = other.GetComponent<PlayerController>();
        if (pc != null)
        {
            _safePlayers.Remove(pc);
        }
    }
}
