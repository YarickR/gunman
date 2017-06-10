using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Targetable : MonoBehaviour
{
    static HashSet<Targetable> s_allTargets = new HashSet<Targetable>();

    public Collider Collider;
    public float Radius;

    public bool isVisibleOnly = false;

    public PlayerController PlayerController;

    public static IEnumerable<Targetable> AllTargets
    {
        get { return s_allTargets; }
    }

    Renderer[] renderers;

    bool _visible = true;
    public bool Visible {
        set {
            if (_visible != value)
            {
            //    Debug.LogFormat("CHANGE VISIBILITY {0} {1}", PlayerController.playerControllerId, value);
                foreach (var r in renderers)
                {
                    r.enabled = value;
                }
                _visible = value;
            }
        }
    }

    void Awake()
    {
        renderers = GetComponentsInChildren<Renderer>();
        if (Collider == null)
        {
            Collider = GetComponent<Collider>();
        }
        
        if (PlayerController == null)
        {
            PlayerController = GetComponent<PlayerController>();
        }

        if (Collider is CharacterController)
        {
            Radius = (Collider as CharacterController).radius;
        } else if (Collider is CapsuleCollider)
        {
            Radius = (Collider as CapsuleCollider).radius;
        } else
        {
            var bounds = Collider.bounds.extents;
            Radius = Mathf.Max(bounds.x, bounds.z);
        }
    }

    void OnEnable()
    {
        s_allTargets.Add(this);
      //  Debug.LogFormat("TARGETS {0}", s_allTargets.Count);
    }

    void OnDisable()
    {
        s_allTargets.Remove(this);
//        Debug.LogFormat("TARGETS {0}", s_allTargets.Count);
    }
}
