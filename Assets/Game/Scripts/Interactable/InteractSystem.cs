using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InteractSystem : MonoBehaviour {
    PlayerController playerController;

    Interactable currentInteractable;

    void Awake()
    {
        playerController = GetComponent<PlayerController>();
    }

    void Update()
    {
        CheckInteracts();
    }

    void CheckInteracts()
    {
        if (currentInteractable != null)
        {
            if (!checkDistance(currentInteractable)) {
                setCurrentInteractable(null);
            }
        }

        if (currentInteractable == null)
        {
            foreach (var i in Interactable.All)
            {
                if (checkDistance(i))
                {
                    setCurrentInteractable(i);
                    break;
                }
            }
        }
    }

    bool checkDistance(Interactable i)
    {
        var delta = i.transform.position - transform.position;
        delta.y = 0;
        
        return delta.sqrMagnitude < i.PickupRadius * i.PickupRadius;
    }

    void setCurrentInteractable(Interactable interactable)
    {
        if (currentInteractable != interactable)
        {
            Debug.LogFormat("Current interactable {0}", interactable);
            currentInteractable = interactable;
            if (currentInteractable != null)
            {
                currentInteractable.Interact(playerController);
            }
        }
    }
}
