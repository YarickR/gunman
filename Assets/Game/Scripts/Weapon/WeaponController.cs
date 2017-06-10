using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WeaponController : MonoBehaviour
{
    public PlayerController playerController;

    public WeaponParams weaponParams;

    private Targetable _lastTarget = null;
    private float _currentAimProcent;

    private bool _isFirstEmptyTarget = false;

    private void Update()
    {
        UpdateAiming();

        UpdateFire();
    }

    private void UpdateAiming()
    {
        var currentTarget = playerController.LineOfSights.CurrentTarget;
        if (_lastTarget == currentTarget)
        {
            if (_currentAimProcent >= 1.0f)
            {
                return;
            }

            _currentAimProcent += Time.deltaTime / weaponParams.StartFireDelay;
            _currentAimProcent = Mathf.Clamp01(_currentAimProcent);
        }

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
            _isFirstEmptyTarget = true;
        }
    }

    private void UpdateFire()
    {
        if (_currentAimProcent < 1.0f)
        {
            return;
        }
    }
}
