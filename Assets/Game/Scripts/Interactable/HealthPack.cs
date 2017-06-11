using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HealthPack : Interactable
{
    public float addHealth = 10;

    public override void Interact(PlayerController player)
    {
        player.Heal(addHealth);

        Destroy(this.gameObject);
    }
}
