using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public static class ChangeSceneToMain {
    [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.BeforeSceneLoad)]
    static void ChangeSceneAutomatically()
    {
        SceneManager.LoadScene(0);
    }
}
