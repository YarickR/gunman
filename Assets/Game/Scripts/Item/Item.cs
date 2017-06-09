using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Item : MonoBehaviour {
	public enum ItemType_e {
		Unknown, Weapon, Ammo, Health, Special	
	};
	public ItemType_e Type ;
	public float PickupDistance;
	public float PickupTime, UseTime;
	public string Name, UseableFor;
	public float Damage, Health;
	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		
	}
}
