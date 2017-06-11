using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HitEffect : MonoBehaviour {
    public float Duration = 0.1f;

    float startTime;
	// Use this for initialization
	void Start () {
        startTime = Time.time;
        var rotation = transform.rotation;
        rotation = Quaternion.Euler(0, Random.Range(0, 360), 0) * rotation;
        transform.rotation = rotation;
	}

    void Update()
    {
        if (Time.time - startTime > Duration)
        {
            DestroyHit();
        }
    }

    public void DestroyHit()
    {
        Destroy(gameObject);
    }
}
