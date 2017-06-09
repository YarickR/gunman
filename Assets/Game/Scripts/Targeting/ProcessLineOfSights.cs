using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ProcessLineOfSights : MonoBehaviour {
    public LineOfSight VisibilityLineOfSight;
    public LineOfSight TargetingLineOfSight;

    public Targetable IgnoreTarget;
	
	// Update is called once per frame
	void Update () {
        CheckForTargets();
	}

    void CheckForTargets()
    {
        var maxVisibleDistance = VisibilityLineOfSight.MaxDistance;
        var maxVisibleDistanceSqr = maxVisibleDistance * maxVisibleDistance;
        var minVisibleCosAngle = Mathf.Cos(VisibilityLineOfSight.MaxAngle/2 * Mathf.Deg2Rad);

        var maxTargetingDistance = TargetingLineOfSight.MaxDistance;
        var maxTargetingDistanceSqr = maxTargetingDistance * maxTargetingDistance;
        var minTargetingCosAngle = Mathf.Cos(TargetingLineOfSight.MaxAngle/2 * Mathf.Deg2Rad);

        Targetable currentTarget = null;
        float sqrDistToTarget = float.MaxValue;

        foreach (var targetable in Targetable.AllTargets)
        {
            if (targetable != IgnoreTarget)
            {
                var direction = (targetable.transform.position - transform.position).normalized;
                var rotatedDirection = new Vector3(direction.z, 0, -direction.x);

                var midPoint = targetable.transform.position;
                var leftPoint = midPoint + rotatedDirection * targetable.Radius;
                var rightPoint = midPoint - rotatedDirection * targetable.Radius;


                if (HitTestPoint(midPoint, maxVisibleDistance, maxVisibleDistanceSqr, minVisibleCosAngle, targetable.Collider) ||
                    HitTestPoint(leftPoint, maxVisibleDistance, maxVisibleDistanceSqr, minVisibleCosAngle, targetable.Collider) ||
                    HitTestPoint(rightPoint, maxVisibleDistance, maxVisibleDistanceSqr, minVisibleCosAngle, targetable.Collider))
                {
                    OnTargetVisible(targetable);

                    if (HitTestPoint(midPoint, maxTargetingDistance, maxTargetingDistanceSqr, minTargetingCosAngle, targetable.Collider) ||
                        HitTestPoint(leftPoint, maxTargetingDistance, maxTargetingDistanceSqr, minTargetingCosAngle, targetable.Collider) ||
                        HitTestPoint(rightPoint, maxTargetingDistance, maxTargetingDistanceSqr, minTargetingCosAngle, targetable.Collider))
                    {
                        if (currentTarget == null)
                        {
                            currentTarget = targetable;
                        }
                        else
                        {
                            var sqrDistance = (targetable.transform.position - transform.position).sqrMagnitude;
                            if (sqrDistance < sqrDistToTarget)
                            {
                                sqrDistToTarget = sqrDistance;
                                currentTarget = targetable;
                            }
                        }
                    }
                }
                else
                {
                    OnTargetInvisible(targetable);
                }
            }
        }

        if (currentTarget != null)
        {
       //     Debug.LogFormat("Current target {0}", currentTarget.name);
        }
    }

    void OnTargetVisible(Targetable target) {
        target.Visible = true;
    }

    void OnTargetInvisible(Targetable target) {
        target.Visible = false;
    }

    bool HitTestPoint(Vector3 point, float maxDistance, float maxDistanceSquared, float minCosAngle, Collider col) {
        var delta = point - transform.position;
        if (delta.sqrMagnitude > maxDistanceSquared)
        {
            return false;
        }

        var direction = delta.normalized;

        var forward = transform.forward;
        var cosAngle = Vector3.Dot(forward, direction);
        if (cosAngle < minCosAngle)
        {
            return false;
        }

        RaycastHit hit;

        if (Physics.Raycast(transform.position, direction, out hit, maxDistance))
        {
            return hit.collider == col;
        }
       

        return false;
    }
}
