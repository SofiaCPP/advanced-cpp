+++ slide

# Inheritance and virtual functions

+++
+++ slide

## Contents

* Object layout
* Inheritance
* Multiple inheritance
* Virtual functions
* Virtual inheritance

+++
=== topic

+++ slide
# Object Layout
+++

+++ slide

    class Pawn {
        int m_Id;
        bool m_IsAlive;
        int m_HP;
    }

+++

+++ slide

The members of the class are laid out in the same order in memory as they are declared.

+++

+++ slide

Dumping the layout of a struct.

    clang++ -cc1 -fdump-record-layouts file.cxx

http://eli.thegreenplace.net/2012/12/17/dumping-a-c-objects-memory-layout-with-clang

+++

+++ slide

    0 | struct Pawn
    0 |   int m_Id
    4 |   _Bool m_IsAlive
    8 |   int m_HP
      | [sizeof=12, dsize=12, align=4
      |  nvsize=12, nvalign=4]

+++

+++ slide

* The digit in the first column is the offset of the member in the stuct.
* sizeof is how much the `sizeof` operator will return
* dsize is the size without the extra tail padding
* align is the alignment of the structure

+++

+++ slide

### Alignment

https://en.wikipedia.org/wiki/Data_structure_alignment

+++

+++ slide

In short - the CPU is most effective to load data at addresses that are multiple
of a 4, 8, 16, 64, etc. Therefore the compiler generates the code so that the
address of every variable is a multiple of its alignment.

+++

+++ slide

In C++11, the `alignof` operator gives the alignment of a type.

    static_assert(alignof(bool) == 1, "the alignment of bool is 1");

+++
+++ slide

* `m_IsAlive` is `bool`, size 4, alignment 1
* `m_HP` is `int` - size 4, alignment 4

The compiler must create a hole of 3 bytes in `Pawn` in order to fulfill the
alignment of `m_HP`.

+++

+++ slide

### Padding

The extra empty spaces that the compiler places inside user-defined types in
order to properly align their members.

+++

+++ slide

### Padding caveats

The padding is filled with random data. You *SHOULD* never use it.

    Pawn p1, p2;
    
    if (std::memcmp(&p1, &p2, sizeof(p1)))

This will take the 3 random bytes in `p1` and `p2` into the comparison and might
return that they are different, although all of their data members are actually
equal.

+++


+++

===
=== topic

+++ slide
## Inheritance
+++

+++ slide

    struct Player : Pawn {
        const char* m_Name;
        int m_Score;
    };

+++

+++ slide

The alignment of pointers depends on the architecture. So the layout also
depends on the architecture.

+++

+++ slide

64-bit architecture

     0 | struct Player
     0 |   struct Pawn (base)
     0 |     int m_Id
     4 |     _Bool m_IsAlive
     8 |     int m_HP
    16 |   const char * m_Name
    24 |   int m_Score
       | [sizeof=32, dsize=28, align=8
       |  nvsize=28, nvalign=8]

+++


+++ slide

32-bit architecture

     0 | struct Player
     0 |   struct Pawn (base)
     0 |     int m_Id
     4 |     _Bool m_IsAlive
     8 |     int m_HP
    12 |   const char * m_Name
    16 |   int m_Score
       | [sizeof=20, dsize=20, align=4
       |  nvsize=20, nvalign=4]
+++



+++ slide
## Multiple inheritance
+++

+++ slide

    struct Enemy {
        int m_Damage;
    };

    struct EnemyPawn : Pawn, Enemy {
        int m_TargetId;
    };

+++

+++ slide

    0 | struct Enemy
    0 |   int m_Damage
      | [sizeof=4, dsize=4, align=4
      |  nvsize=4, nvalign=4]

+++

+++ slide

     0 | struct EnemyPawn
     0 |   struct Pawn (base)
     0 |     int m_Id
     4 |     _Bool m_IsAlive
     8 |     int m_HP
    12 |   struct Enemy (base)
    12 |     int m_Damage
    16 |   int m_TargetId
       | [sizeof=20, dsize=20, align=4
       |  nvsize=20, nvalign=4]
