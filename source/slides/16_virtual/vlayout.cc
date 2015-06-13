struct Pawn {
    virtual ~Pawn() {};
    virtual void NotOverridden() {}
    virtual int Move() { return 0; }
    int m_Id;
    bool m_IsAlive;
    int m_HP;
} p;

struct Player : virtual Pawn {
    virtual ~Player() {}
    virtual int Move() override { return 42; }
    const char* m_Name;
    int m_Score;
} pp;

struct Enemy {
    virtual ~Enemy() {}
    virtual int DoDamage() { return m_Damage; }
    int m_Damage;
} e;

struct EnemyPawn : Pawn, Enemy {
    int m_TargetId;
} ep1;

struct EnemyPawnV : Pawn, Enemy {
    int m_TargetId;
} ep3;

struct EnemyPlayer : Player, EnemyPawnV {
    int m_Karma;
} ep2;

int fun(Pawn* x);

int main()
{
    static_assert(alignof(bool) == 1, "bool alignment must be 1");
    Pawn* q = new Player;
    auto x = q->Move() + fun(q);
    delete q;
    return x + p.m_HP + pp.m_Score;
}



