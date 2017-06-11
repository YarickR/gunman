using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WeaponController : MonoBehaviour
{
    public PlayerController playerController;
    public Transform weaponPlaceHolder;

    private Dictionary<WeaponParams, GameObject> _cache = new Dictionary<WeaponParams, GameObject>();

    public int GetBackpackAmmo
    {
        get
        {
            if (_mainWeaponView == null)
            {
                return 0;
            }

            return _mainWeaponView.backpackAmmo;
        }
    }

    public int GetCurrentAmmo
    {
        get
        {
            if (_mainWeaponView == null)
            {
                return 0;
            }

            return _mainWeaponView.currentClipAmmo;
        }
    }

    public bool HaveMainWeapon
    {
        get
        {
            return _mainWeaponRpgParams != null;
        }
    }

    public bool IsReloading
    {
        get
        {
            return _reloadTime > 0.0f;
        }
    }

    public bool IsCanFire { get; set; }

    public float ReloadProgeress
    {
        get
        {
            return _reloadTime != 0.0f ? _reloadTime / _mainWeaponRpgParams.ReloadTime : 0.0f;
        }
    }

    public float AimProgress
    {
        get
        {
            return _currentAimProcent;
        }
    }

    private WeaponParams _baseWeaponRpgParams;
    private WeaponView _baseWeaponView;

    private WeaponParams _mainWeaponRpgParams;
    private WeaponView _mainWeaponView;

    //only for change
    private WeaponParams _lastSet;

    private GameObject _currentActiveGO = null;

    private Targetable _lastTarget = null;
    private float _currentAimProcent;

    private bool _isFirstEmptyTarget = false;

    private float _lastFireTime = 0.0f;

    private float _reloadTime = 0.0f;

    //+++++ net
    public void InitWithParams(WeaponParams rpgParams, int currentClipAmmo, int backpackAmmo)
    {
        IsCanFire = true;

        ShowModel(rpgParams);

        WeaponView targetView;
        if (rpgParams == playerController.rpgParams.StartWeapon)
        {
            _baseWeaponRpgParams = rpgParams;
            _baseWeaponView = _currentActiveGO.GetComponent<WeaponView>();
            targetView = _baseWeaponView;
        }
        else
        {
            _mainWeaponRpgParams = rpgParams;
            _mainWeaponView = _currentActiveGO.GetComponent<WeaponView>();
            targetView = _mainWeaponView;
        }

        targetView.backpackAmmo = backpackAmmo;
        targetView.currentClipAmmo = currentClipAmmo;

        _lastSet = rpgParams;
    }

    public void AddMainWeaponAmmo(int ammoCount)
    {
        if (_mainWeaponRpgParams == null)
        {
            return;
        }

        _mainWeaponView.backpackAmmo = Mathf.Min(_mainWeaponView.backpackAmmo + ammoCount, _mainWeaponRpgParams.MaxAmmo);

        TrySetMainWeapon();
    }

    public void ShowFireMuzzle()
    {
        var targetParams = GetTargetParams();
        if (targetParams == null)
        {
            return;
        }

        WeaponView targetView;
        if (targetParams == _mainWeaponRpgParams)
        {
            targetView = _mainWeaponView;
        }
        else
        {
            targetView = _baseWeaponView;
        }

        if (targetView != null && targetView.muzzle != null)
        {
            targetView.FireVisual();
        }
    }
    //----- net

    private void ShowModel(WeaponParams rpgParams)
    {
        GameObject target = null;

        if (_cache.ContainsKey(rpgParams))
        {
            target = _cache[rpgParams];
        }
        else
        {
            target = GameObject.Instantiate(rpgParams.InHandsModel, weaponPlaceHolder);
            target.transform.localPosition = Vector3.zero;
            target.transform.localRotation = Quaternion.identity;
            target.transform.localScale = Vector3.one;

            playerController.RegisterAdditionalRenderPart(target.GetComponent<VisiblePart>());

            _cache[rpgParams] = target;
        }

        if (_currentActiveGO != null)
        {
            _currentActiveGO.SetActive(false);
        }

        target.SetActive(true);
        _currentActiveGO = target;
    }

    private void Update()
    {
        if (playerController == null ||
            GetTargetParams() == null ||
            !playerController.isLocalPlayer)
        {
            return;
        }

        UpdateAiming();

        UpdateFire();

        UpdateReload();

        TrySetBaseWeapon();

        GameLogic.Instance.HUD.SetAmmo(GetCurrentAmmo, GetBackpackAmmo);
    }

    private void UpdateAiming()
    {
        var targetParams = GetTargetParams();
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
            _currentAimProcent += aimValue / targetParams.StartFireDelay;
            _currentAimProcent = Mathf.Clamp01(_currentAimProcent);
            return;
        }

        //lose target/change target
        if (_lastTarget != null && currentTarget == null)
        {
            if (_isFirstEmptyTarget)
            {
                _isFirstEmptyTarget = false;
                _currentAimProcent = _currentAimProcent * targetParams.DropTargetPercent;
            }

            _currentAimProcent -= Time.deltaTime / targetParams.StartFireDelay;
            _currentAimProcent = Mathf.Clamp01(_currentAimProcent);
        }
        else if (_lastTarget == null && currentTarget == null)
        {
            _currentAimProcent -= Time.deltaTime / targetParams.StartFireDelay;
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
        var targetParams = GetTargetParams();
        var targetView = targetParams == _baseWeaponRpgParams ? _baseWeaponView : _mainWeaponView;
        if (targetView == null)
        {
            return;
        }

        if (_currentAimProcent < 1.0f)
        {
            return;
        }

        if (targetView.currentClipAmmo == 0)
        {
            return;
        }

        var fireRate = 1.0f / targetParams.FireRate;
        if (_lastFireTime + fireRate > Time.time)
        {
            return;
        }

        if (!IsCanFire)
        {
            return;
        }

        Shoot();
    }

    private void Shoot()
    {
        var targetParams = GetTargetParams();
        var targetView = targetParams == _baseWeaponRpgParams ? _baseWeaponView : _mainWeaponView;
        if (targetView == null)
        {
            return;
        }

        var critRoll = Random.Range(0.0f, 1.0f);
        var isCrit = targetParams.CritChance > critRoll;

        var damage = isCrit ? targetParams.Damage * targetParams.CritMultiplier : targetParams.Damage;

        targetView.currentClipAmmo -= 1;
        playerController.CmdSendDamageToPlayer(damage, _lastTarget.PlayerController.netId, (int)targetParams.FireAnimationType);

        _lastFireTime = Time.time;

    }

    private void UpdateReload()
    {
        var targetParams = GetTargetParams();
        var targetView = targetParams == _baseWeaponRpgParams ? _baseWeaponView : _mainWeaponView;
        if (targetView == null)
        {
            return;
        }

        if (targetView.currentClipAmmo > 0)
        {
            return;
        }

        if (targetView.backpackAmmo  <= 0)
        {
            return;
        }

        if (_reloadTime < targetParams.ReloadTime)
        {
            _reloadTime += Time.deltaTime;
        }
        else
        {
            _reloadTime = 0.0f;

            if (targetView.backpackAmmo >= targetParams.ClipSize)
            {
                targetView.currentClipAmmo = targetParams.ClipSize;
                targetView.backpackAmmo -= targetParams.ClipSize;
            }
            else
            {
                targetView.currentClipAmmo = targetView.backpackAmmo;
                targetView.backpackAmmo = 0;
            }

            //Debug.Log("Finish reload!");
        }
    }

    private void TrySetBaseWeapon()
    {
        if (GetTargetParams() == _baseWeaponRpgParams && _baseWeaponRpgParams != _lastSet)
        {
            playerController.CmdSetWeapon(_baseWeaponRpgParams.WeaponId, _baseWeaponRpgParams.ClipSize, _baseWeaponRpgParams.MaxAmmo);
        }
    }

    private void TrySetMainWeapon()
    {
        if (GetTargetParams() == _mainWeaponRpgParams && _mainWeaponRpgParams != _lastSet)
        {
            playerController.CmdSetWeapon(_mainWeaponRpgParams.WeaponId, _mainWeaponView.currentClipAmmo, _mainWeaponView.backpackAmmo);
        }
    }

    private WeaponParams GetTargetParams()
    {
        if (_mainWeaponRpgParams != null &&
            (_mainWeaponView.currentClipAmmo > 0 ||
            _mainWeaponView.backpackAmmo > 0))
        {
            return _mainWeaponRpgParams;
        }

        return _baseWeaponRpgParams;
    }
}
