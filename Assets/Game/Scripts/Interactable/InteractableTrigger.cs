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
        if (pc != null && pc._interactSystem != null && pc._interactSystem.enabled && interactable.CanInteract(pc))
        {
            pc._interactSystem.TryActivateInteractable(interactable);
        }
    }

    void OnTriggerExit(Collider other)
    {
        if (interactable == null)
        {
            interactable = transform.parent.GetComponent<Interactable>();
        }
        var pc = other.GetComponent<PlayerController>();
        if (pc != null && pc._interactSystem != null && pc._interactSystem.enabled)
        {
            pc._interactSystem.TryDeactivateInteractable(interactable);
        }
    }
}
