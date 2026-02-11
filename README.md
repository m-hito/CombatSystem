# Combat System v1.0

- 5-swing combo chain (each swing handles special events)
- Swing 5 = guaranteed stun
- Swing 3 = special effect window
- Modular state machine for player/enemy states
- Built for wave spawner integration

## Movement System (Player)
- Dash in direction of WASD input
- FOV juicing (camera zoom in/out on dash)
- Handled inside `input.lua`

## Folder Hierarchy

```text 
ServerScriptService/
└── Systems/
    ├── HitTypes/
    │   ├── Default
    │   ├── BlockBreak
    │   └── Blocked
    ├── Weapons/
    │   ├── Fist
    │   ├── Katana
    │   └── FireFist ...
    └── InitializeCombat   # Parent = Systems

ReplicatedStorage/
└── Assets/
|    ├── Animations/
|    │   ├── Character/HitReaction
|    │   ├── Client/
|    │   └── Fist, Katana, .../
|    │       ├── Block/Idle
|    │       ├── HitReactions/1-5
|    │       └── Swings/L1-L5
|    ├── Effects/
|    │   ├── CoreEffect/
|    │   │   ├── BlockBreak (Dizzy emitter)
|    │   │   ├── Blocked (multiple emitters)
|    │   │   └── FistEffect (HitFX emitters)
|    │   └── DizzyEffect (part in NPC head)
|    ├── Sounds/
|    │   ├── BlockBreak
|    │   ├── Fist, FireFist, others/
|    │   │   ├── Blocked/1-5
|   │   │   ├── Hit/1-5
|    │   │   └── Swings/1-5
|    │   └── Katana/ (same pattern)
|    └── Weapons/
|    |    ├── Dagger
|    |    └── Katana
|    └── HitBoxTemplate ( Part ) 
└── Modules/
      └── ClientEffects
                └──




