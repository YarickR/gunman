using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Networking;

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

    private double _startServerTimeOnServer;
    private double _startServerTimeOnClient;

    private bool _shouldDoAnnounce = true;

    private HashSet<PlayerController> _safePlayers = new HashSet<PlayerController>();
    private List<PlayerController> _cachedPlayers = new List<PlayerController>();

    public override void OnStartServer()
    {
        base.OnStartServer();
        if (isServer)
        {
            _startTime = Time.time;
            //_startServerTimeOnServer = Network.time;
            fromScale = transform.localScale.x;
            StartCoroutine(DamageAll());
            StartCoroutine(UpdateScale());

            //if (NetworkServer.localClientActive)
            //{
            //    _startServerTimeOnClient = _startServerTimeOnServer;
            //    GameLogic.Instance.HUD.SetZoneData(Steps, _startServerTimeOnClient);
            //}
        }
    }

    public override void OnStartLocalPlayer()
    {
        base.OnStartLocalPlayer();

        //get current state on client
        CmdRequestServerStatTime();
    }

    #region Command
    [Command]
    private void CmdRequestServerStatTime()
    {
        RpcSetServerStartTime(_startServerTimeOnServer);
    }
    #endregion

    #region ClientRpc
    [ClientRpc]
    void RpcSetScale(float scaleToSet)
    {
        transform.localScale = new Vector3(scaleToSet, transform.localScale.y, scaleToSet);
    }

    [ClientRpc]
    private void RpcSetServerStartTime(double serverStartTime)
    {
        _startServerTimeOnClient = serverStartTime;

        GameLogic.Instance.HUD.SetZoneData(Steps, _startServerTimeOnClient);
    }
    #endregion

    private void AnnounceFire()
    {
        // implement logic here
		foreach( KeyValuePair<NetworkInstanceId, PlayerController> pair in GameLogic.Instance.ActivePlayers) {
			pair.Value.RpcAnnounceFire(AnnounceInterval, activatedStep + 2);
		};
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
                _cachedPlayers.Clear();

                _cachedPlayers.AddRange(GameLogic.Instance.ActivePlayers.Values);
                foreach (var p in _cachedPlayers)
                {
                    if (!_safePlayers.Contains(p))
                    {
                        p.FireDamage(Damage, this.netId);
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
