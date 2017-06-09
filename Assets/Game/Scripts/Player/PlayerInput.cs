using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityStandardAssets.CrossPlatformInput;


public class PlayerInput : MonoBehaviour {
    public PlayerCamera Cam;
    public PlayerController Player;
    public float Speed;
	private Vector3 _camFwd;             // The current forward direction of the camera
    private Vector3 _move;
    public void Start() {
    	if (Player == null) {
    		Player = GetComponent<PlayerController>();
    		if (Player == null) {
    			GCTX.Log("Can't find main player object");
    		};
    	}
    }
	public void FixedUpdate() {
    	GCTX ctx = GCTX.Instance;
		float h = CrossPlatformInputManager.GetAxis("Horizontal");
        float v = CrossPlatformInputManager.GetAxis("Vertical");
	    // calculate camera relative direction to move:

	    _camFwd = Vector3.Scale(Cam.transform.forward, new Vector3(1, 0, 1)).normalized;
	    _move = v * _camFwd + h * Cam.transform.right;

        Player.Move(_move);
    }
}
