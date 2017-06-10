using System.Collections;
using System.Collections.Generic;
using UnityEngine;

#if UNITY_EDITOR
using UnityEditor;
#endif

public class WeaponParams : ScriptableObject
{
    [Range(0.0f, 30.0f)]
    public float StartFireDelay;

    [Range(0.0f, 180.0f)]
    public float RangeOfAiming;

    [Range(0.0f, 100.0f)]
    public float FireDistance;

    [Range(0.0f, 10.0f)]
    public float FireRate;

    public float ClipSize;
    public float MaxAmmo;
    public float Damage;

    [Range(0.0f, 30.0f)]
    public float ReloadSpeed;

    [Range(0.0f, 1.0f)]
    public float CritChance;

    [Range(1.0f, 10.0f)]
    public float CritMultiplier = 1.0f;

#if UNITY_EDITOR
    [MenuItem("RPGParams/Params/Create weapon params", false, 100)]
    public static void CreatePlayerParams()
    {
        CreateScriptableObject.Create<WeaponParams>();
    }
#endif
}
