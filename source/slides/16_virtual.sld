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

===
=== topic

+++ slide
## Inheritance
+++

+++ slide
## Multiple inheritance
+++

===
=== topic

+++ slide
# Virtual Functions
+++
+++ slide
## Setting of v
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
=== topic

+++ slide
# Virtual Inheritance
+++

===
