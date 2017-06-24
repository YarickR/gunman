using System;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

[RequireComponent(typeof(MeshFilter))]
[RequireComponent(typeof(MeshRenderer))]

public class LineOfSight : MonoBehaviour
{
    //////////////////////////
    /// PROPERTIES
    //////////////////////////
    
    [Header("Common Settings")]
    [SerializeField, RangeAttribute(1, 10), Tooltip("Quality of raycasting, better quality reduce performance")]
    private int _quality = 4;
    [SerializeField, RangeAttribute(1, 361), Tooltip("Maximum angle of viewing area")] 
    private int _maxAngle = 90;
    [SerializeField, Tooltip("Maximum viewing distance")]
    private float _maxDistance = 15;
    [SerializeField, Tooltip("Layers of objects which are not transparent for viewing")]
    private LayerMask _cullingMask = -1;

    [Header("Materials")]
    [SerializeField, Tooltip("Material")]
    private Material Material;

    [SerializeField, Tooltip("Turn on to display rays in editor window")]
    private bool _displayRaysInEditor = false;

    //////////////////////////
    /// PUBLIC METHODS
    //////////////////////////
    /// 
    ///

    public float MaxAngle {
        get
        {
            return _maxAngle;
        }

        set
        {
            _maxAngle = (int)value;
        }
    }

    public float MaxDistance {
        get
        {
            return _maxDistance;
        }

        set
        {
            _maxDistance = value;
        }
    }

    /// <summary>
    /// Automatic check based on tag.
    /// </summary>
    /// <param name="tagName">Name of tag to check</param>
    /// <returns>True if viewer sees anything with given tag, otherwise false</returns>
    public bool SeeByTag(string tagName)
    {
        return _hits.Any(hit => hit.transform && hit.transform.tag == tagName);
    }

    /// <summary>
    /// Manual check of what the viewer sees.
    /// </summary>
    /// <param name="function">Method which returns true if a ray collides with an appropriate object</param>
    /// <returns>True if something appropriate was seen, otherwise false</returns>
    public bool SeeByFunction(Func<RaycastHit, bool> function)
    {
        return _hits.Any(function);
    }
       
    //////////////////////////
    /// INTERNALS
    //////////////////////////

    private List<RaycastHit> _hits;
    private MeshRenderer _meshRenderer;
    private Vector3[] _vertices;
    private int[] _triangles;
    private Mesh _mesh;
    private Transform _transform;

    private void Start()
    {
        _hits = new List<RaycastHit>();
        _mesh = GetComponent<MeshFilter>().mesh;
        _meshRenderer = GetComponent<MeshRenderer>();
        _meshRenderer.material = Material;
        _transform = this.transform;
    }

    private void Update()
    {
        CastRays();
    }

    private void LateUpdate()
    {
        UpdateMesh();
    }

    private void OnDrawGizmosSelected()
    {
        if (!_displayRaysInEditor || !_hits.Any()) return;

        Gizmos.color = Color.cyan;
        foreach (RaycastHit hit in _hits)
        {
            Gizmos.DrawSphere(hit.point, 0.04f);
            Gizmos.DrawLine(transform.position, hit.point);
        }
    }

    private void CastRays()
    {
        int numberOfRays = _maxAngle*_quality;
        float currentAngle = _maxAngle/-2.0f;

        _hits.Clear();

        var upVector = _transform.up;
        var forwardVector = _transform.forward;

        for (int i = 0; i < numberOfRays; i++)
        {
            Vector3 direction = Quaternion.AngleAxis(currentAngle, upVector) * forwardVector;
            RaycastHit hit;

            if (Physics.Raycast(_transform.position, direction, out hit, _maxDistance, _cullingMask) == false)
            {
                hit.point = _transform.position + (direction * _maxDistance);
            }

            _hits.Add(hit);
            currentAngle += 1f/_quality;
        }
    }

    private void UpdateMesh()
    {
        if (_hits == null || _hits.Count == 0)
            return;

        if (_mesh.vertices.Length != _hits.Count + 1)
        {
            _mesh.Clear();

            _vertices = new Vector3[_hits.Count + 1];
            _triangles = new int[(_hits.Count - 1)*3];

            int sideIndex = 1;
            for (int i = 0; i < _triangles.Length; i += 3)
            {
                _triangles[i] = 0;
                _triangles[i + 1] = sideIndex;
                _triangles[i + 2] = sideIndex + 1;
                sideIndex++;
            }
        }

        _vertices[0] = Vector3.zero;
        for (int i = 1; i <= _hits.Count; i++)
        {
            _vertices[i] = transform.InverseTransformPoint(_hits[i - 1].point);
        }

        var uv = new Vector2[_vertices.Length];
        for (int i = 0; i < uv.Length; i++)
        {
            uv[i] = new Vector2(_vertices[i].x, _vertices[i].z);
        }

        _mesh.vertices = _vertices;
        _mesh.triangles = _triangles;
        _mesh.uv = uv;

        _mesh.RecalculateNormals();
        _mesh.RecalculateBounds();
    }
}