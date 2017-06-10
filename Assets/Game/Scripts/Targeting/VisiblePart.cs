using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class VisiblePart : MonoBehaviour
{
    private Renderer[] renderers;

    private void Awake()
    {
        renderers = GetComponentsInChildren<Renderer>(true);
    }

    public void SetVisible(bool value)
    {
        for (int i = 0, l = renderers.Length; i < l; ++i)
        {
            renderers[i].enabled = value;
        }
    }
}
