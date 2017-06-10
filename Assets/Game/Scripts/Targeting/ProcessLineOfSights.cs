using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ProcessLineOfSights : MonoBehaviour {
    public LineOfSight VisibilityLineOfSight;
    public LineOfSight TargetingLineOfSight;

    public Targetable IgnoreTarget;

    private Targetable currentTarget;
    private float currentTargetAcquireTime;

    public Targetable CurrentTarget
    {
        get { return currentTarget; }
    }

    public float TargetDuration
    {
        get { return Time.time - currentTargetAcquireTime; }
    }
	
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

        if (currentTarget != null)
        {
            Vector3 midPoint, leftPoint, rightPoint;
            calcPoints(currentTarget, out midPoint, out leftPoint, out rightPoint);
            if (!HitTestPoint(midPoint, maxTargetingDistance, maxTargetingDistanceSqr, minTargetingCosAngle, currentTarget.Collider) ||
                    HitTestPoint(leftPoint, maxTargetingDistance, maxTargetingDistanceSqr, minTargetingCosAngle, currentTarget.Collider) ||
                    HitTestPoint(rightPoint, maxTargetingDistance, maxTargetingDistanceSqr, minTargetingCosAngle, currentTarget.Collider) ||
                    currentTarget.isVisibleOnly)
            {
                updateCurrentTarget(null);
            }
        }


        Targetable candidateTarget = null;
        float sqrDistToTarget = float.MaxValue;

        foreach (var targetable in Targetable.AllTargets)
        {
            if (targetable != IgnoreTarget)
            {
                Vector3 midPoint, leftPoint, rightPoint;
                calcPoints(targetable, out midPoint, out leftPoint, out rightPoint);

                if (HitTestPoint(midPoint, maxVisibleDistance, maxVisibleDistanceSqr, minVisibleCosAngle, targetable.Collider, true) ||
                    HitTestPoint(leftPoint, maxVisibleDistance, maxVisibleDistanceSqr, minVisibleCosAngle, targetable.Collider, true) ||
                    HitTestPoint(rightPoint, maxVisibleDistance, maxVisibleDistanceSqr, minVisibleCosAngle, targetable.Collider, true))
                {
                    OnTargetVisible(targetable);

                    if (currentTarget == null && !targetable.isVisibleOnly)
                    {
                        if (HitTestPoint(midPoint, maxTargetingDistance, maxTargetingDistanceSqr, minTargetingCosAngle, targetable.Collider) ||
                        HitTestPoint(leftPoint, maxTargetingDistance, maxTargetingDistanceSqr, minTargetingCosAngle, targetable.Collider) ||
                        HitTestPoint(rightPoint, maxTargetingDistance, maxTargetingDistanceSqr, minTargetingCosAngle, targetable.Collider))
                        {
                            if (candidateTarget == null)
                            {
                                candidateTarget = targetable;
                            }
                            else
                            {
                                var sqrDistance = (targetable.transform.position - transform.position).sqrMagnitude;
                                if (sqrDistance < sqrDistToTarget)
                                {
                                    sqrDistToTarget = sqrDistance;
                                    candidateTarget = targetable;
                                }
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

        if (candidateTarget != null)
        {
            updateCurrentTarget(candidateTarget);
        }
    }

    void calcPoints(Targetable targetable, out Vector3 midPoint, out Vector3 leftPoint, out Vector3 rightPoint)
    {
        var direction = (targetable.transform.position - transform.position).normalized;
        var rotatedDirection = new Vector3(direction.z, 0, -direction.x);

        Vector3 heightDelta = new Vector3(0, transform.position.y, 0);

        midPoint = targetable.transform.position;
        midPoint.y = transform.position.y;
        float k = 0.95f;
        leftPoint = midPoint + k * rotatedDirection * targetable.Radius + heightDelta;
        leftPoint.y = transform.position.y;
        rightPoint = midPoint - k * rotatedDirection * targetable.Radius + heightDelta;
        rightPoint.y = transform.position.y;
    }

    void updateCurrentTarget(Targetable target)
    {
        if (currentTarget != null)
        {
            Debug.LogFormat("LOST CURRENT TARGET {0} | {1}", currentTarget != null ? currentTarget.name : null, TargetDuration);
        }
        Debug.LogFormat("CURRENT TARGET {0}", target != null ? target.name : null);
        currentTarget = target;
        currentTargetAcquireTime = Time.time;
    }

    void OnTargetVisible(Targetable target) {
        target.Visible = true;
    }

    void OnTargetInvisible(Targetable target) {
        target.Visible = false;
    }

    const int MAX_HITS = 10;
    RaycastHit[] hits = new RaycastHit[MAX_HITS];

    bool HitTestPoint(Vector3 point, float maxDistance, float maxDistanceSquared, float minCosAngle, Collider col, bool raycastAll = false) {
        var delta = point - transform.position;
        if (delta.sqrMagnitude > maxDistanceSquared)
        {
            //Debug.LogFormat("TOO FAR");
            return false;
        }

        var direction = delta.normalized;

        var forward = transform.forward;
        var cosAngle = Vector3.Dot(forward, direction);
        if (cosAngle < minCosAngle)
        {
            //Debug.LogFormat("NOT IN ANGLE");
            return false;
        }

        
        if (!raycastAll)
        {
            RaycastHit hit;

            if (Physics.Raycast(transform.position, direction, out hit, maxDistance))
            {
                return hit.collider == col;
            }
        }
        else
        {
            int hitsCount = Physics.RaycastNonAlloc(transform.position, direction, hits, maxDistance);
            //Debug.DrawRay(transform.position, delta, Color.red);

            Array.Sort<RaycastHit>(hits, 0, hitsCount, sortByHitDistanceComparer);

            //Debug.LogFormat("HITS COUNT {0}", hitsCount);
            for (int i = 0; i < hitsCount; ++i)
            {
                var hit = hits[i];

                if (hit.collider.gameObject.layer == 8)
                {
                    if (hit.collider == col)
                    {
                        return true;
                    }
                }
                else
                {
                    //Debug.LogFormat("wall hit {0}", hit.collider.name);
                    return false;
                }
            }
        }

        //Debug.LogFormat("no hit");

        return false;
    }

    static IComparer<RaycastHit> sortByHitDistanceComparer = new SortByDistanceComparer();

    public class SortByDistanceComparer : IComparer<RaycastHit>
    {
        public int Compare(RaycastHit hit1, RaycastHit hit2)
        {
            return hit1.distance.CompareTo(hit2.distance);
        }
    }
    
}
