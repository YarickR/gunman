using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class EndScreen : MonoBehaviour {
    public Text Text;

    public void SetEndStatus(bool isVictory, int place, int maxPlayers)
    {
        string text = isVictory ? "You are the villain!" : "You are dead!";
        Text.text = string.Format("{2}\nPlace: {0} of {1}", place, maxPlayers, text);
    }
}
