using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InteractSystem : MonoBehaviour
{
    public GameObject Selection;

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

            if (Selection != null)
            {
                Selection.gameObject.SetActive(true);
                Selection.transform.SetParent(null);

                var anchor = interactable.SelectionAnchor != null ? interactable.SelectionAnchor : interactable.transform ;
                Selection.transform.SetParent(anchor);
                Selection.transform.localPosition = Vector3.zero;
                Selection.transform.SetParent(null, true);
            }

           // playerController.CmdActivateInteractable(interactable.netId);
        }
        else
        {
            if (Selection != null)
            {
                Selection.gameObject.SetActive(false);    
            }
        }
        
        

        playerController.SetShowUseButtonState(currentInteractable != null);
    }
}
