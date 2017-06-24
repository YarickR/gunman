using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

#if UNITY_EDITOR
using UnityEditor;
#endif

[Serializable]
public class BaseContainerElement
{
    public int weight;
    public Interactable target;
}

public class ContainerParams : ScriptableObject
{
    [Header("Empty element weight")]
    public int emptyDropWeight;

    [Header("Content map")]
    public List<BaseContainerElement> elements = new List<BaseContainerElement>();

    public Interactable Roll()
    {
        int overallWeight = emptyDropWeight;
        for (int i = 0; i < elements.Count; ++i)
        {
            overallWeight += elements[i].weight;
        }

        int rollValue = UnityEngine.Random.Range(0, overallWeight);
        //Debug.Log(string.Format("preset:{0} Chances:{1} - {2} ", name, rollValue, overallWeight));

        for (int i = 0; i < elements.Count; ++i)
        {
            rollValue -= elements[i].weight;
            if (rollValue < 0)
            {
                return elements[i].target;
            }
        }

        return null;
    }

#if UNITY_EDITOR
    [MenuItem("RPGParams/Params/Create container params", false, 300)]
    public static void CreatePlayerParams()
    {
        CreateScriptableObject.Create<ContainerParams>();
    }
#endif
}
