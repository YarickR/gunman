using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WeaponsList : MonoBehaviour
{
    private static string RESOURCES_NAME = "WeaponParamsList";

    private static WeaponsList _instance = null;
    public static WeaponsList Instance
    {
        get
        {
            if (_instance == null)
            {
                var prefab = Resources.Load<GameObject>(RESOURCES_NAME);
                var go = GameObject.Instantiate(prefab);
                GameObject.DontDestroyOnLoad(go);
                _instance = go.GetComponent<WeaponsList>();
            }

            return _instance;
        }
    }

    public List<WeaponParams> allWeaponParams;

    public WeaponParams GetParamsByID(int weaponId)
    {
        for (int i = 0; i < allWeaponParams.Count; ++i)
        {
            if (allWeaponParams[i].WeaponId == weaponId)
            {
                return allWeaponParams[i];
            }
        }

        return null;
    }

}
