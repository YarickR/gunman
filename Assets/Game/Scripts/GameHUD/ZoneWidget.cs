using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ZoneWidget : MonoBehaviour
{
    private enum ZoneState
    {
        Wait,
        Movihg,
    }

    public Slider progressSlider;
    public Text timeToStartZone;

    private ZoneState _currentState = ZoneState.Wait;
    private int _currentStateIndex;

    private FireSystemStep[] _steps = null;
    private double _serverStartTime = 0;

    private float _serverTimeDelta = 0;
    private float _targetTime = 0;
    private List<float> _stepTimings = new List<float>();
    private Dictionary<int, ZoneState> _stepState = new Dictionary<int, ZoneState>();

    private void Update()
    {
        if (_steps == null)
        {
            return;
        }

        var targetTime = Time.time - _serverTimeDelta;
        var newStateIndex = _currentStateIndex;
        for (int i = _currentStateIndex; i < _stepTimings.Count; ++i)
        {
            if (_stepTimings[i] > targetTime)
            {
                newStateIndex = i;
                break;
            }
        }

        if (newStateIndex != _currentStateIndex)
        {
            _currentStateIndex = newStateIndex;

            StopAllCoroutines();
            var state = _stepState[_currentStateIndex];

            switch (state)
            {
                case ZoneState.Movihg:
                    StartCoroutine(StartProgress(_stepTimings[_currentStateIndex], _stepTimings[_currentStateIndex - 1], targetTime));
                    break;

                case ZoneState.Wait:
                default:
                    StartCoroutine(StartTimer(_stepTimings[_currentStateIndex] - targetTime));
                    break;
            }

            SetState(state);
        }
    }

    private void OnEnable()
    {
        SetState(_currentState);
    }

    private void OnDisable()
    {
        _steps = null;
        _serverStartTime = 0;
        _serverTimeDelta = 0;
        _currentState = ZoneState.Wait;

        StopAllCoroutines();
    }

    public void SetFireSystemData(FireSystemStep[] steps, double serverStartTime)
    {
        _steps = steps;
        _serverStartTime = serverStartTime;

        _serverTimeDelta = Time.time - System.Convert.ToSingle(Network.time - _serverStartTime);

        _stepTimings.Clear();
        _stepState.Clear();
        _currentStateIndex = 0;
        for (int i = 0; i < steps.Length; ++i)
        {
            var stepStartTime = steps[i].StartTime;
            _stepTimings.Add(stepStartTime);
            _stepState[i * 2] = ZoneState.Wait;

            _stepTimings.Add(stepStartTime + steps[i].Duration);
            _stepState[(i * 2) + 1] = ZoneState.Movihg;
        }
    }

    private void SetState(ZoneState state)
    {
        _currentState = state;

        switch (state)
        {
            case ZoneState.Movihg:
                progressSlider.gameObject.SetActive(true);
                timeToStartZone.gameObject.SetActive(false);
                break;

            case ZoneState.Wait:
            default:
                progressSlider.gameObject.SetActive(false);
                timeToStartZone.gameObject.SetActive(true);
                break;
        }

    }

    private IEnumerator StartTimer(float totalSeconds)
    {
        float secondsOverall = totalSeconds;

        while (secondsOverall > 0.0f)
        {
            int minutes = (int)secondsOverall / 60;
            int seconds = (int)secondsOverall % 60;

            timeToStartZone.text = string.Format("{0}:{1}", minutes, seconds);
            yield return new WaitForSeconds(0.5f);
            secondsOverall -= 0.5f;
        }
    }

    private IEnumerator StartProgress(float endSecond, float startSeconds, float currentSeconds)
    {
        var currentSecondsInInterval = currentSeconds - startSeconds;
        var overallSeconds = endSecond - startSeconds;
        progressSlider.value = Mathf.Clamp01(currentSecondsInInterval / overallSeconds);

        while (currentSecondsInInterval > 0.0f)
        {
            yield return new WaitForSeconds(0.5f);

            currentSecondsInInterval -= 0.5f;

            progressSlider.value = Mathf.Clamp01(currentSecondsInInterval / overallSeconds);
        }
    }
}
