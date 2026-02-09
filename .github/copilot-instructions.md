# Copilot Instructions: Chill/Kill Bases (OverPy Project)

## Project Overview

This is an **Overwatch Workshop gamemode** written in **OverPy** — a high-level, Python-like language that compiles to Overwatch Workshop script. The project is a chill/kill base creator gamemode.

- **Language**: OverPy (`.opy` files)
- **Compiler**: [Zezombye/overpy](https://github.com/Zezombye/overpy) (VS Code extension)
- **File extension**: `.opy`
- **Compilation**: Save the main file in VS Code with the OverPy extension installed

---

## Project Structure

```
main.opy              # Entry point — settings block, #!include directives
script/
  variables.opy       # globalvar / playervar declarations
  subroutines.opy     # subroutine declarations (forward declarations)
  enums.opy           # Custom enum definitions (Preference, ProgHUD, etc.)
  macros.opy          # Custom macros (pref, pos, eye, face, helpers, effects)
rules/
  *.opy               # Rule files organized by feature (base, cameras, etc.)
```

- Every non-main file starts with `#!mainFile "../main.opy"` so OverPy knows the entry point.
- The main file uses `#!include "path/to/file.opy"` to include all modules.

---

## OverPy Language Essentials

### Syntax Basics

- **Indentation**: 4 spaces (tabs are treated as 4 spaces). Indentation is significant — it defines scope, just like Python.
- **Comments**: `#` for line comments, `/* */` for multiline.
- **Strings**: Single or double quotes. Supports escape sequences (`\n`, `\xHH`, `\uHHHH`, `\&entity;`). Successive strings auto-concatenate.
- **String modifiers**: `f""` (f-string), `w""` (fullwidth), `b""` (Blizzard Global font), `c""` (case-sensitive), `t""` (translatable), `l""` (localized/legacy).

### Rules

```overpy
rule "Rule Name":
    @Event eachPlayer          # or global
    @Team 1                    # optional
    @Hero widowmaker           # optional
    @Slot 11                   # optional
    @Condition expression1
    @Condition expression2     # multiple conditions = AND

    # Rule body
    someAction()
```

- `@Disabled` — disables the rule.
- `@Delimiter` — prevents the compiler from removing an empty rule (used as visual separators).
- `@NewPage` — adds empty rules to push the rule to the top of a new page in-game.

### Subroutines

```overpy
# In subroutines.opy (forward declaration)
subroutine MySubroutine

# In a rule file (definition)
def MySubroutine():
    @Name "— My subroutine"

    # body
```

- **No parameters or return values** — this is a Workshop limitation. Subroutines operate on `eventPlayer` and global state.
- Call with `MySubroutine()` or `async(MySubroutine, AsyncBehavior.RESTART)`.
- `@Name` sets the display name in the Workshop editor.

### Variables

```overpy
globalvar myGlobal 0        # with explicit index
playervar myPlayerVar       # auto-indexed
globalvar initialized = false   # with initialization
```

- Default variable names `A`–`Z`, `AA`–`DX` don't need declaration.
- Player variables are accessed as `eventPlayer.myVar` or `player.myVar`.

### Enums

```overpy
enum GameStatus:
    NOT_STARTED = 1,
    IN_PROGRESS,
    FINISHED
```

- Values auto-increment from the previous value (or 0 if first).
- Access: `GameStatus.IN_PROGRESS`
- `len(GameStatus)` gives the count; `GameStatus.toArray()` gives an array of values.
- Enum members are inlined at compile time.

### Macros

```overpy
# Constant macro
macro MAX_HP = 500

# Function macro (inline expansion — NOT a subroutine)
macro myMacro(param1, param2):
    param1 + param2

# Member macro (uses self)
macro Player.doSomething(value):
    self.setMaxHealth(value)
```

- Macros expand inline in the AST — order of operations is preserved.
- **Unlike `#!define`**, `macro` is safe with operator precedence (no need for extra parentheses).
- Default parameters and keyword arguments are supported.

### Control Flow

```overpy
# If/elif/else
if condition:
    action1()
elif otherCondition:
    action2()
else:
    action3()

# While loop
while condition:
    action()
    wait()

# Do-while
do:
    action()
    wait()
while RULE_CONDITION

# For loop
for i in range(5):
    action()

# Switch
switch value:
    case 1:
        action1()
        break
    case 2:
        action2()
        break
    default:
        action3()
```

- `RULE_CONDITION` is a special keyword that re-evaluates all `@Condition` annotations.
- Switch has **fallthrough** — always use `break` unless intentional.

### Async Calls

```overpy
async(MySubroutine, AsyncBehavior.RESTART)    # Restart if already running
async(MySubroutine, AsyncBehavior.NOOP)       # Do nothing if already running
```

### Built-in Values & Functions

- Functions are **camelCased**: `createEffect()`, `setMatchTime()`.
- Player functions are member calls: `eventPlayer.teleport(pos)`, `eventPlayer.getPosition()`.
- Constants use enums: `Hero.ANA`, `Map.HANAMURA`, `Color.RED`, `Button.INTERACT`, `Team.ALL`.
- `Math.INFINITY` for infinity.
- `vect(x, y, z)` for vectors.
- `wait()` defaults to `wait(0.016, Wait.IGNORE_CONDITION)`.

### Type Limitations

**Status types cannot be stored in arrays or variables.** OverPy's type system requires `Status` values to be inlined directly. Use `switch` statements instead of array lookups:

```overpy
# WRONG — Status cannot be stored in array
stasis_data = [Status.KNOCKED_DOWN, Status.STUNNED, Status.ASLEEP, Status.FROZEN]
eventPlayer.clearStatusEffect(stasis_data[index])  # Type error!

# CORRECT — Use switch statement with Status inlined
switch s(Setting.STASIS_MODE):
    case Stasis.KNOCKED_DOWN:
        eventPlayer.clearStatusEffect(Status.KNOCKED_DOWN)
        break
    case Stasis.STUNNED:
        eventPlayer.clearStatusEffect(Status.STUNNED)
        break
    # ... etc
```

---

## Project-Specific Conventions

### Shorthand Macros

This project defines shorthand macros in `script/macros.opy` to reduce verbosity:

| Macro | Expands To | Usage |
|-------|-----------|-------|
| `s(Setting.X)` | `eventPlayer.settings[Setting.X]` | Read/write player preferences |
| `pos()` | `eventPlayer.getPosition()` | Get event player position |
| `eye()` | `eventPlayer.getEyePosition()` | Get event player eye position |
| `face()` | `eventPlayer.getFacingDirection()` | Get event player facing direction |

**Important**: These macros only apply to `eventPlayer`. For other players (e.g., `eventPlayer.focused_player`, `eventPlayer.current_base_owner`), use the full syntax.

```overpy
# Correct
s(Setting.PLAYER_MODE)                                    # for eventPlayer
eventPlayer.focused_player.preferences[Setting.SIZE]         # for other players

# Correct
eye() + face() * 100                                            # for eventPlayer
eventPlayer.focused_player.getEyePosition()                     # for other players
```

Since macros expand inline, `pref()` can be used on both sides of assignment:
```overpy
s(Setting.DREAM_MODE) = true
s(Setting.THIRD_PERSON_OFFSET) = s(Setting.THIRD_PERSON_OFFSET) * -1
eventPlayer.isInDreamMode = true  # dream mode state uses a dedicated playervar
```

### Custom Enums (see `script/enums.opy`)

Key enums used throughout:

- **`Preference`** — indices into `eventPlayer.settings[]` array (PLAYER_MODE, THIRD_PERSON, BASE_SIZE, etc.)
- **`ProgHUD`** — indices for `eventPlayer.progress_hud[]` (TEXT, COLOR)
- **`SettingsHUD`** — indices for preferences display HUD
- **`OnScreenHUD`** — indices for on-screen HUD elements
- **`InWorldHUD`** — indices for in-world HUD elements
- **`ExtendedColor`** — extended color palette including RAINBOW
- **`PlayerMode`** — KILL, CHILL, ZEN
- **`BaseMode`** — PASSIVE, HIDDEN, FRIENDLY, REPULSIVE, HOSTILE
- **`AbilityMode`** — NORMAL, NO_COOLDOWN, HOLD_TO_SPAM
- **`ThirdPersonCamera`** — OFF, REAR, TOP_DOWN, STATIC_TOP_DOWN, FRONT

### Rule Naming Convention

- Section headers use `@Delimiter` and `@Disabled`:
  ```overpy
  rule "Base":
      @Disabled
      @Delimiter
  ```
- Sub-rules under a section are prefixed with `—` (em dash):
  ```overpy
  rule "— Create base":
  ```

### Subroutine Naming

- PascalCase: `UpdateCamera`, `CreateBase`, `DestroyBase`, `UpdateBaseOwner`
- Subroutines must be **forward-declared** in `script/subroutines.opy`

### Effect/Sound Macros

Commonly used macros in `script/macros.opy` for effects and sounds:

- `BuffImpactSound()`, `DebuffImpactSound()`, `BuffExplosionSound()`, etc.
- `BaseRingExplosion()` — plays a ring explosion effect at the base
- `Aura(effect, pos)`, `AuraHidden(effect, pos)` — creates aura effects
- `RainbowColor(color)` — resolves rainbow or static color

### Helper Macros

- `chaseProgress(duration, cancelCondition)` — chases `eventPlayer.progress` to 100
- `unchaseProgress(duration)` — chases progress back to 0
- `stopMomentum()` — stops all player velocity
- `waitLoad()` — adaptive wait based on server load
- `recreateBase()` — destroys and recreates base effects
- `isOverlappingBase(vector, size, gap_size)` — checks for base overlap
- `isInDifferentBase()` — checks if player is in someone else's base
- `isConfined()` — checks if player should be confined to their base

### Player State

Players have several important state variables:
- `eventPlayer.settings[]` — array of all preference values (use `pref()` macro)
- `eventPlayer.base_vector` — position of the player's base (null if no base)
- `eventPlayer.active_base_owner` — whose base the player is currently activated in
- `eventPlayer.current_base_owner` — whose base the player is currently standing in
- `eventPlayer.progress` — general-purpose progress bar value (0–100)
- `eventPlayer.progress_hud[]` — progress HUD display data [TEXT, COLOR]
- `eventPlayer.isInDreamMode` — whether player is in dream mode (dedicated playervar, not stored in preferences array)
- `eventPlayer.isInBaseCreationMode` — whether player is placing a base
- `eventPlayer.isViewingPreferences` — whether player is in the settings orb
- `eventPlayer.isInModeratorMode` — whether player is moderating
- `eventPlayer.mount` — the player being mounted on (if any)
- `eventPlayer.focused_player` — the player being spectated/focused on

---

## Common Patterns

### Camera Setup Pattern

Most camera functions follow this structure:
```overpy
# 1. Instant snap to current view
eventPlayer.startCamera(eye(), raycast(eye(), eye() + face() * 100, null, eventPlayer, false).getHitPosition(), 1)
# 2. Wait a frame
wait()
# 3. Set actual camera position with transition
eventPlayer.startCamera(cameraPos, lookAt, transitionSpeed)
# 4. Optionally upgrade to updateEveryFrame for smooth tracking
if not optimize and not s(Setting.THIRD_PERSON_SMOOTHING):
    wait(0.2)
    eventPlayer.startCamera(updateEveryFrame(cameraPos), updateEveryFrame(lookAt), 0)
```

### Progress Bar Pattern

```overpy
eventPlayer.progress_hud[ProgHUD.TEXT] = "Doing something..."
eventPlayer.progress_hud[ProgHUD.COLOR] = s(Setting.BASE_COLOR)
chaseProgress(duration, cancelCondition)
if eventPlayer.progress == 100:
    # Success action
unchaseProgress(duration)
wait(0.5)
```

### Overload Protection

Many rules check `not isOverloaded` and `not optimize` to reduce server load:
```overpy
@Condition not optimize
@Condition not isOverloaded
```

---

## Differences from Python

| Feature | Python | OverPy |
|---------|--------|--------|
| Subroutines | Functions with params/returns | `def` with no params, no returns |
| Macros | N/A | `macro` keyword for inline expansion |
| Enums | `enum.Enum` class | Simple `enum` block with auto-increment |
| Variables | Normal scoping | Must declare with `globalvar`/`playervar` |
| Imports | `import` / `from` | `#!include "file.opy"` |
| Entry point | `if __name__ == "__main__"` | `main.opy` with settings block |
| Compiler directives | N/A | `#!directive` syntax |
| Switch/case | `match`/`case` (3.10+) | `switch`/`case` with fallthrough |
| Annotations | Decorators `@decorator` | Rule metadata `@Event`, `@Condition`, etc. |
| F-strings | `f"text {expr}"` | `f"text {expr}"` (same syntax) |
| Arrays | Lists with methods | Workshop arrays — `.append()`, `.slice()`, `.index()` |
| Docstrings | `"""docstring"""` | `@Name "description"` for subroutines |
| Ternary | `x if cond else y` | `x if cond else y` (same syntax) |
| `wait()` | N/A | Required in loops to prevent server crash |

---

## Key Reminders

1. **Always add `wait()` in loops** — infinite loops without `wait()` will crash the Workshop server.
2. **`RULE_CONDITION`** re-evaluates all `@Condition` annotations — use in `do: ... while RULE_CONDITION` patterns.
3. **Subroutines have no parameters** — they operate on `eventPlayer` and shared state.
4. **Macros expand inline** — they are NOT function calls. They can be used on both sides of assignment.
5. **`#!mainFile`** must be at the very first line of every non-main `.opy` file.
6. **Forward-declare subroutines** in `script/subroutines.opy` before defining them.
7. **Enum values are inlined** — they are compile-time constants, not runtime objects.
8. **2D array assignment** is supported: `array[i][j] = value` compiles to a `.slice().concat()` pattern.
9. **`updateEveryFrame()`** wraps an expression to be re-evaluated every frame (used in camera/HUD).
10. **`evalOnce()`** wraps an expression to be evaluated only once (used to capture a player reference).
