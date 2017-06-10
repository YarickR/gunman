using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Networking;

public abstract class Interactable : NetworkBehaviour {
    public float PickupRadius = 1;
    public float InteractionTime = 1;

    static HashSet<Interactable> s_all = new HashSet<Interactable>();

    public abstract void Interact(PlayerController player);

    public static IEnumerable<Interactable> All
    {
        get { return s_all; }
    }

    protected virtual void OnEnable()
    {
        s_all.Add(this);
    }

    protected virtual void OnDisable()
    {
        s_all.Remove(this);
    }
}
