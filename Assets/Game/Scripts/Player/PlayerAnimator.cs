using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerAnimator : MonoBehaviour
{
    private static int IS_MOVE = Animator.StringToHash("IsMove");
    private static int MOVE_ANGLE_FROM_VIEW = Animator.StringToHash("MoveAngleFromView");
    private static int IS_DEAD = Animator.StringToHash("IsDead");
    private static int IS_RELOADING = Animator.StringToHash("IsReloading");

    private static int RELOAD_LAYER_INDEX = 1;

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

    public void SetReloadingState(bool value)
    {
        animator.SetBool(IS_RELOADING, value);
        animator.SetLayerWeight(RELOAD_LAYER_INDEX, value ? 1.0f : 0.0f);
    }
}
