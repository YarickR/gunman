using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Targeter : MonoBehaviour {
    public float VisibilityMaxDistance = 10;
    public float VisibilityAngle = 45.0f;

    public float TargetMaxDistance = 5;
    public float TargetAngle = 15.0f;

    public LineRenderer VisibleLineRendererPrefab;
    public LineRenderer TargetLineRendererPrefab;

    LineRenderer visibleLineRenderer;
    LineRenderer targetLineRenderer;

    void Awake()
    {
        instantiateDebugLines();
    }

    private void instantiateDebugLines()
    {
        if (VisibleLineRendererPrefab != null)
        {
            visibleLineRenderer = Instantiate(VisibleLineRendererPrefab);
            visibleLineRenderer.positionCount = 3;
        }

        if (TargetLineRendererPrefab != null)
        {
            targetLineRenderer = Instantiate(TargetLineRendererPrefab);
            targetLineRenderer.positionCount = 3;
        }
    }
    
    void Update()
    {
        CheckForTargets();

        drawDebugLines();
    }

    void drawDebugLines()
    {
        Vector3 floorOffset = 0.1f * Vector3.up;
        if (visibleLineRenderer != null)
        {
            var visibilityForward = VisibilityMaxDistance * transform.forward;
            visibleLineRenderer.SetPosition(0, transform.position + floorOffset);
            visibleLineRenderer.SetPosition(1, transform.position + Quaternion.Euler(0, VisibilityAngle / 2, 0) * visibilityForward + floorOffset);
            visibleLineRenderer.SetPosition(2, transform.position + Quaternion.Euler(0, -VisibilityAngle / 2, 0) * visibilityForward + floorOffset);
        }
        if (targetLineRenderer != null)
        {
            var targetForward = TargetMaxDistance * transform.forward;
            targetLineRenderer.SetPosition(0, transform.position + floorOffset);
            targetLineRenderer.SetPosition(1, transform.position + Quaternion.Euler(0, TargetAngle / 2, 0) * targetForward + floorOffset);
            targetLineRenderer.SetPosition(2, transform.position + Quaternion.Euler(0, -TargetAngle / 2, 0) * targetForward + floorOffset);
        }
    }

    void OnDrawGizmos()
    {
        Gizmos.color = Color.blue;

        var visibilityForward = VisibilityMaxDistance * transform.forward;
        
        Gizmos.DrawLine(transform.position, transform.position + Quaternion.Euler(0, VisibilityAngle / 2, 0) * visibilityForward);
        Gizmos.DrawLine(transform.position, transform.position + Quaternion.Euler(0, -VisibilityAngle / 2, 0) * visibilityForward);

        Gizmos.color = Color.red;

        var targetForward = TargetMaxDistance * transform.forward;

        Gizmos.DrawLine(transform.position, transform.position + Quaternion.Euler(0, TargetAngle / 2, 0) * targetForward);
        Gizmos.DrawLine(transform.position, transform.position + Quaternion.Euler(0, -TargetAngle / 2, 0) * targetForward);
    }

    void CheckForTargets()
    {
        foreach (var targetable in Targetable.AllTargets)
        {
            var collider = targetable.Collider;

            var direction = (targetable.transform.position - transform.position).normalized;
            var rotatedDirection = new Vector3(direction.z, 0, -direction.x);

            var midPoint = targetable.transform.position;
            var leftPoint = midPoint + rotatedDirection * collider.radius;
            var rightPoint = midPoint - rotatedDirection * collider.radius;

            Debug.DrawLine(transform.position, midPoint);
            Debug.DrawLine(transform.position, leftPoint);
            Debug.DrawLine(transform.position, rightPoint);
        }
    }
}
