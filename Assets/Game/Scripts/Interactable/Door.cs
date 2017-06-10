using UnityEngine;
using UnityEngine.Networking;

public class Door : Interactable
{
    [SyncVar(hook = "OnChangeIsOpen")]
    public bool IsOpen;

    Quaternion initialRotation;

    void Start()
    {
        initialRotation = transform.rotation;
    }

    #region Network Hooks
    void OnChangeIsOpen(bool v)
    {
        IsOpen = v;
        updateOpen();
    }
    #endregion

    void updateOpen()
    {
        transform.rotation = Quaternion.Euler(0, IsOpen ? 90 : 0, 0) * initialRotation;
    }

    public override void Interact(PlayerController player)
    {
        IsOpen = !IsOpen;
        updateOpen();
    }
}
