using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WeaponController : MonoBehaviour
{
    public PlayerController playerController;

    public WeaponParams weaponParams;

    public float ReloadProgeress
    {
        get
        {
            return _reloadTime != 0.0f ? _reloadTime / weaponParams.ReloadTime : 0.0f;
        }
    }

    public float AimProgress
    {
        get
        {
            return _currentAimProcent;
        }
    }

    private int _currentClipAmmo;
    private int _backpackAmmo;

    private Targetable _lastTarget = null;
    private float _currentAimProcent;

    private bool _isFirstEmptyTarget = false;

    private float _lastFireTime = 0.0f;

    private float _reloadTime = 0.0f;

    public void Init(int currentClipAmmo, int backpackAmmo)
    {
        _currentClipAmmo = currentClipAmmo;
        _backpackAmmo = backpackAmmo;
        _currentAimProcent = 0.0f;
    }

    private void Update()
    {
        if (playerController == null)
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

            _isFirstEmptyTarget = true;
            _currentAimProcent += Time.deltaTime / weaponParams.StartFireDelay;
            _currentAimProcent = Mathf.Clamp01(_currentAimProcent);
            return;
        }

        //lose target/change target
        if (_lastTarget != null && currentTarget == null)
        {
            if (_isFirstEmptyTarget)
            {
                _isFirstEmptyTarget = false;
                _currentAimProcent = _currentAimProcent * weaponParams.DropTargetPercent;
            }

            _currentAimProcent -= Time.deltaTime / weaponParams.StartFireDelay;
            _currentAimProcent = Mathf.Clamp01(_currentAimProcent);
        }
        else if (_lastTarget == null && currentTarget == null)
        {
            _currentAimProcent -= Time.deltaTime / weaponParams.StartFireDelay;
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

        var fireRate = 1.0f / weaponParams.FireRate;
        if (_lastFireTime + fireRate > Time.time)
        {
            return;
        }

        Shoot();
    }

    private void Shoot()
    {
        var critRoll = Random.Range(0.0f, 1.0f);
        var isCrit = weaponParams.CritChance > critRoll;

        var damage = isCrit ? weaponParams.Damage * weaponParams.CritMultiplier : weaponParams.Damage;

        _currentClipAmmo -= 1;
        _lastTarget.PlayerController.CmdSendDamageToServer(damage);

        _lastFireTime = Time.time;

        //Debug.Log("Fire!");
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

        if (_reloadTime < weaponParams.ReloadTime)
        {
            _reloadTime += Time.deltaTime;
        }
        else
        {
            _reloadTime = 0.0f;

            if (_backpackAmmo >= weaponParams.ClipSize)
            {
                _currentClipAmmo = weaponParams.ClipSize;
                _backpackAmmo -= weaponParams.ClipSize;
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
