using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityStandardAssets.Cameras;

public class PlayerCamera : MonoBehaviour
{
    public static PlayerCamera instance;

    public Camera cam;
    public AutoCam autoCam;

    private void Awake()
    {
        instance = this;
    }

    public void SetFollowTransform(Transform targetTransform)
    {
        autoCam.SetTarget(targetTransform);
    }
}
