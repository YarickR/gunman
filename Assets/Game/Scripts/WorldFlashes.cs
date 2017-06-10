using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WorldFlashes : Singleton<WorldFlashes>
{
    private List<MuzzleFlash> _cache = new List<MuzzleFlash>();

    private GameObject _prefabSrc;

    public void Return(MuzzleFlash flash)
    {
        _cache.Add(flash);
    }

    public void ShowFire(Vector3 position)
    {
        var flash = GetFlash(position);
        flash.Flash();
    }

    private MuzzleFlash GetFlash(Vector3 position)
    {
        MuzzleFlash result = null;

        if (_cache.Count > 0)
        {
            result = _cache[0];
            result.transform.position = position;
            _cache.RemoveAt(0);
        }

        if (result == null)
        {
            if (_prefabSrc == null)
            {
                _prefabSrc = Resources.Load(MuzzleFlash.SHOT_PREFAB_PATH) as GameObject;
            }

            var obj = GameObject.Instantiate(_prefabSrc, position, Quaternion.identity, this.transform) as GameObject;
            result = obj.GetComponent<MuzzleFlash>();
        }

        return result;
    }
}