+++

+++ slide

The members of the derived class are laid out after the members of the base
class.

+++

===
=== topic

+++ slide
# Virtual Functions
+++

+++ slide
    struct Pawn {
        virtual ~Pawn() {} 
        virtual void NotOverridden() {}
        virtual int Move() { return 0; }
        int m_Id;
        bool m_IsAlive;
        int m_HP;
    };
+++

+++ slide
    struct Player : Pawn {
        virtual ~Player() {}
        virtual int Move() override { return 42; }
        const char* m_Name;
        int m_Score;
    };
+++

+++ slide

Virtual functions in C++ are implemented with the so called *virtual table*. The
*virtual table* is an array of pointers to methods. Whenever a virtual method is
called, the code lookups the pointer to the method in the *virtual table* and
executes it.

+++

+++ slide

    Pawn* p = new Player;

    p->Move();
    // actually it is:
    (p->*(p->vtable[index_for_Move]))();

+++

+++ slide

    Vtable for Pawn
    Pawn::vtable for Pawn: 6u entries
    0     (int (*)(...))0
    8     (int (*)(...))(& typeinfo for Pawn)
    16    (int (*)(...))Pawn::~Pawn
    24    (int (*)(...))Pawn::~Pawn
    32    (int (*)(...))Pawn::NotOverridden
    40    (int (*)(...))Pawn::Move

+++

+++ slide

    Player::vtable for Player: 6u entries
    0     (int (*)(...))0
    8     (int (*)(...))(& typeinfo for Player)
    16    (int (*)(...))Player::~Player
    24    (int (*)(...))Player::~Player
    32    (int (*)(...))Pawn::NotOverridden
    40    (int (*)(...))Player::Move

+++

+++ slide
### Layout
+++

+++ slide

     0 | struct Pawn
     0 |   (Pawn vtable pointer)
     8 |   int m_Id
    12 |   _Bool m_IsAlive
    16 |   int m_HP
       | [sizeof=24, dsize=20, align=8
       |  nvsize=20, nvalign=8]

+++

+++ slide
     0 | struct Player
     0 |   struct Pawn (primary base)
     0 |     (Pawn vtable pointer)
     8 |     int m_Id
    12 |     _Bool m_IsAlive
    16 |     int m_HP
    24 |   const char * m_Name
    32 |   int m_Score
       | [sizeof=40, dsize=36, align=8
       |  nvsize=36, nvalign=8]
+++

+++ slide
`clang++`'s `-fdump-vtable-laouts` did not output anything.

The virtual tables are dumped with:

    g++ -fdump-class-hierarchy -std=c++11 -c vlayout.cc 

+++
+++ slide
## Setting of the vtable pointer
+++
+++ slide
**Pseudo-C++ class for virtual tables**

    class VTable;
+++
+++ slide
    
    struct Pawn {
        Pawn(int health)
            : _vtbl(VTable_Pawn) // added by the compiler
            , m_Health(healt)
        {}
        virtual ~Pawn()
            : _vtbl(VTable_Pawn) // added by the compiler
        {}
        VTable* _vtbl;
        int m_Health;
    };

+++
+++ slide
    struct Player : Pawn {
        Player(int health, int score)
            : Pawn(health)
            , _vtbl(VTable_Player)
            , m_Score(score)
        {}
        virtual ~Player()
            : _vtbl(VTable_Pawn) // added by the compiler
        {
            this->~Pawn(); // added by the compiler
        }
        VTable* _vtbl;
        int m_Score;
    };
+++
+++ slide
# virtual functions are not virtual inside constructors and destructors
+++
+++ slide

Otherwise the virtual function will execute over not-yet constructed or already
destroyed object.

+++
+++ slide
# `C++11` `final` classes

Cannot be derived from.

* show intention
* optimizations - de-virtualization

+++
===
