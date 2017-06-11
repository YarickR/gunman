using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WeaponView : MonoBehaviour
{
    public MuzzleFlash muzzle;
    public int currentClipAmmo;
    public int backpackAmmo;

    public void FireVisual()
    {
        muzzle.Flash();
    }
}
