using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayAnimationOnEnable : MonoBehaviour
{
    public Animation animationController;

    private void OnEnable()
    {
        if (animationController != null)
        {
            animationController.Play();
        }
    }
}
