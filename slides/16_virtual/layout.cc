struct Pawn {
    int m_Id;
    bool m_IsAlive;
    int m_HP;
} p;

struct Player : Pawn {
    const char* m_Name;
    int m_Score;
} pp;

struct Enemy {
    int m_Damage;
} e;

struct EnemyPawn : Pawn, Enemy {
    int m_TargetId;
} ep1;

struct EnemyPlayer : Player, EnemyPawn {
    int m_Karma;
} ep2;

int main()
{
    static_assert(alignof(bool) == 1, "bool alignment must be 1");
    return p.m_HP + pp.m_Score + e.m_Damage + ep1.m_TargetId + ep2.m_Karma;
}

