using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InteractSystem : MonoBehaviour {
    PlayerController playerController;

    void Awake()
    {
        playerController = GetComponent<PlayerController>();
    }
}
