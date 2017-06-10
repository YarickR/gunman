using UnityEngine;
public class InteractableTrigger : MonoBehaviour
{
    Interactable interactable;

    void OnTriggerEnter(Collider other)
    {
        if (interactable == null)
        {
            interactable = transform.parent.GetComponent<Interactable>();
        }
        var pc = other.GetComponent<PlayerController>();
        if (pc != null && pc.InteractSystem != null && pc.InteractSystem.enabled)
        {
            pc.InteractSystem.TryActivateInteractable(interactable);
        }
    }

    void OnTriggerExit(Collider other)
    {
        if (interactable == null)
        {
            interactable = transform.parent.GetComponent<Interactable>();
        }
        var pc = other.GetComponent<PlayerController>();
        if (pc != null && pc.InteractSystem != null && pc.InteractSystem.enabled)
        {
            pc.InteractSystem.TryDeactivateInteractable(interactable);
        }
    }
}
