using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Targeter : MonoBehaviour {
    public float VisibilityMaxDistance = 10;
    public float VisibilityAngle = 45.0f;

    public float TargetMaxDistance = 5;
    public float TargetAngle = 15.0f;
    
    void Update()
    {
        CheckForTargets();
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
