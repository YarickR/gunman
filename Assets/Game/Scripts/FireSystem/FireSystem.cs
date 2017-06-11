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

public class FireSystem : NetworkBehaviour {
    public FireSystemStep[] Steps;

    public float DamagePeriod = 1;
    public float Damage = 15;

    public float AnnounceInterval = 5;

    int activatedStep = -1;

    float fromScale;
    float toScale;
    float startScaleTime;
    float duration;

    float startTime;

    bool shouldDoAnnounce = true;

    HashSet<PlayerController> safePlayers = new HashSet<PlayerController>();

    public override void OnStartServer()
    {
        base.OnStartServer();
        if (isServer)
        {
            startTime = Time.time;
            fromScale = transform.localScale.x;
            StartCoroutine(DamageAll());
            StartCoroutine(UpdateScale());
        }
    }

    [ClientRpc]
    void RpcSetScale(float scaleToSet)
    {
        transform.localScale = new Vector3(scaleToSet, transform.localScale.y, scaleToSet);
    }

    public void AnnounceFire()
    {
        // implement logic here
        Debug.LogFormat("Fire will be in {0} seconds", AnnounceInterval);
    }

    void OnDestroy()
    {
        StopAllCoroutines();
    }

    public void Update()
    {
        if (isServer && activatedStep > -1)
        {
            var normalizedTime = Mathf.Clamp01((Time.time - startScaleTime - startTime) / duration);
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

            var time = Time.time - startTime;

            //Debug.LogFormat("time {0} realtime {1} delta {2} PlayTime {3} starttime {4}", Time.time, Time.realtimeSinceStartup, Time.time - Time.realtimeSinceStartup, time, startTime);

            var candidateStep = activatedStep + 1;
            
            if (candidateStep < Steps.Length)
            {
                var stepData = Steps[candidateStep];

                if (candidateStep != activatedStep)
                {
                    if (shouldDoAnnounce && stepData.StartTime <= time + AnnounceInterval)
                    {
                        AnnounceFire();
                        shouldDoAnnounce = false;
                    }

                    if (stepData.StartTime <= time)
                    {
                        shouldDoAnnounce = true;
                        fromScale = transform.localScale.x;
                        toScale = stepData.Scale;
                        startScaleTime = Time.time - startTime;
                        duration = stepData.Duration;

                        activatedStep = candidateStep;
                    }
                }
            }
        }
    }

    List<PlayerController> cachedPlayers = new List<PlayerController>();
    IEnumerator DamageAll()
    {
        while (enabled)
        {
            yield return new WaitForSeconds(DamagePeriod);
            if (enabled)
            {
                cachedPlayers.Clear();

                cachedPlayers.AddRange(GameLogic.Instance.ActivePlayers.Values);
                foreach (var p in cachedPlayers)
                {
                    if (!safePlayers.Contains(p))
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
            safePlayers.Add(pc);
        }
    }

    void OnTriggerExit(Collider other)
    {
        var pc = other.GetComponent<PlayerController>();
        if (pc != null)
        {
            safePlayers.Remove(pc);
        }
    }
}
