using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ZoneWidget : MonoBehaviour
{
    public Slider progressSlider;
    public Text timeToStartZone;

    private ZoneState _currentState = ZoneState.Wait;

    private void OnEnable()
    {
        SetState(_currentState);
    }

    private void OnDisable()
    {
        _currentState = ZoneState.Wait;
        StopAllCoroutines();
    }

    public void SetFireSystemData(float startTime, float endTime, ZoneState state)
    {
        StopAllCoroutines();

        switch (state)
        {
            case ZoneState.Movihg:
                StartCoroutine(StartProgress(endTime, startTime));
                break;

            case ZoneState.Wait:
            default:
                StartCoroutine(StartTimer(endTime - startTime));
                break;
        }

        SetState(state);
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

            timeToStartZone.text = string.Format("{0}:{1:00}", minutes, seconds);
            yield return new WaitForSeconds(0.5f);
            secondsOverall -= 0.5f;
        }
    }

    private IEnumerator StartProgress(float endSecond, float startSeconds)
    {
        var overallSeconds = endSecond - startSeconds;
        var currTime = 0.0f;

        while (currTime <= overallSeconds)
        {
            currTime += Time.deltaTime;
            var currentInterval = currTime / overallSeconds;
            progressSlider.value = Mathf.Clamp01(currentInterval);

            yield return null;
        }

        progressSlider.value = 1f;
    }
}
