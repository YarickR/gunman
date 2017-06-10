using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Networking;

public class AutoInteract : NetworkBehaviour {

	// Use this for initialization
	void Start () {
        if (isServer)
        {
            GetComponent<Interactable>().Interact(null);
        }
	}
	
	// Update is called once per frame
	void Update () {
		
	}
}
