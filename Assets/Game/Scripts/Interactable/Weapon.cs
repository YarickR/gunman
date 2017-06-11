public class Weapon : Interactable
{
    public WeaponParams Params;
    public int ClipAmmo = 1;
    public int BackpackAmmo;

    public override void Interact(PlayerController player)
    {
        player.RpcSetWeaponById(Params.WeaponId, ClipAmmo, BackpackAmmo, false);

        Destroy(this.gameObject);
    }
}
