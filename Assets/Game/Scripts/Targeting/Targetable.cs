using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Targetable : MonoBehaviour {
    static HashSet<Targetable> s_allTargets = new HashSet<Targetable>();

    public CapsuleCollider Collider;

    public static IEnumerable<Targetable> AllTargets
    {
        get { return s_allTargets; }
    }

    void Awake()
    {
        if (Collider == null)
        {
            Collider = GetComponent<CapsuleCollider>();
        }
    }

    void OnEnable()
    {
        s_allTargets.Add(this);
        Debug.LogFormat("TARGETS {0}", s_allTargets.Count);
    }

    void OnDisable()
    {
        s_allTargets.Remove(this);
        Debug.LogFormat("TARGETS {0}", s_allTargets.Count);
    }
}
