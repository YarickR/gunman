using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum ShotAnimationType
{
    MELEE = 0,
    RANGED = 10,
}

public class PlayerAnimator : MonoBehaviour
{
    private static int IS_MOVE = Animator.StringToHash("IsMove");
    private static int MOVE_ANGLE_FROM_VIEW = Animator.StringToHash("MoveAngleFromView");
    private static int IS_DEAD = Animator.StringToHash("IsDead");
    private static int IS_RELOADING = Animator.StringToHash("IsReloading");
    private static int TRIGGER_MELEE = Animator.StringToHash("Attack");
    private static int TRIGGER_FIRE = Animator.StringToHash("Fire");
    private static int IS_INTERACTING = Animator.StringToHash("IsInteracting");

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
    }

    public void SetShootTrigger(ShotAnimationType type)
    {
        if (type == ShotAnimationType.MELEE)
        {
            animator.SetTrigger(TRIGGER_MELEE);
        }
        else if (type == ShotAnimationType.RANGED)
        {
            animator.SetTrigger(TRIGGER_FIRE);
        }
    }

    public void SetInteractingState(bool value)
    {
        animator.SetBool(IS_INTERACTING, value);
    }
}
