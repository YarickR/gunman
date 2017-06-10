using System.IO;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

#if UNITY_EDITOR
using UnityEditor;

public static class CreateScriptableObject
{
    public static void Create<T>() where T : ScriptableObject
    {
        T asset = ScriptableObject.CreateInstance<T>();

        string path = AssetDatabase.GetAssetPath(Selection.activeObject);
        if (path == "")
        {
            path = "Assets";
        }
        else if (Path.GetExtension(path) != "")
        {
            path = path.Replace(Path.GetFileName(AssetDatabase.GetAssetPath(Selection.activeObject)), "");
        }

        string assetPathAndName = AssetDatabase.GenerateUniqueAssetPath(path + "/New " + typeof(T).ToString() + ".asset");

        AssetDatabase.CreateAsset(asset, assetPathAndName);
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
        EditorUtility.FocusProjectWindow();
        Selection.activeObject = asset;
    }
}
#endif

public class PlayerParams : ScriptableObject
{
    [Range(0.0f, 360.0f)]
    public float RangeOfView;

    [Header("RPG Health params")]
    public float MaxHealth;

    [Range(0.0f, 1.0f)]
    public float HealthStepDecreasePercent;
    [Range(0.0f, 1.0f)]
    public float HealthMoveSpeedDecreasePercentPerStep;
    [Range(0.0f, 1.0f)]
    public float HealthRotateSpeedDecreasePercentPerStep;
    [Range(0.0f, 1.0f)]
    public float HealthLootDecreasePercentPerStep;

    [Header("RPG Move params")]
    public float baseMoveSpeed;
    public float baseRotateSpeed;

    [Header("RPG interact speed")]
    [Range(0.0f, 30.0f)]
    public float basePickUpTime;

#if UNITY_EDITOR
    [MenuItem("RPGParams/Params/Create player params", false, 100)]
    public static void CreatePlayerParams()
    {
        CreateScriptableObject.Create<PlayerParams>();
    }
#endif
}
