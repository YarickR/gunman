using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Networking;

public class Container : NetworkBehaviour {

	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		
	}

	public void OnClick() {
		Debug.Log("OnClick");
		if (Vector3.Distance(transform.position, GameLogic.Instance.LocalPlayer.transform.position) < 1.0f) {
			Debug.Log("Activating");	
		};
	}
}
