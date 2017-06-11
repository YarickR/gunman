using System.Collections;
using System.Collections.Generic;
using UnityEngine;

#if UNITY_EDITOR
using UnityEditor;
#endif

public enum AmmoType
{
    Knife = 0,
    Pistol = 10,
    Machinegun = 20,
    Rifle = 30,
}

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

    public ShotAnimationType FireAnimationType;

    [Header("Ammo params")]
    public AmmoType AmmoType;
    public int ClipSize;
    public int MaxAmmo;

    [Range(0.0f, 30.0f)]
    public float ReloadTime;

    [Header("Crit params")]
    [Range(0.0f, 1.0f)]
    public float CritChance;

    [Range(1.0f, 10.0f)]
    public float CritMultiplier = 1.0f;

    public GameObject InHandsModel;
    public GameObject PicablePrefab;
    public int WeaponId;

#if UNITY_EDITOR
    [MenuItem("RPGParams/Params/Create weapon params", false, 100)]
    public static void CreatePlayerParams()
    {
        CreateScriptableObject.Create<WeaponParams>();
    }
#endif
}
