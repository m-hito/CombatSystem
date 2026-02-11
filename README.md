# Combat System v1.0

- 5-swing combo chain (each swing handles special events)
- Swing 5 = guaranteed stun
- Swing 3 = Uppercut Knockback in air
- Modular state machine for player/enemy states
- Knockback System extends to airbone combat if continued further ( uppercut a small glimpse of airbone combat )
- Built for wave spawner integration
- Damage Indicator to display damage  

## Movement System (Player)
- Dash in direction of WASD input
- FOV juicing (camera zoom in/out on dash)
- Handled inside `input.lua`

## Folder Hierarchy

```text 
ServerScriptService/
└── Systems (Folder 📂)/ HitTypes (Folder 📂) / Weapons (Folder 📂) / InitializeCombat (ServerScript 📜)
    ├── HitTypes (Folder 📂)/
    │   ├── Default
    │   ├── BlockBreak
    │   └── Blocked
    ├── Weapons (Folder 📂)/
    │   ├── Fist (ModuleScript)
    │   ├── Katana (ModuleScript
    │   └── FireFist ...)
    └── InitializeCombat (ServerScript)   # Parent = Systems

ReplicatedStorage/ Assets / Modules / Remotes ( 3 core folder ) 
└── Assets (Folder 📂) / Animations (Folder 📂) / Effects (Folder 📂) / Sounds (Folder 📂) / Weapons (Folder 📂) / HitboxTemplate (Part)/ DmgGui (ScreenGui)
|    ├── Animations/ Character (Folder 📂)/ Client (Folder 📂)/ Fist (Folder 📂)/ Katana (Folder 📂)/ more weapons... ( all weapons have identical structure )
|    │   ├── Character/HitReaction (Folder 📂)
|    |   |     ├── HitReaction/ 1/ 2 /3 /4 /5 (Animations track)
|    |   |     ├── BlockBreak (Animation)
|    |   |
|    │   ├── Client (Folder 📂)/
|    │   └── Fist, Katana, Dagger, FireFist .../
|    │       ├── Block/Idle
|    │       ├── HitReactions/1-5
|    │       └── Swings/L1-L5
|    ├── Effects (Folder 📂)/
|    │   ├── CoreEffect/
|    │   │   ├── BlockBreak (Dizzy emitter)
|    │   │   ├── Blocked (multiple emitters)
|    │   │   └── FistEffect (HitFX emitters)
|    │   └── DizzyEffect (part in NPC head)
|    |
|    ├── Sounds (Folder 📂)/
|    │   ├── BlockBreak 
|    │   ├── Fist, FireFist, others (Folder 📂)/
|    │   │   ├── Blocked/1-5 
|    │   │   ├── Hit/1-5
|    │   │   └── Swings/1-5
|    │   └── Katana/ (same pattern)
|    |
|    └── Weapons (Folder 📂)/
|    |    ├── Dagger
|    |    └── Katana
|    └── HitBoxTemplate ( Part )
|    └── DmgGui (ScreenGui) (make ur own)
|        └── DmgLabel (TextLabel)
|
└── Modules/
|      └── ClientEffects (Folder 📂)
|      |      └── BlockBreak ( ModuleScript) 
|      |      └── BlockEffect (ModuleScript)
|      |      └── DefaultHit (ModuleScript)
|      |      └── Sound (ModuleScript)
|      └── WeaponData (ModuleScript)
|              └── FireFist (ModuleScript)
|              └── Fist (ModuleScript)
|              └── More weapons 
└── Remotes
        └── Attack (RemoteEvents)
        └── Block
        └── ClientEffects
        └── LoadAnims

StarterPlayer
    └── StarterCharacterScripts
    |     └── Core (Folder 📂)
    |     |    └── GetTool (LocalScript)
    |     |    └── Inputs (LocalScript)
    |     |    └── Animations (ModuleScript)
    |     |
    |     └── Status (Folder 📂)
    └── StarterPlayerScripts
            └── ClientEffects (localScript)
```

## Inputs.lua
Input is taken from user here inside starterChar. This fires event for block/ attack from client to server. Server decides whether to give damage to player or not. Input.lua also handles dodge for local player


## Weapons/Fist.moduleScript (or any other weapon)
This handles the core weapon logic, whether to give damage or not attack combo handling state handling.

## InitializeCombat.lua 

