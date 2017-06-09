using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerAnimator : MonoBehaviour
{
    private static int IS_MOVE = Animator.StringToHash("IsMove");
    private static int MOVE_ANGLE_FROM_VIEW = Animator.StringToHash("MoveAngleFromView");
    private static int IS_DEAD = Animator.StringToHash("IsDead");

    public Animator animator;

    public void SetMoveState(bool value)
    {
        animator.SetBool(IS_MOVE, value);
    }

    public void SetMoveAngleFromView(float value)
    {
        animator.SetFloat(MOVE_ANGLE_FROM_VIEW, value);
    }

    public void SetDeadState(bool value)
    {
        animator.SetBool(IS_DEAD, value);
    }
}
