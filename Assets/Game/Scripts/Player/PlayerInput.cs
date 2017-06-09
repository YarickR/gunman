using UnityEngine;
public class PlayerInput : MonoBehaviour
{
    public virtual Vector2 GetMoveDirection() { return Vector2.one; }
    public virtual Vector2 GetLookDirection() { return Vector2.one; }
}