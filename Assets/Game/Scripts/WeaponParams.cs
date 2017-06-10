using System.Collections;
using System.Collections.Generic;
using UnityEngine;

#if UNITY_EDITOR
using UnityEditor;
#endif

public class WeaponParams : ScriptableObject
{
    public float Damage;

    [Header("Targeting params")]
    [Range(0.0f, 30.0f)]
    public float StartFireDelay;

    [Range(0.0f, 180.0f)]
    public float RangeOfAiming;

    [Range(0.0f, 100.0f)]
    public float FireDistance;

    [Range(0.0f, 1.0f)]
    public float DropTargetPercent;

    [Header("Fire params")]
    [Range(0.0f, 10.0f)]
    public float FireRate;

    [Header("Ammo params")]
    public int ClipSize;
    public int MaxAmmo;

    [Range(0.0f, 30.0f)]
    public float ReloadTime;

    [Header("Crit params")]
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
