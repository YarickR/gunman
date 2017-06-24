using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Networking;

public class ContainerOnStartGenerate : MonoBehaviour
{
    public ContainerParams preset;

    public void Awake()
    {
        if (NetworkServer.active)
        {
            RollAndSpawn();
        }
    }

    private void RollAndSpawn()
    {
        Interactable rolledObj = preset.Roll();
        if (rolledObj == null)
        {
            return;
        }

        var targetObj = GameObject.Instantiate(rolledObj.gameObject, transform.position, transform.rotation);
        NetworkServer.Spawn(targetObj);
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.yellow;
        Gizmos.DrawSphere(transform.position, 0.3f);
    }
}
