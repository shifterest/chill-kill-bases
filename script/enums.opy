#!mainFile "../main.opy"

enum PreferenceProperty:
    TITLE,
    DESCRIPTIONS,
    TYPE,
    PARAMETERS,
    COLORS,
    CHILL_REQUIRED


enum PreferenceCategoryProperty:
    CATEGORY_INDEX,
    STARTING_INDEX,
    ENDING_INDEX,
    COLOR


enum PreferenceType:
    CATEGORY,
    MULTIPLE_CHOICE,
    MULTIPLE_CHOICE_RANDOM,
    BOOLEAN,
    NUMERIC,
    NUMERIC_REVERSIBLE,
    INTERACT, # duration
    INTERACT_MULTIPLE_CHOICE,
    INTERACT_MULTIPLE_CHOICE_RANDOM,
    INTERACT_BOOLEAN, # duration
    KEYBOARD, # duration
    COLOR_PICKER


enum Numeric:
    MIN,
    MAX,
    STEP,
    SUFFIX


enum Preference:
    # Main
    GAME,
    HERO,
    ABILITIES,
    EFFECTS,
    SPECIAL,
    BASE,
    DREAM,
    # Game
    PLAYER_MODE,
    THIRD_PERSON,
    THIRD_PERSON_DISTANCE,
    THIRD_PERSON_OFFSET,
    THIRD_PERSON_SMOOTHING,
    SWITCH_HERO,
    SHOW_HOTKEYS,
    STASIS,
    STASIS_MODE,
    FAST_TRAVEL,
    FAST_TRAVEL_TO_OBJECTIVE,
    INSTANT_RESPAWN,
    REMOVE_BASE_REMOTELY,
    SWITCH_TEAM,
    RESET,
    # Hero
    OUTLINE_COLOR,
    FLIGHT,
    FLIGHT_ACCELERATION,
    SIZE,
    GRAVITY,
    SPEED,
    JUMP_SPEED,
    VOICE_PITCH,
    # Abilities
    DAMAGE,
    DAMAGE_EFFECT,
    HEALING,
    HEALING_EFFECT,
    HEALTH,
    THORNS,
    THORNS_EFFECT,
    ABILITY_MODE,
    ABILITY_SPAM_DELAY,
    ULTIMATE_MODE,
    ULTIMATE_SPAM_DELAY,
    KNOCKBACK,
    PROJECTILE_SPEED,
    PROJECTILE_GRAVITY,
    AMMO_OVERLOAD,
    # Effects
    CUSTOM_MESSAGE,
    CUSTOM_MESSAGE_COLOR,
    AURA,
    AURA_EFFECT,
    AURA_COLOR,
    AURA_SIZE,
    HIDE_AURA_IN_FIRST_PERSON,
    # Special
    NOCLIP,
    INVISIBILITY,
    ALLOW_MOUNTING,
    MOUNTING_MODE,
    TRAMPOLINE,
    # Base
    BASE_MODE,
    BASE_COLOR,
    BASE_SIZE,
    BASE_GAP_SIZE,
    BASE_LOCK,
    BASE_NOCLIP,
    BASE_GRAVITY,
    BASE_SPEED,
    BASE_JUMP_SPEED,
    # Dream
    DREAM_MODE,
    AFK_TIMER,
    SWITCH_TIMER,
    CLIP_CAMERA,


enum AbilityEffect:
    NONE,
    SLEEP,
    BURN,
    FREEZE,
    HACK,
    KNOCK,
    STUN,
    REPEL,
    ATTRACT


# other enums
enum Mode:
    DEFAULT,
    MUSIC,
    SLEEP,
    SHIFTEREST


enum Key:
    CHAR,
    ANGLE_HORIZONTAL,
    ANGLE_VERTICAL,
    HALF_WIDTH


enum ProgressHUD:
    TEXT,
    COLOR


enum InWorldHUD:
    BASE_MODE_ICON,
    BASE_SUMMARY


enum PreferencesHUD:
    ACCENT_COLOR,
    TITLE,
    CURRENT_PREFERENCE,
    TOTAL_PREFERENCES,
    TYPE,
    PARAMETER,
    PARAMETER_COLOR,
    CURRENT_TOTAL_PARAMETERS,
    DESCRIPTION,
    CHILL_REQUIRED


enum OnScreenHUD:
    MAIN,
    COLOR,
    ACTIVATION


enum ExtendedColor:
    WHITE,
    GRAY,
    BLACK,
    RED,
    ORANGE,
    YELLOW,
    GREEN,
    LIME_GREEN,
    AQUA,
    TURQUOISE,
    SKY_BLUE,
    BLUE,
    VIOLET,
    PURPLE,
    ROSE,
    RAINBOW


enum PlayerMode:
    KILL,
    CHILL,
    ZEN


enum BaseMode:
    PASSIVE,
    HIDDEN,
    FRIENDLY,
    REPULSIVE,
    HOSTILE


enum Stasis:
    KNOCKED_DOWN,
    STUNNED,
    ASLEEP,
    FROZEN


enum ChillEffect:
    SPARKLES,
    CLOUD,
    LIGHT_SHAFT,
    GOOD_AURA,
    BAD_AURA,
    RING,
    SPHERE


enum AbilityMode:
    NORMAL,
    NO_COOLDOWN,
    HOLD_TO_SPAM


enum UltimateMode:
    NORMAL,
    NO_COOLDOWN,
    INFINITE,
    HOLD_TO_SPAM


enum MountingMode:
    STACK,
    INTERSECT,
    FRONT,
    BACK,
    LEFT,
    RIGHT


enum SpecialChar:
    BACKSPACE = 1,
    EXIT


enum ThirdPersonCamera:
    OFF,
    REAR,
    TOP_DOWN,
    STATIC_TOP_DOWN,
    FRONT