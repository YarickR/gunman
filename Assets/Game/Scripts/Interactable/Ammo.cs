using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Ammo : Interactable
{
    public int backpackAmmoAdd = 10;

    public override void Interact(PlayerController player)
    {
        player.RpcAddAmmoToMainWeapon(backpackAmmoAdd);

        Destroy(this.gameObject);
    }

    public override bool CanInteract(PlayerController pc)
    {
        if (!base.CanInteract(pc))
        {
            return false;
        }

        return pc.weaponController.HaveMainWeapon;
    }
}
