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
}

public class FireSystem : NetworkBehaviour
{
    public FireSystemStep[] Steps;

    public float DamagePeriod = 1;
    public float Damage = 15;

    public float AnnounceInterval = 5;

    int activatedStep = -1;

    float fromScale;
    float toScale;
    float startScaleTime;
    float duration;

    private float _startTime;

    private bool _shouldDoAnnounce = true;

    private HashSet<PlayerController> _safePlayers = new HashSet<PlayerController>();

    private BattleServerContext _serverContext;
    private BattleClientContext _clientContext;

    public override void OnStartServer()
    {
        base.OnStartServer();

        _serverContext = LobbyManager.Instance.battleServerContext;
        _startTime = Time.time;

        fromScale = transform.localScale.x;
        StartCoroutine(DamageAll());
        StartCoroutine(UpdateScale());
    }

    public override void OnStartClient()
    {
        base.OnStartClient();

        _clientContext = LobbyManager.Instance.battleClientContext;
    }

    #region Command
    #endregion

    #region ClientRpc
    [ClientRpc]
    void RpcSetScale(float scaleToSet)
    {
        transform.localScale = new Vector3(scaleToSet, transform.localScale.y, scaleToSet);
    }

    [ClientRpc]
    void RpcAnnounceFire(float announceInterval, int fireStep)
    {
        _clientContext.gameHUDProvider.AnnounceFire(announceInterval, fireStep);
    }
    #endregion

    private void AnnounceFire()
    {
        RpcAnnounceFire(AnnounceInterval, activatedStep + 2);
    }

    void OnDestroy()
    {
        StopAllCoroutines();
    }

    public void Update()
    {
        if (isServer && activatedStep > -1)
        {
            var normalizedTime = Mathf.Clamp01((Time.time - startScaleTime - _startTime) / duration);
            var scaleToSet = Mathf.Lerp(fromScale, toScale, normalizedTime);

            if (transform.localScale.x != scaleToSet)
            {
                transform.localScale = new Vector3(scaleToSet, transform.localScale.y, scaleToSet);
                RpcSetScale(scaleToSet);
            }
        }
    }

    IEnumerator UpdateScale()
    {
        while (true)
        {
            yield return new WaitForSecondsRealtime(0.5f);

            var time = Time.time - _startTime;

            //Debug.LogFormat("time {0} realtime {1} delta {2} PlayTime {3} starttime {4}", Time.time, Time.realtimeSinceStartup, Time.time - Time.realtimeSinceStartup, time, startTime);

            var candidateStep = activatedStep + 1;
            
            if (candidateStep < Steps.Length)
            {
                var stepData = Steps[candidateStep];

                if (candidateStep != activatedStep)
                {
                    if (_shouldDoAnnounce && stepData.StartTime <= time + AnnounceInterval)
                    {
                        AnnounceFire();
                        _shouldDoAnnounce = false;
                    }

                    if (stepData.StartTime <= time)
                    {
                        _shouldDoAnnounce = true;
                        fromScale = transform.localScale.x;
                        toScale = stepData.Scale;
                        startScaleTime = Time.time - _startTime;
                        duration = stepData.Duration;

                        activatedStep = candidateStep;
                    }
                }
                else
                {
                    //last step achieved
                    break;
                }
            }
        }
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
