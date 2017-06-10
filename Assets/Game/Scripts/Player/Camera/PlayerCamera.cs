using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityStandardAssets.Cameras;

[ExecuteInEditMode]
public class PlayerCamera : MonoBehaviour
{
    public static PlayerCamera instance;

    public Camera cam;
    public Transform Target;

    public Vector3 TargetOffset;

    private void Awake()
    {
        instance = this;
    }

    public void Update()
    {
        if (Target != null)
        {
            transform.position = Target.position + TargetOffset;
        }
    }

    public void SetFollowTransform(Transform targetTransform)
    {
        Target = targetTransform;
    }
}
