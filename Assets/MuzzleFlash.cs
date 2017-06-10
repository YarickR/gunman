using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MuzzleFlash : MonoBehaviour {

	private float _flashStart;
	// Use this for initialization
	void Start () {
		
	}


	public void Flash() {
		_flashStart = Time.time;
		gameObject.SetActive(true);
	}
	// Update is called once per frame
	void Update () {
		if (_flashStart > 0) {
			if ((Time.time - _flashStart) > 0.1f) { 
				gameObject.SetActive(false);
				_flashStart = 0;
			} 
		}
	}
}
