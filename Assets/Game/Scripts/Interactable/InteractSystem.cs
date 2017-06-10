using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InteractSystem : MonoBehaviour
{
    PlayerController playerController;

    Interactable currentInteractable;

    public Interactable CurrentInteractable
    {
        get
        {
            return currentInteractable;
        }
    }


    public void ClearInteractable()
    {
        setCurrentInteractable(null);
    }

    void Awake()
    {
        playerController = GetComponent<PlayerController>();
    }

    public void TryActivateInteractable(Interactable interactable)
    {
        if (currentInteractable == null)
        {
            setCurrentInteractable(interactable);
        }
    }

    public void TryDeactivateInteractable(Interactable interactable)
    {
        if (currentInteractable == interactable)
        {
            setCurrentInteractable(null);
        }
    }

    void setCurrentInteractable(Interactable interactable)
    {
        currentInteractable = interactable;
        if (currentInteractable != null)
        {
            Debug.LogFormat("Current interactable {0}", currentInteractable);

            

           // playerController.CmdActivateInteractable(interactable.netId);
        }
        playerController.SetShowUseButtonState(currentInteractable != null);
    }
}
