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
        pickBestInteractable();
    }

    void Awake()
    {
        playerController = GetComponent<PlayerController>();
    }

    void Update()
    {
        if (possibleInteractables.Count > 0)
        {
            pickBestInteractable();
        }
    }

    List<Interactable> possibleInteractables = new List<Interactable>();

    public void TryActivateInteractable(Interactable interactable)
    {
        possibleInteractables.Add(interactable);
        pickBestInteractable();
    }

    public void TryDeactivateInteractable(Interactable interactable)
    {
        possibleInteractables.Remove(interactable);
        pickBestInteractable();
    }

    void pickBestInteractable()
    {
        Interactable candidate = null;
        float minDistSqr = float.MaxValue;

        for (int i = 0; i < possibleInteractables.Count;)
        {
            var inter = possibleInteractables[i];
            if (inter == null)
            {
                possibleInteractables.RemoveAt(i);
            }
            else
            {
                i++;
            }
        }

        foreach (var interactable in possibleInteractables)
        {
            if (!interactable.CanInteract(playerController))
            {
                continue;
            }

            var delta = interactable.transform.position - transform.position;
            var mag = delta.sqrMagnitude;

            if (mag < minDistSqr)
            {
                candidate = interactable;
                minDistSqr = mag;
            }
        }
        setCurrentInteractable(candidate);
    }

    void setCurrentInteractable(Interactable interactable)
    {
        if (currentInteractable != interactable)
        {

            currentInteractable = interactable;
            if (currentInteractable != null)
            {

                if (Selection != null)
                {
                    Selection.gameObject.SetActive(true);
                    Selection.transform.SetParent(null);

                    var anchor = interactable.SelectionAnchor != null ? interactable.SelectionAnchor : interactable.transform;
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

        Selection.gameObject.SetActive(interactable != null);
    }
}
