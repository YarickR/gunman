using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WeaponController : MonoBehaviour
{
    public PlayerController playerController;
    public Transform weaponPlaceHolder;

    private Dictionary<WeaponParams, GameObject> _cache = new Dictionary<WeaponParams, GameObject>();

    public float ReloadProgeress
    {
        get
        {
            return _reloadTime != 0.0f ? _reloadTime / _rpgParams.ReloadTime : 0.0f;
        }
    }

    public float AimProgress
    {
        get
        {
            return _currentAimProcent;
        }
    }

    private WeaponParams _rpgParams;
    private int _currentClipAmmo;
    private int _backpackAmmo;

    private GameObject _currentActiveGO = null;

    private Targetable _lastTarget = null;
    private float _currentAimProcent;

    private bool _isFirstEmptyTarget = false;

    private float _lastFireTime = 0.0f;

    private float _reloadTime = 0.0f;

    public void InitWithParams(WeaponParams rpgParams, int currentClipAmmo, int backpackAmmo)
    {
        _rpgParams = rpgParams;
        _currentClipAmmo = currentClipAmmo;
        _backpackAmmo = backpackAmmo;

        ShowModel();
    }

    private void ShowModel()
    {
        GameObject target = null;

        if (_cache.ContainsKey(_rpgParams))
        {
            target = _cache[_rpgParams];
        }
        else
        {
            target = GameObject.Instantiate(_rpgParams.InHandsModel, weaponPlaceHolder);
            target.transform.localPosition = Vector3.zero;
            target.transform.localRotation = Quaternion.identity;
            target.transform.localScale = Vector3.one;

            _cache[_rpgParams] = target;
        }

        target.SetActive(true);

        if (_currentActiveGO != null)
        {
            _currentActiveGO.SetActive(false);
        }

        _currentActiveGO = target;
    }

    private void Update()
    {
        if (playerController == null || _rpgParams == null)
        {
            return;
        }

        UpdateAiming();

        UpdateFire();

        UpdateReload();
    }

    private void UpdateAiming()
    {
        var currentTarget = playerController.LineOfSights.CurrentTarget;

        if (_lastTarget == currentTarget && currentTarget != null)
        {
            if (_currentAimProcent >= 1.0f)
            {
                return;
            }

            //calc aim speed
            var aimSpeedFactor = 1.0f;
            if (playerController.IsMoving)
            {
                aimSpeedFactor = aimSpeedFactor - playerController.rpgParams.MoveAimSlowFactor;
            }

            var aimValue = Time.deltaTime * aimSpeedFactor;
            if (aimValue <= 0.0f)
            {
                return;
            }

            _isFirstEmptyTarget = true;
            _currentAimProcent += aimValue / _rpgParams.StartFireDelay;
            _currentAimProcent = Mathf.Clamp01(_currentAimProcent);
			playerController.UpdateTimer(_currentAimProcent, 1.0f);
            return;
        }

        //lose target/change target
        if (_lastTarget != null && currentTarget == null)
        {
            if (_isFirstEmptyTarget)
            {
                _isFirstEmptyTarget = false;
                _currentAimProcent = _currentAimProcent * _rpgParams.DropTargetPercent;
            }

            _currentAimProcent -= Time.deltaTime / _rpgParams.StartFireDelay;
            _currentAimProcent = Mathf.Clamp01(_currentAimProcent);
        }
        else if (_lastTarget == null && currentTarget == null)
        {
            _currentAimProcent -= Time.deltaTime / _rpgParams.StartFireDelay;
            _currentAimProcent = Mathf.Clamp01(_currentAimProcent);
        }
        else if (_lastTarget != null && currentTarget != null)
        {
            _currentAimProcent = 0.0f;
        }

        if (currentTarget != null)
        {
            _lastTarget = currentTarget;
        }
        playerController.UpdateTimer(_currentAimProcent, 1.0f);
    }

    private void UpdateFire()
    {
        if (_currentAimProcent < 1.0f)
        {
            return;
        }

        if (_currentClipAmmo == 0)
        {
            return;
        }

        var fireRate = 1.0f / _rpgParams.FireRate;
        if (_lastFireTime + fireRate > Time.time)
        {
            return;
        }

        Shoot();
    }

    private void Shoot()
    {
        var critRoll = Random.Range(0.0f, 1.0f);
        var isCrit = _rpgParams.CritChance > critRoll;

        var damage = isCrit ? _rpgParams.Damage * _rpgParams.CritMultiplier : _rpgParams.Damage;

        _currentClipAmmo -= 1;
        playerController.CmdSendDamageToPlayer(damage, _lastTarget.PlayerController.netId);

        _lastFireTime = Time.time;

		if (playerController.muzzleFlash != null) {
        	playerController.muzzleFlash.Flash();
        } else {
        	Debug.Log("No muzzle flash instantiated");
        }

    }

    private void UpdateReload()
    {
        if (_currentClipAmmo > 0)
        {
            return;
        }

        if (_backpackAmmo <= 0)
        {
            return;
        }

        if (_reloadTime < _rpgParams.ReloadTime)
        {
            _reloadTime += Time.deltaTime;
        }
        else
        {
            _reloadTime = 0.0f;

            if (_backpackAmmo >= _rpgParams.ClipSize)
            {
                _currentClipAmmo = _rpgParams.ClipSize;
                _backpackAmmo -= _rpgParams.ClipSize;
            }
            else
            {
                _currentClipAmmo = _backpackAmmo;
                _backpackAmmo = 0;
            }

            //Debug.Log("Finish reload!");
        }
    }
}
