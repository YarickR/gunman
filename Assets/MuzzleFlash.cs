using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MuzzleFlash : MonoBehaviour {
    public static string SHOT_PREFAB_PATH = "MuzzleFlashShot";

    public bool needReturnToCache = false;

    public float showTime = 0.1f;

	private float _flashStart;

	public void Flash()
    {
		_flashStart = Time.time;
		gameObject.SetActive(true);
	}

	void Update ()
    {
		if (_flashStart > 0)
        {
            if ((Time.time - _flashStart) > showTime)
            { 
				gameObject.SetActive(false);
				_flashStart = 0;

                if (needReturnToCache)
                {

                }
			} 
		}
	}
}
