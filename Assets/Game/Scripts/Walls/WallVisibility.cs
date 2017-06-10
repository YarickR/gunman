using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WallVisibility : MonoBehaviour {
    static HashSet<WallVisibility> s_allWalls = new HashSet<WallVisibility>();

    public Material NormalMaterial;
    public Material TransparentMaterial;

    bool isTransparent;

    Renderer _renderer;

    public static IEnumerable<WallVisibility> All
    {
        get { return s_allWalls; }
    }

    void Awake()
    {
        _renderer = GetComponent<Renderer>();
    }

	// Use this for initialization
	void Start () {
	}

    public void SetTransparent()
    {
        if (!isTransparent)
        {
            _renderer.sharedMaterial = TransparentMaterial;
            isTransparent = true;
        }
    }

    public void SetOpaque()
    {
        if (isTransparent)
        {
            _renderer.sharedMaterial = NormalMaterial;
            isTransparent = false;
        }
    }

    void OnEnable()
    {
        s_allWalls.Add(this);
    }

    void OnDisable()
    {
        s_allWalls.Remove(this);
    }
}
