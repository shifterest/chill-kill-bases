#!mainFile "../main.opy"

enum SettingProp:
    TITLE,
    DESCRIPTIONS,
    TYPE,
    PARAMETERS,
    COLORS,
    CHILL_REQUIRED


enum SettingsCatProp:
    NAME,
    STARTING_INDEX,
    ENDING_INDEX,
    COLOR


enum SettingType:
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
    COLOR_PICKER,
    CATEGORY  # For category navigation


enum SettingTypeNumericProp:
    MIN,
    MAX,
    STEP,
    SUFFIX


enum SettingCat:
    QUICK,
    GAME,
    HERO,
    ABILITIES,
    EFFECTS,
    SPECIAL,
    BASE,
    DREAM


enum Setting:
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


enum ProgHUD:
    TEXT,
    COLOR


enum InWorldHUD:
    BASE_MODE_ICON,
    BASE_SUMMARY


enum SettingsHUD:
    ACCENT_COLOR,
    CATEGORY_NAME,
    SECOND_PREVIOUS_SETTING,
    PREVIOUS_SETTING,
    CURRENT_SETTING,
    NEXT_SETTING,
    SECOND_NEXT_SETTING,
    CURRENT_SETTING_INDEX,
    TOTAL_SETTINGS,
    TYPE,
    SECOND_PREVIOUS_OPTION,
    PREVIOUS_OPTION,
    CURRENT_OPTION,
    NEXT_OPTION,
    SECOND_NEXT_OPTION,
    OPTION_COLOR,
    DESCRIPTION,
    CHILL_REQUIRED,
    # Legacy orb.opy compatibility
    SETTING,  # Setting title
    OPTION,   # Current option value
    CURRENT_TOTAL_OPTIONS  # Option counter string


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


enum UIState:
    NORMAL,
    IN_MENU,
    IN_ORB,
    MODERATING,
    DREAM_MODE,
    BASE_CREATION,
    KEYBOARD_INPUT


enum PendingSetting:
    CAMERA,
    HERO,
    SIZE_NOCLIP,
    INVISIBILITY


enum LastTransformProp:
    LAST_POS,
    LAST_FACING_DIR


enum WorkshopSettings:
    SERVER_MODE,
    REDUCE_SERVER_LOAD,
    MATCH_TIME,
    ENABLE_MATCH_TIMER,
    ENABLE_INSPECTOR,
    ENABLE_SCOREBOARD,
    ENABLE_POTG,
    RANDOMIZE_OUTLINE_COLOR,
    RANDOMIZE_BASE_COLOR,
    RANDOMIZE_CHILL_COLOR
