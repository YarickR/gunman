using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Networking;

public abstract class Interactable : NetworkBehaviour {
    public float PickupRadius = 1;
    public float InteractionTime = 1;

    public Transform SelectionAnchor;

    public abstract void Interact(PlayerController player);

    void Awake()
    {
        createTrigger();
    }

    void createTrigger()
    {
        var go = new GameObject("trigger", typeof(SphereCollider), typeof(InteractableTrigger));
        go.layer = 11;
        var sc = go.GetComponent<SphereCollider>();
        sc.isTrigger = true;
        sc.radius = PickupRadius;
        go.transform.SetParent(transform, false);
        Vector3 p = transform.position;
        p.y = 1;
        go.transform.position = p;
    }

    public virtual bool CanInteract(PlayerController pc)
    {
        return true;
    }
}
