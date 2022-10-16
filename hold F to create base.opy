settings {
    "main": {
        "description": "[v2.6b1] chill / kill bases (by shifterest) • TSX53\r\nlast updated: 10/16/2022\r\n\r\nbased on Chill Zone Base Creator by AlaskaWolf • ARYD2\r\n\r\na chill or kill gamemode designed with AFKing in mind.",
        "modeName": "hold F to create base"
    },
    "lobby": {
        "allowPlayersInQueue": true,
        "enableMatchVoiceChat": true,
        "spectatorSlots": 2,
        "returnToLobby": "never"
    },
    "gamemodes": {
        "ffa": {
            "disabledMaps": [
                "workshopChamber",
                "workshopGreenScreen"
            ]
        },
        "general": {
            "gamemodeStartTrigger": "immediately",
            "heroLimit": "off",
            "enableKillCam": false,
            "respawnTime%": 100,
            "scoreToWin": 9,
            "spawnHealthPacks": "enabled"
        }
    }
}


# * GLOBAL VARIABLES
# moderator variables
globalvar banList
globalvar modList
# data sets
globalvar COLORS
globalvar KEYBOARD_DATA
globalvar BASE_MODE_ICONS
globalvar PREFS_TITLES
globalvar PREFS_DATA
# constants
globalvar CENTER_ORB_RADIUS
globalvar SPIN_RADIUS
globalvar RAINBOW_DURATION
# initialization variables
globalvar defaultPrefs
globalvar prefsDefined
globalvar angle
globalvar red
globalvar green
globalvar blue


# * PLAYER VARIABLES
# moderator variables
playervar modProgressEntity
playervar playerToBan
# base variables
playervar baseVector
playervar isLookingAtCenterOrb
playervar baseRadiusPrev
# settlement variables
playervar baseInRadiusOf
playervar baseSettledIn
playervar baseInRadiusOfPrev
playervar baseModePrev
playervar arenaModePrev
playervar baseToFastTravelTo
playervar settleImmediately
# preferences variables
playervar prefsType
playervar prefsPage
playervar isHoldingToAdjustPrefs
playervar playerPrefs
# player mode variables
playervar modMode
playervar keyboardMode
playervar baseCreationMode
# HUD variables
playervar holdMeleeText
playervar holdMeleeColor
playervar HUDData
playervar prefsHUDData
# progress variables
playervar modActionProgress
playervar baseCreationProgress
playervar baseSettlementProgress
playervar prefsInteractProgress
playervar holdMeleeProgress
# miscellaneous variables
playervar focusedPlayer
playervar cubicBezier
playervar centerOrbRadiusT
playervar lastPosDir
playervar keyboardChar
playervar arenaDamageModification


# * SUBROUTINE NAMES
subroutine CalibrateHero
subroutine UpdateHUD
subroutine ResetCam
subroutine ThirdPersonCam
subroutine ThirdPersonSpectateCam
subroutine CircularPanCam
subroutine Confine
subroutine SettleInOwnBase
subroutine AnimateCenterOrb
subroutine SettleInArena
subroutine SettleInFriendlyBase
subroutine SettleInExclusiveBase
subroutine ArenaDamageModification
subroutine UpdatePrefsHUD
subroutine PrefsInteract


# * MACROS
# constants
#!define keyboardVect(n) localPlayer.getEyePosition() + vect(sinDeg(horizontalAngleOfDirection(localPlayer.lastPosDir[1])), n, cosDeg(horizontalAngleOfDirection(localPlayer.lastPosDir[1])))
#!define prefsVect(n) localPlayer.baseVector + (vect([], n, []) * distance(localPlayer.getEyePosition(), localPlayer.baseVector) / 2.5 * (3 if localPlayer.playerPrefs[prefsIndex.thirdPersonMode] else 1))
#!define rainbow() rgb(red, green, blue)
# conditions
#!define isCurrOrDupHero(hero) eventPlayer.getCurrentHero() == hero or eventPlayer.getHeroOfDuplication() == hero
#!define isInDifferentBase() [player for player in getAllPlayers() if player.baseVector and eventPlayer in getPlayersInRadius(player.baseVector, player.playerPrefs[prefsIndex.baseRadius], Team.ALL, LosCheck.OFF)][0] != eventPlayer.baseInRadiusOf
#!define isConfined() eventPlayer.baseSettledIn and (not eventPlayer.playerPrefs[prefsIndex.chillMode] and eventPlayer.baseSettledIn.playerPrefs[prefsIndex.arenaMode]) or (eventPlayer.baseSettledIn == eventPlayer and eventPlayer.playerPrefs[prefsIndex.baseLock])
# functions
#!define ChaseColor(c, d) chase(c, d, duration = RAINBOW_DURATION, ChaseReeval.NONE)\
wait(RAINBOW_DURATION)\
stopChasingVariable(c)
#!define ExplodeBase() playEffect(eventPlayer, DynamicEffect.RING_EXPLOSION, rainbow() if eventPlayer.playerPrefs[prefsIndex.baseColor] > 14 else COLORS[eventPlayer.playerPrefs[prefsIndex.baseColor]], eventPlayer.baseVector, eventPlayer.playerPrefs[prefsIndex.baseRadius] * 2)
#!define DebuffPlayerOnFocus() playEffect(eventPlayer, DynamicEffect.DEBUFF_IMPACT_SOUND, null, eventPlayer.focusedPlayer.getPosition(), 100)
#!define BuffFocusOnFocus() playEffect([eventPlayer, eventPlayer.focusedPlayer], DynamicEffect.BUFF_IMPACT_SOUND, null, eventPlayer.focusedPlayer.getPosition(), 100)
#!define DebuffFocusOnFocus() playEffect([eventPlayer, eventPlayer.focusedPlayer], DynamicEffect.DEBUFF_IMPACT_SOUND, null, eventPlayer.focusedPlayer.getPosition(), 100)
#!define BuffPlayer() playEffect(eventPlayer, DynamicEffect.BUFF_IMPACT_SOUND, null, eventPlayer.getPosition(), 100)
#!define DebuffPlayer() playEffect(eventPlayer, DynamicEffect.DEBUFF_IMPACT_SOUND, null, eventPlayer.getPosition(), 100)
#!define StopMomentum() eventPlayer.applyImpulse(-eventPlayer.getVelocity(), 0.00001, Relativity.TO_PLAYER, Impulse.CANCEL_CONTRARY_MOTION_XYZ)


enum prefsIndex:
    # ! sync prefsIndex with PREFS_TITLES, PREFS_TITLES and defaultPrefs
    chillMode,
    fastTravel,
    thirdPersonMode,
    spectatorMode,
    customMessage,
    customMessageColor,
    instantRespawn,
    switchHero,
    packBase,
    heroOutlineColor,
    flight,
    environmentCollision,
    invisibility,
    noCooldowns,
    fastUltimate,
    fastReload,
    heroScale,
    movementSpeed,
    projectileSpeed,
    projectileGravity,
    voicelinePitch,
    baseMode,
    arenaMode,
    baseColor,
    baseLock,
    baseRadius,
    inBaseGravity,
    inBaseMovementSpeed


rule "*+:. chill bases .:+*":
    @Delimiter

    #DISCLAIMER:
    #
    #this gamemode is very volatile. variable names may change and rules may be modified without further notice. sometimes it's optimizations, sometimes it's because i feel like it, lol.
    #
    #that is all, thankies for reading.
    return
    #COMMEMORATIONS:
    #
    # • i hereby commemorate the time i wasted trying to implement a cursor-based preferences menu only to scrap it all because of indecisiveness and server overloads. may you rest in peace.
    return

rule "setup":
    @Delimiter
    @Disabled


rule " • assemble heroes quickly":
    @Condition isAssemblingHeroes()

    setMatchTime(5)


rule " • server crash mitigation":
    @Condition getServerLoad() >= 200

    waitUntil(getServerLoad() < 200, 3)

    if getServerLoad() >= 200:
        setSlowMotion(15)

        waitUntil(getServerLoad() < 175, 99999)

        setSlowMotion(100)


rule " • global initialization":
    @Condition isGameInProgress()

    disableGamemodeCompletion()
    disableScoring()

    # workshop settings
    if createWorkshopSetting(
        bool,
        "match preferences",
        "disable workshop inspector (reduces server load)",
        false,
        4
    ):
        disableInspector()
    if createWorkshopSetting(bool, "match preferences", "disable match timer", true, 1):
        pauseMatchTime()
    setMatchTime(
        createWorkshopSetting(int[30:100], "match preferences", "match time", 60, 0)
        * 60
    )


rule " • global variables":
    @Condition isGameInProgress()

    # define data sets
    # ! sync COLORS with workshop settings colors
    COLORS = [
        Color.WHITE,
        Color.YELLOW,
        Color.GREEN,
        Color.PURPLE,
        Color.RED,
        Color.BLUE,
        Color.AQUA,
        Color.ORANGE,
        Color.SKY_BLUE,
        Color.TURQUOISE,
        Color.LIME_GREEN,
        Color.GRAY,
        Color.VIOLET,
        Color.ROSE,
        Color.BLACK,
        "rainbow",
    ]
    BASE_MODE_ICONS = [
        abilityIconString(Hero.SOLDIER, Button.ABILITY_1),
        abilityIconString(Hero.ZARYA, Button.ABILITY_1),
        abilityIconString(Hero.ZARYA, Button.ABILITY_2),
        iconString(Icon.NO),
    ]
    PREFS_TITLES = [
        [
            "chill mode",
            "fast travel",
            "third-person mode",
            "spectator mode",
            "custom message",
            "custom message color",
            "instant respawn",
            "switch hero",
            "pack base",
            "hero outline color",
            "flight",
            "environment collision",
            "invisibility",
            "no cooldowns",
            "fast ultimate",
            "fast reload",
            "hero scale",
            "movement speed",
            "projectile speed",
            "projectile gravity",
            "voiceline pitch",
            "base mode",
            "arena mode",
            "base color",
            "base lock",
            "base radius",
            "in-base gravity",
            "in-base movement speed",
        ],
        ["arena mode", "chill mode"],
    ]
    # description(s), preference type [0: multiple choice 1: boolean 2: numeric 3: interact 4: hold to interact 5: boolean (reference to another preference) 6: custom message], chill mode required, multiple choices / numeric variables [min, max, step] / hold to interact duration / preference index, color(s)
    PREFS_DATA = [
        [
            [
                [
                    "you are vulnerable to damage.",
                    "you are resilient to damage and knockback. you are still vulnerable to sleeps and stuns.",
                ],
                1,
                false,
                null,
                [Color.RED, Color.SKY_BLUE],
            ],
            [
                "lets you teleport to a waypoint you're looking at, or to your own base. hold melee to use.",
                1,
                true,
            ],
            ["toggles the third-person camera.", 1, false],
            ["spectate players randomly.", 4, false, 0.6],
            ["type a custom message that floats above your hero's head.", 6, false, 0.6],
            ["changes the color of your custom message.", 0, false, COLORS, COLORS],
            ["instantly respawns you in your base upon death.", 1, false],
            ["switch your hero.", 3, false, 0.6],
            ["remove your base from the map. you can place it again later.", 4, false, 0.6],
            [
                "changes the color of your hero outline. (due to limitations, rainbow mode is not available.)",
                0,
                false,
                COLORS.exclude("rainbow"),
                COLORS.exclude("rainbow"),
            ],
            ["lets you fly by holding jump.", 1, true],
            ["if disabled, lets you walk through walls.", 1, true],
            ["makes you invisible (along with your custom message).", 1, true],
            [
                "disables ability cooldowns and enables ability spam for certain heroes.",
                1,
                true,
            ],
            ["reduces ultimate cooldown time.", 1, true],
            ["reloads your weapon instantly.", 1, true],
            [
                "the size of your hero. 100+ only works with environmental collision disabled.",
                2,
                true,
                [10, 500, 10],
            ],
            ["your movement speed outside your base.", 2, true, [10, 500, 10]],
            ["your projectile speed.", 2, true, [0, 500, 10]],
            ["your projectile gravity.", 2, true, [0, 500, 10]],
            ["the pitch of your hero's voicelines.", 2, false, [50, 150, 10]],
            [
                [
                    "your base has no effect to players.",
                    "your base protects players.",
                    "your base protects players. players can fast travel to your base.",
                    "your base repels visitors.",
                ],
                0,
                false,
                ["passive", "friendly", "waypoint", "exclusive"],
                [Color.WHITE, Color.GREEN, Color.BLUE, Color.RED],
            ],
            [
                "turns your base into an arena. players inside are trapped and forced to kill mode.",
                4,
                false,
                3,
            ],
            [
                "changes the color of your base. (due to limitations, rainbow mode is not smooth.)",
                0,
                false,
                COLORS,
                COLORS
            ],
            ["prevents you from leaving your base.", 1],
            ["the size of your base.", 2, false, [1, 12, 0.5]],
            ["the gravity in your base.", 2, false, [0, 100, 10]],
            ["the speed of everyone in your base.", 2, false, [10, 150, 10]],
        ],
        [
            ["turn off arena mode.", 4, false, 0.6],
            [
                [
                    "you are vulnerable in your arena.",
                    "you are invulnerable in your arena.",
                ],
                5,
                false,
                0,
                [Color.RED, Color.SKY_BLUE],
            ],
        ],
    ]
    # character, horizontal angle, vertical angle
    KEYBOARD_DATA = [
        ["~", 28.1, -3.3],
        ["!", 24.6, -3.3],
        ["@", 21.0, -3.3],
        ["#", 17.1, -3.3],
        ["$", 13.2, -3.3],
        ["%", 9.3, -3.3],
        ["^", 5.3, -3.3],
        ["&", 1.6, -3.3],
        ["*", -2.1, -3.3],
        ["(", -5.3, -3.3],
        [")", -8.5, -3.3],
        ["_", -11.9, -3.3],
        ["+", -15.6, -3.3],
        ["back", -24.1, -3.3, 5],
        ["`", 28.1, 0],
        ["1", 24.6, 0],
        ["2", 21.0, 0],
        ["3", 17.1, 0],
        ["4", 13.2, 0],
        ["5", 9.7, 0],
        ["6", 6, 0],
        ["7", 2.2, 0],
        ["8", -1.5, 0],
        ["9", -5.3, 0],
        ["0", -8.9, 0],
        ["-", -12.4, 0],
        ["=", -15.7, 0],
        ["{", -19.2, 0],
        ["[", -22.4, 0],
        ["|", -25.8, 0],
        ["q", 22.8, 5.3],
        ["w", 18.9, 5.3],
        ["e", 14.6, 5.3],
        ["r", 11.1, 5.3],
        ["t", 7.5, 5.3],
        ["y", 4, 5.3],
        ["u", 0.2, 5.3],
        ["i", -3.2, 5.3],
        ["o", -6.7, 5.3],
        ["p", -10.5, 5.3],
        ["}", -16.5, 5.3],
        ["]", -19.7, 5.3],
        ["\\", -23, 5.3],
        ["a", 20.8, 8.8],
        ["s", 17.2, 8.8],
        ["d", 13.5, 8.8],
        ["f", 9.9, 8.8],
        ["g", 6.2, 8.8],
        ["h", 2.1, 8.8],
        ["j", -1.5, 8.8],
        ["k", -5.1, 8.8],
        ["l", -8.6, 8.8],
        [":", -11.9, 8.8],
        [";", -15, 8.8],
        ['"', -18.2, 8.8],
        ["'", -21.3, 8.8],
        ["z", 19.4, 12.3],
        ["x", 15.5, 12.3],
        ["c", 11.6, 12.3],
        ["v", 7.8, 12.3],
        ["b", 4.1, 12.3],
        ["n", 0.2, 12.3],
        ["m", -3.8, 12.3],
        ["<", -7.8, 12.3],
        [">", -11.4, 12.3],
        [",", -14.5, 12.3],
        [".", -17.6, 12.3],
        ["?", -21, 12.3],
        ["/", -24.6, 12.3],
        [" ", 0, 17.5, 2.5],
    ]
    # PREFS_PRI_ATK_DATA = [
    #     [prefsActionsIndex.prevPref, 0, -12.7, 5, 2.5],
    #     [prefsActionsIndex.nextPref, 0, -4.5, 5, 2.5],
    #     [prefsActionsIndex.jumpPref, 0, -1.6, 12, 1.5],
    #     [prefsActionsIndex.prevOption, 0, 9.35, 5, 2.5],
    #     [prefsActionsIndex.nextOption, 0, 16.5, 5, 2.5],
    #     [prefsActionsIndex.resetPref, 0, 19, 12, 1.5]
    # ]
    # PREFS_SEC_ATK_DATA = [
    #     [prefsActionsIndex.minOption, 0, 9.35, 5, 2.5],
    #     [prefsActionsIndex.maxOption, 0, 16.5, 5, 2.5],
    # ]
    # define constants
    CENTER_ORB_RADIUS = createWorkshopSetting(
        float[0.1:1], "game preferences", "center orb radius", 0.4, 0
    )
    SPIN_RADIUS = createWorkshopSetting(
        float[1:10], "game preferences", "circular pan camera radius", 4, 0
    )
    # rainbow color variables
    red = 0
    green = 0
    blue = 255
    RAINBOW_DURATION = createWorkshopSetting(
        float[0.1:5], "game preferences", "rainbow color duration", 0.5, 0
    )
    # start rotating circular pan camera
    chase(angle, -10000, rate = 7, ChaseReeval.NONE)
    # define moderator lists
    banList = []
    modList = []
    # define default preferences
    defaultPrefs[prefsIndex.chillMode] = createWorkshopSetting(
        bool, "default hero preferences", "chill mode", false, 0
    )
    defaultPrefs[prefsIndex.fastTravel] = createWorkshopSetting(
        bool, "default hero preferences", "fast travel", true, 1
    )
    defaultPrefs[prefsIndex.thirdPersonMode] = createWorkshopSetting(
        bool, "default hero preferences", "third-person mode", false, 2
    )
    defaultPrefs[prefsIndex.spectatorMode] = false
    defaultPrefs[prefsIndex.customMessage] = ""
    defaultPrefs[prefsIndex.customMessageColor] = createWorkshopSetting(
        enum[
            "white",
            "yellow",
            "green",
            "purple",
            "red",
            "blue",
            "aqua",
            "orange",
            "sky blue",
            "turquoise",
            "lime green",
            "gray",
            "violet",
            "rose",
            "black",
            "rainbow",
        ],
        "default hero preferences",
        "custom message color",
        0,
        3
    )
    defaultPrefs[prefsIndex.instantRespawn] = createWorkshopSetting(
        bool, "default hero preferences", "instant respawn", false, 4
    )
    defaultPrefs[prefsIndex.heroOutlineColor] = createWorkshopSetting(
        enum[
            "white",
            "yellow",
            "green",
            "purple",
            "red",
            "blue",
            "aqua",
            "orange",
            "sky blue",
            "turquoise",
            "lime green",
            "gray",
            "violet",
            "rose",
            "black",
        ],
        "default hero preferences",
        "hero outline color",
        4,
        5
    )
    defaultPrefs[prefsIndex.flight] = createWorkshopSetting(
        bool, "default hero preferences", "flight", false, 6
    )
    defaultPrefs[prefsIndex.environmentCollision] = createWorkshopSetting(
        bool, "default hero preferences", "environment collision", true, 7
    )
    defaultPrefs[prefsIndex.invisibility] = createWorkshopSetting(
        bool, "default hero preferences", "invisibility", false, 8
    )
    defaultPrefs[prefsIndex.noCooldowns] = createWorkshopSetting(
        bool, "default hero preferences", "no cooldowns", false, 9
    )
    defaultPrefs[prefsIndex.fastUltimate] = createWorkshopSetting(
        bool, "default hero preferences", "fast ultimate", false, 10
    )
    defaultPrefs[prefsIndex.fastReload] = createWorkshopSetting(
        bool, "default hero preferences", "fast reload", false, 11
    )
    defaultPrefs[prefsIndex.heroScale] = createWorkshopSetting(
        int[10:500], "default hero preferences", "hero scale", 100, 12
    )
    defaultPrefs[prefsIndex.movementSpeed] = createWorkshopSetting(
        int[10:500], "default hero preferences", "movement speed", 100, 13
    )
    defaultPrefs[prefsIndex.projectileSpeed] = createWorkshopSetting(
        int[0:500], "default hero preferences", "projectile speed", 100, 14
    )
    defaultPrefs[prefsIndex.projectileGravity] = createWorkshopSetting(
        int[0:500], "default hero preferences", "projectile gravity", 100, 15
    )
    defaultPrefs[prefsIndex.voicelinePitch] = createWorkshopSetting(
        int[50:150], "default hero preferences", "voiceline pitch", 100, 16
    )

    defaultPrefs[prefsIndex.baseMode] = createWorkshopSetting(
        enum["passive", "friendly", "waypoint", "exclusive"],
        "default base preferences",
        "base mode",
        0,
        0
    )
    defaultPrefs[prefsIndex.arenaMode] = false
    defaultPrefs[prefsIndex.baseColor] = createWorkshopSetting(
        enum[
            "white",
            "yellow",
            "green",
            "purple",
            "red",
            "blue",
            "aqua",
            "orange",
            "sky blue",
            "turquoise",
            "lime green",
            "gray",
            "violet",
            "rose",
            "black",
            "rainbow",
        ],
        "default base preferences",
        "base color",
        7,
        1
    )
    defaultPrefs[prefsIndex.baseLock] = createWorkshopSetting(
        bool, "default base preferences", "base lock", false, 2
    )
    defaultPrefs[prefsIndex.baseRadius] = createWorkshopSetting(
        int[1:12], "default base preferences", "base radius", 3, 3
    )
    defaultPrefs[prefsIndex.inBaseGravity] = createWorkshopSetting(
        int[0:100], "default base preferences", "in-base gravity", 100, 4
    )
    defaultPrefs[prefsIndex.inBaseMovementSpeed] = createWorkshopSetting(
        int[10:150], "default base preferences", "in-base movement speed", 100, 5
    )
    # finish defining variables
    prefsDefined = true


rule " • player initialization and variables":
    @Event playerJoined

    eventPlayer.disableGamemodeHud()
    if createWorkshopSetting(bool, "match preferences", "disable scoreboard", false, 2):
        eventPlayer.disableScoreboard()

    # define player preferences
    waitUntil(prefsDefined == true, 99999)

    eventPlayer.playerPrefs = defaultPrefs

    CalibrateHero()
    ResetCam()

    # define center orb animation variable
    eventPlayer.cubicBezier = (
        1 - CENTER_ORB_RADIUS / eventPlayer.playerPrefs[prefsIndex.baseRadius]
    )

    waitUntil(eventPlayer.hasSpawned(), 99999)

    # set hero outline color
    eventPlayer.startForcingOutlineFor(
        getAllPlayers(),
        true,
        COLORS[eventPlayer.playerPrefs[prefsIndex.heroOutlineColor]],
        OutlineVisibility.DEFAULT
    )

    # display welcome messages
    wait(0.25)

    bigMessage(eventPlayer, "welcome to chill bases!")

    wait(3)

    bigMessage(
        eventPlayer,
        "to get started, hold {} to create a base!".format(
            buttonString(Button.INTERACT)
        )
    )


rule " • global HUD":
    @Condition isGameInProgress()

    # * LEFT
    # your hero
    hudText(
        [
            player
            for player in getAllPlayers()
            if not player.modMode and not player.playerPrefs[prefsIndex.spectatorMode]
        ],
        localPlayer.HUDData[0],
        "your hero",
        localPlayer.HUDData[1],
        HudPosition.LEFT,
        0,
        COLORS[localPlayer.playerPrefs[prefsIndex.heroOutlineColor]],
        Color.WHITE,
        COLORS[localPlayer.playerPrefs[prefsIndex.heroOutlineColor]],
        HudReeval.VISIBILITY_STRING_AND_COLOR,
        SpecVisibility.DEFAULT
    )
    # your base
    hudText(
        [
            player
            for player in getAllPlayers()
            if not player.modMode and not player.playerPrefs[prefsIndex.spectatorMode]
        ],
        localPlayer.HUDData[2],
        "your base",
        localPlayer.HUDData[3],
        HudPosition.LEFT,
        1,
        Color.GRAY
        if not localPlayer.baseVector
        else rainbow()
        if localPlayer.playerPrefs[prefsIndex.baseColor] > 14
        else COLORS[localPlayer.playerPrefs[prefsIndex.baseColor]],
        Color.WHITE,
        Color.GRAY
        if not localPlayer.baseVector
        else rainbow()
        if localPlayer.playerPrefs[prefsIndex.baseColor] > 14
        else COLORS[localPlayer.playerPrefs[prefsIndex.baseColor]],
        HudReeval.VISIBILITY_STRING_AND_COLOR,
        SpecVisibility.DEFAULT
    )
    # current base
    hudText(
        [
            player
            for player in getAllPlayers()
            if player.baseSettledIn
            and player.baseSettledIn != player
            and not player.modMode
            and not player.playerPrefs[prefsIndex.spectatorMode]
        ],
        localPlayer.baseSettledIn.HUDData[2],
        "{} {}'s base".format(
            heroIcon(localPlayer.baseSettledIn.getCurrentHero()),
            localPlayer.baseSettledIn
        ),
        localPlayer.baseSettledIn.HUDData[3],
        HudPosition.LEFT,
        2,
        rainbow()
        if localPlayer.baseSettledIn.playerPrefs[prefsIndex.baseColor] > 14
        else COLORS[localPlayer.baseSettledIn.playerPrefs[prefsIndex.baseColor]],
        Color.WHITE,
        rainbow()
        if localPlayer.baseSettledIn.playerPrefs[prefsIndex.baseColor] > 14
        else COLORS[localPlayer.baseSettledIn.playerPrefs[prefsIndex.baseColor]],
        HudReeval.VISIBILITY_STRING_AND_COLOR,
        SpecVisibility.DEFAULT
    )
    # custom message
    hudText(
        [
            player
            for player in getAllPlayers()
            if strLen(player.playerPrefs[prefsIndex.customMessage]) > 0
            and not player.modMode
            and not player.playerPrefs[prefsIndex.spectatorMode]
        ],
        iconString(Icon.FLAG),
        "custom message",
        localPlayer.playerPrefs[prefsIndex.customMessage],
        HudPosition.LEFT,
        3,
        rainbow()
        if localPlayer.playerPrefs[prefsIndex.customMessageColor] > 14
        else COLORS[localPlayer.playerPrefs[prefsIndex.customMessageColor]],
        Color.WHITE,
        rainbow()
        if localPlayer.playerPrefs[prefsIndex.customMessageColor] > 14
        else COLORS[localPlayer.playerPrefs[prefsIndex.customMessageColor]],
        HudReeval.VISIBILITY_STRING_AND_COLOR,
        SpecVisibility.DEFAULT
    )
    # moderator mode
    hudText(
        [player for player in getAllPlayers() if player.modMode],
        iconString(Icon.EYE),
        "{} to switch player • {} to sleep • {} to kill • {} to ban • {} to delete base{}".format(
            buttonString(Button.JUMP),
            buttonString(Button.PRIMARY_FIRE),
            buttonString(Button.SECONDARY_FIRE),
            buttonString(Button.MELEE),
            buttonString(Button.ABILITY_1),
            "• {} to promote / demote player".format(buttonString(Button.ABILITY_2))
            if localPlayer == hostPlayer
            else ""
        ),
        "{} {}{}  |  {}  |  {}".format(
            heroIcon(localPlayer.focusedPlayer.getCurrentHero()),
            localPlayer.focusedPlayer,
            " (host)"
            if localPlayer.focusedPlayer == hostPlayer
            else " (moderator)"
            if localPlayer.focusedPlayer in modList
            else "",
            localPlayer.focusedPlayer.HUDData[1],
            localPlayer.focusedPlayer.HUDData[3]
        ),
        HudPosition.LEFT,
        0,
        Color.RED,
        Color.WHITE,
        Color.WHITE,
        HudReeval.VISIBILITY_AND_STRING,
        SpecVisibility.DEFAULT
    )
    # padding
    hudSubtext(
        getAllPlayers(),
        " ",
        HudPosition.LEFT,
        9,
        Color.WHITE,
        HudReeval.VISIBILITY,
        SpecVisibility.DEFAULT
    )
    # moderator mode tip
    hudText(
        [
            player
            for player in modList.concat(hostPlayer)
            if not player.playerPrefs[prefsIndex.spectatorMode]
        ],
        iconString(Icon.EYE),
        "moderator mode",
        "press {} + {} to toggle".format(
            buttonString(Button.CROUCH), buttonString(Button.RELOAD)
        ),
        HudPosition.LEFT,
        10,
        Color.WHITE,
        Color.WHITE,
        Color.WHITE,
        HudReeval.VISIBILITY_AND_STRING,
        SpecVisibility.DEFAULT
    )
    # server load
    hudText(
        [
            player
            for player in modList.concat(hostPlayer)
            if not player.playerPrefs[prefsIndex.spectatorMode]
        ],
        iconString(Icon.BOLT),
        "server info",
        "{} live • {} mean • {} peak • {} text • {} entities".format(
            getServerLoad(),
            getAverageServerLoad(),
            getPeakServerLoad(),
            getNumberOfTextIds(),
            getNumberOfEntityIds()
        ),
        HudPosition.LEFT,
        11,
        Color.WHITE,
        Color.WHITE,
        Color.WHITE,
        HudReeval.VISIBILITY_AND_STRING,
        SpecVisibility.DEFAULT
    )

    # * TOP
    # base creation tips
    hudSubtext(
        [
            player
            for player in getAllPlayers()
            if not player.baseVector and not player.modMode
        ],
        "press {} to place your base, or press {} again to cancel.".format(
            buttonString(Button.PRIMARY_FIRE), buttonString(Button.INTERACT)
        )
        if localPlayer.baseCreationMode
        else "to get started, hold {} to create a base!".format(
            buttonString(Button.INTERACT)
        ),
        HudPosition.TOP,
        0,
        Color.WHITE,
        HudReeval.VISIBILITY_AND_STRING,
        SpecVisibility.DEFAULT
    )
    # preferences tips
    hudSubtext(
        [
            player
            for player in getAllPlayers()
            if player.baseSettledIn == player
            and not player.modMode
            and not player.playerPrefs[prefsIndex.spectatorMode]
            and not player.keyboardMode
        ],
        "look at the center orb to change your preferences!",
        HudPosition.TOP,
        0,
        Color.WHITE,
        HudReeval.VISIBILITY,
        SpecVisibility.DEFAULT
    )
    # spectator tip
    hudSubtext(
        [
            player
            for player in getAllPlayers()
            if player.playerPrefs[prefsIndex.spectatorMode]
        ],
        "press {} to exit spectator mode.".format(buttonString(Button.JUMP)),
        HudPosition.TOP,
        0,
        Color.WHITE,
        HudReeval.VISIBILITY_AND_STRING,
        SpecVisibility.DEFAULT
    )
    # arena tip
    hudSubtext(
        [
            player
            for player in getAllPlayers()
            if player.baseSettledIn != player
            and not player.modMode
            and player.baseSettledIn.playerPrefs[prefsIndex.arenaMode]
        ],
        "death is your only escape. (you can hold {} to escape, but that's a secret between us.)".format(
            buttonString(Button.MELEE)
        ),
        HudPosition.TOP,
        0,
        Color.WHITE,
        HudReeval.VISIBILITY_AND_STRING,
        SpecVisibility.DEFAULT
    )
    # keyboard tip
    hudSubtext(
        [player for player in getAllPlayers() if player.keyboardMode],
        "hold backspace to clear. press {} to exit keyboard.".format(
            buttonString(Button.JUMP)
        ),
        HudPosition.TOP,
        0,
        Color.WHITE,
        HudReeval.VISIBILITY_AND_STRING,
        SpecVisibility.DEFAULT
    )
    # fast travel / arena self-kill progress
    progressBarHud(
        [
            player
            for player in getAllPlayers()
            if player.holdMeleeProgress > 0 and player.holdMeleeProgress < 100
        ],
        localPlayer.holdMeleeProgress,
        localPlayer.holdMeleeText,
        HudPosition.TOP,
        2,
        rainbow()
        if localPlayer.holdMeleeColor < 0
        else localPlayer.holdMeleeColor,
        Color.WHITE,
        ProgressHudReeval.VISIBILITY_VALUES_AND_COLOR,
        SpecVisibility.DEFAULT
    )
    # base preparation progress
    progressBarHud(
        [player for player in getAllPlayers() if player.baseCreationProgress > 0],
        localPlayer.baseCreationProgress,
        "preparing base...",
        HudPosition.TOP,
        2,
        rainbow()
        if localPlayer.playerPrefs[prefsIndex.baseColor] > 14
        else COLORS[localPlayer.playerPrefs[prefsIndex.baseColor]],
        Color.WHITE,
        ProgressHudReeval.VISIBILITY_VALUES_AND_COLOR,
        SpecVisibility.DEFAULT
    )
    # base settlement progress
    progressBarHud(
        localPlayer
        if localPlayer.baseSettlementProgress > 0
        and localPlayer.baseSettlementProgress < 100
        else null,
        localPlayer.baseSettlementProgress,
        "entering {}{} {}...".format(
            heroIcon(localPlayer.baseInRadiusOf.getCurrentHero())
            if localPlayer.baseInRadiusOf != localPlayer
            else "",
            "{}'s".format(localPlayer.baseInRadiusOf)
            if localPlayer.baseInRadiusOf != localPlayer
            else "your",
            "arena"
            if localPlayer.baseInRadiusOf.playerPrefs[prefsIndex.arenaMode]
            else "base"
        ),
        HudPosition.TOP,
        2,
        rainbow()
        if localPlayer.baseInRadiusOf.playerPrefs[prefsIndex.baseColor] > 14
        else COLORS[localPlayer.baseInRadiusOf.playerPrefs[prefsIndex.baseColor]],
        Color.WHITE,
        ProgressHudReeval.VISIBILITY_VALUES_AND_COLOR,
        SpecVisibility.DEFAULT
    )

    # * RIGHT
    # game info
    hudSubtext(
        getAllPlayers(),
        "chill bases (by shifterest) • TSX53",
        HudPosition.RIGHT,
        0,
        rainbow(),
        HudReeval.VISIBILITY_AND_COLOR,
        SpecVisibility.DEFAULT
    )
    # lobby owner info
    hudSubtext(
        getAllPlayers(),
        "this lobby is owned by {} {}".format(
            heroIcon(hostPlayer.getCurrentHero()), hostPlayer
        ),
        HudPosition.RIGHT,
        1,
        Color.WHITE,
        HudReeval.VISIBILITY_AND_STRING,
        SpecVisibility.DEFAULT
    )

    # * IN-WORLD
    # base icon
    createIcon(
        localPlayer
        if localPlayer.baseVector and localPlayer.baseSettledIn != localPlayer
        else null,
        localPlayer.baseVector
        + vect([], localPlayer.playerPrefs[prefsIndex.baseRadius], []),
        Icon.ARROW_DOWN,
        IconReeval.VISIBILITY_AND_POSITION,
        Color.WHITE,
        true
    )
    # base outline
    createEffect(
        [player for player in getAllPlayers() if player.baseSettledIn],
        Effect.RING,
        rainbow()
        if localPlayer.baseSettledIn.playerPrefs[prefsIndex.baseColor] > 14
        else COLORS[localPlayer.baseSettledIn.playerPrefs[prefsIndex.baseColor]],
        localPlayer.baseSettledIn.baseVector,
        localPlayer.baseSettledIn.playerPrefs[prefsIndex.baseRadius],
        EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR
    )
    # center orb
    createEffect(
        localPlayer
        if localPlayer.baseSettledIn == localPlayer
        and not localPlayer.modMode
        and not localPlayer.playerPrefs[prefsIndex.spectatorMode]
        and not localPlayer.keyboardMode
        else null,
        Effect.SPHERE,
        rainbow()
        if localPlayer.playerPrefs[prefsIndex.baseColor] > 14
        else COLORS[localPlayer.playerPrefs[prefsIndex.baseColor]],
        localPlayer.baseVector,
        CENTER_ORB_RADIUS,
        # (((1 - localPlayer.centerOrbRadiusT) ** 3) * localPlayer.cubicBezier)
        # * localPlayer.playerPrefs[prefsIndex.baseRadius]
        # + CENTER_ORB_RADIUS,
        EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR
    )
    # keyboard
    createInWorldText(
        localPlayer if localPlayer.keyboardMode else null,
        "{}{}".format(
            localPlayer.playerPrefs[prefsIndex.customMessage],
            "|" if getTotalTimeElapsed() % 1 <= 0.5 else "  "
        ),
        keyboardVect(0.25),
        2.5,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
        Color.WHITE,
        SpecVisibility.DEFAULT
    )
    createInWorldText(
        localPlayer if localPlayer.keyboardMode else null,
        "~     !     @     #     $     %     ^     &     *     (     )     _     +     backspace",
        keyboardVect(0.1),
        2.5,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_POSITION,
        Color.WHITE,
        SpecVisibility.DEFAULT
    )
    createInWorldText(
        localPlayer if localPlayer.keyboardMode else null,
        "`     1     2     3     4     5     6     7     8     9     0     -     =     {     [     |     ",
        keyboardVect(0),
        2.5,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_POSITION,
        Color.WHITE,
        SpecVisibility.DEFAULT
    )
    createInWorldText(
        localPlayer if localPlayer.keyboardMode else null,
        "q     w     e     r     t     y     u     i     o     p          }     ]     \\",
        keyboardVect(-0.15),
        2.5,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_POSITION,
        Color.WHITE,
        SpecVisibility.DEFAULT
    )
    createInWorldText(
        localPlayer if localPlayer.keyboardMode else null,
        "a     s     d     f     g     h     j     k     l     :     ;     \"     '",
        keyboardVect(-0.25),
        2.5,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_POSITION,
        Color.WHITE,
        SpecVisibility.DEFAULT
    )
    createInWorldText(
        localPlayer if localPlayer.keyboardMode else null,
        "          z     x     c     v     b     n     m     <     >     ,     .     ?     /",
        keyboardVect(-0.35),
        2.5,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_POSITION,
        Color.WHITE,
        SpecVisibility.DEFAULT
    )
    createInWorldText(
        localPlayer if localPlayer.keyboardMode else null,
        "space",
        keyboardVect(-0.5),
        2.5,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_POSITION,
        Color.WHITE,
        SpecVisibility.DEFAULT
    )
    # cursor
    createInWorldText(
        localPlayer if localPlayer.keyboardMode else null,
        "▲",
        updateEveryTick(
            localPlayer.getEyePosition()
            + vect(
                min(
                    43.5,
                    max(
                        -43.5,
                        angleDifference(
                            horizontalAngleOfDirection(localPlayer.lastPosDir[1]),
                            localPlayer.getHorizontalFacingAngle()
                        )
                    )
                )
                / 35
                * cosDeg(horizontalAngleOfDirection(localPlayer.lastPosDir[1]))
                + sinDeg(horizontalAngleOfDirection(localPlayer.lastPosDir[1])),
                -min(
                    27,
                    max(
                        -21.7,
                        angleDifference(
                            verticalAngleOfDirection(localPlayer.lastPosDir[1]),
                            localPlayer.getVerticalFacingAngle()
                        )
                    )
                )
                / 35,
                -min(
                    43.5,
                    max(
                        -43.5,
                        angleDifference(
                            horizontalAngleOfDirection(localPlayer.lastPosDir[1]),
                            localPlayer.getHorizontalFacingAngle()
                        )
                    )
                )
                / 35
                * sinDeg(horizontalAngleOfDirection(localPlayer.lastPosDir[1]))
                + cosDeg(horizontalAngleOfDirection(localPlayer.lastPosDir[1]))
            )
        ),
        2,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_POSITION,
        Color.ORANGE,
        SpecVisibility.DEFAULT
    )

    # * PREFERENCES
    # jump to x preferences
    createInWorldText(
        localPlayer
        if localPlayer.isLookingAtCenterOrb and not localPlayer.prefsType
        else null,
        "press {} to jump to {} preferences".format(
            buttonString(Button.MELEE), localPlayer.prefsHUDData[0]
        ),
        prefsVect(0.9),
        0.9,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
        Color.ORANGE,
        SpecVisibility.DEFAULT
    )
    # preferences title
    createInWorldText(
        localPlayer if localPlayer.isLookingAtCenterOrb else null,
        PREFS_TITLES[localPlayer.prefsType][localPlayer.prefsPage],
        prefsVect(0.8),
        1.5,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
        Color.WHITE,
        SpecVisibility.DEFAULT
    )
    # preferences counter, previous / next preference tip
    createInWorldText(
        localPlayer if localPlayer.isLookingAtCenterOrb else null,
        "{} {} • {} of {} • {} {}".format(
            buttonString(Button.PRIMARY_FIRE),
            iconString(Icon.ARROW_LEFT),
            localPlayer.prefsPage + 1,
            len(PREFS_TITLES[localPlayer.prefsType]),
            iconString(Icon.ARROW_RIGHT),
            buttonString(Button.SECONDARY_FIRE)
        ),
        prefsVect(0.7),
        0.9,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
        Color.ORANGE,
        SpecVisibility.DEFAULT
    )
    # player preference
    createInWorldText(
        localPlayer if localPlayer.isLookingAtCenterOrb else null,
        localPlayer.prefsHUDData[1],
        prefsVect(0.5),
        1.5,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR,
        rainbow()
        if localPlayer.prefsHUDData[2] < 0
        else localPlayer.prefsHUDData[2],
        SpecVisibility.DEFAULT
    )
    # preference interaction progress
    createProgressBarInWorldText(
        localPlayer
        if localPlayer.isLookingAtCenterOrb and localPlayer.prefsInteractProgress > 0
        else null,
        localPlayer.prefsInteractProgress,
        null,
        prefsVect(0.4),
        0.8,
        Clip.NONE,
        rainbow()
        if localPlayer.playerPrefs[prefsIndex.baseColor] > 14 else COLORS[localPlayer.playerPrefs[prefsIndex.baseColor]],
        null,
        ProgressWorldTextReeval.VISIBILITY_POSITION_VALUES_AND_COLOR,
        SpecVisibility.DEFAULT
    )
    # player preference counter, tips
    createInWorldText(
        localPlayer if localPlayer.isLookingAtCenterOrb else null,
        "{} {} {}  |  {} to reset".format(
            buttonString(Button.ABILITY_1),
            localPlayer.prefsHUDData[3],
            buttonString(Button.ABILITY_2),
            buttonString(Button.RELOAD)
        )
        if PREFS_DATA[localPlayer.prefsType][localPlayer.prefsPage][1] == 0
        else "{} to toggle".format(buttonString(Button.INTERACT))
        if PREFS_DATA[localPlayer.prefsType][localPlayer.prefsPage][1] == 1
        or PREFS_DATA[localPlayer.prefsType][localPlayer.prefsPage][1] == 5
        else "{0} {1} • {2} {3}  |  {4} + {0} {5} • {6} {4} + {3}  |  {7} to reset".format(
            buttonString(Button.ABILITY_1),
            iconString(Icon.ARROW_DOWN),
            iconString(Icon.ARROW_UP),
            buttonString(Button.ABILITY_2),
            buttonString(Button.CROUCH),
            iconString(Icon.ARROW_LEFT),
            iconString(Icon.ARROW_RIGHT),
            buttonString(Button.RELOAD)
        )
        if PREFS_DATA[localPlayer.prefsType][localPlayer.prefsPage][1] == 2
        else "{} to interact".format(buttonString(Button.INTERACT))
        if PREFS_DATA[localPlayer.prefsType][localPlayer.prefsPage][1] == 3
        else "hold {} to interact".format(buttonString(Button.INTERACT))
        if PREFS_DATA[localPlayer.prefsType][localPlayer.prefsPage][1] == 4
        or PREFS_DATA[localPlayer.prefsType][localPlayer.prefsPage][1] == 6
        else "",
        prefsVect(0.4),
        0.9,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
        Color.ORANGE,
        SpecVisibility.DEFAULT
    )
    # description
    createInWorldText(
        localPlayer if localPlayer.isLookingAtCenterOrb else null,
        localPlayer.prefsHUDData[4],
        prefsVect(0.2),
        1,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
        Color.WHITE,
        SpecVisibility.DEFAULT
    )
    # chill mode required
    createInWorldText(
        localPlayer
        if localPlayer.isLookingAtCenterOrb
        and not localPlayer.playerPrefs[prefsIndex.chillMode]
        and PREFS_DATA[localPlayer.prefsType][localPlayer.prefsPage][2]
        else null,
        "chill mode required",
        localPlayer.baseVector,
        1,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_POSITION,
        Color.SKY_BLUE,
        SpecVisibility.DEFAULT
    )


rule " • player HUD":
    @Event eachPlayer

    # chill mode sparkles
    # createEffect(
    #     getAllPlayers().exclude(eventPlayer)
    #     if eventPlayer.playerPrefs[prefsIndex.chillMode]
    #     and not eventPlayer.playerPrefs[prefsIndex.invisibility]
    #     and not eventPlayer.keyboardMode
    #     else null,
    #     Effect.SPARKLES,
    #     COLORS[eventPlayer.playerPrefs[prefsIndex.heroOutlineColor]],
    #     eventPlayer,
    #     eventPlayer.playerPrefs[prefsIndex.heroScale] / 200,
    #     EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR
    # )
    # custom message
    createInWorldText(
        null
        if eventPlayer.playerPrefs[prefsIndex.invisibility] or eventPlayer.keyboardMode
        else getAllPlayers().exclude(eventPlayer),
        "{}{}{}".format(
            abilityIconString(
                Hero.MEI, Button.ULTIMATE
            ) if eventPlayer.playerPrefs[prefsIndex.chillMode] else "",
            " · " if eventPlayer.playerPrefs[prefsIndex.chillMode] and strLen(
                eventPlayer.playerPrefs[prefsIndex.customMessage]
            ) else "",
            eventPlayer.playerPrefs[prefsIndex.customMessage]
        ),
        updateEveryTick(eventPlayer.getEyePosition()) + (Vector.UP * 0.65),
        1.5,
        Clip.SURFACES,
        WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR,
        rainbow()
        if eventPlayer.playerPrefs[prefsIndex.customMessageColor] > 14
        else COLORS[eventPlayer.playerPrefs[prefsIndex.customMessageColor]],
        SpecVisibility.DEFAULT
    )
    # base sphere
    createEffect(
        [player for player in getAllPlayers() if player.baseSettledIn != eventPlayer]
        if eventPlayer.baseVector
        else eventPlayer
        if eventPlayer.baseCreationMode
        else null,
        Effect.SPHERE,
        rainbow()
        if eventPlayer.playerPrefs[prefsIndex.baseColor] > 14
        else COLORS[eventPlayer.playerPrefs[prefsIndex.baseColor]],
        eventPlayer.baseVector
        if eventPlayer.baseVector
        else updateEveryTick(eventPlayer.getPosition())
        if eventPlayer.baseCreationMode
        else null,
        eventPlayer.playerPrefs[prefsIndex.baseRadius],
        EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR
    )
    # base mode icon
    createInWorldText(
        [
            player
            for player in getAllPlayers().exclude(eventPlayer)
            if player.baseSettledIn != eventPlayer
            and not player.playerPrefs[prefsIndex.spectatorMode]
        ]
        if eventPlayer.baseVector
        else null,
        eventPlayer.HUDData[2],
        eventPlayer.baseVector,
        1.5,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
        Color.WHITE,
        SpecVisibility.DEFAULT
    )

    # base description
    createInWorldText(
        [
            player
            for player in getAllPlayers().exclude(eventPlayer)
            if player.baseSettledIn != eventPlayer
            and not player.playerPrefs[prefsIndex.spectatorMode]
        ]
        if eventPlayer.baseVector
        else null,
        "{} {}'s base • {}".format(
            heroIcon(eventPlayer.getCurrentHero()), eventPlayer, eventPlayer.HUDData[3]
        ),
        eventPlayer.baseVector + Vector.UP * eventPlayer.playerPrefs[prefsIndex.baseRadius],
        1,
        Clip.SURFACES,
        WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR,
        rainbow()
        if eventPlayer.playerPrefs[prefsIndex.baseColor] > 14
        else COLORS[eventPlayer.playerPrefs[prefsIndex.baseColor]],
        SpecVisibility.DEFAULT
    )


rule " • end game":
    @Condition getMatchTime() <= 0

    wait(0.25, Wait.ABORT_WHEN_FALSE)

    declarePlayerVictory(null)

    if not createWorkshopSetting(
        bool, "match preferences", "disable play of the game", true, 3
    ):
        wait(10)

    restartMatch()


rule "loops":
    @Delimiter
    @Disabled


rule " • rainbow color":
    @Condition isGameInProgress()

    # * based on u/Halex000's RGB rainbow cycling HUD text (code CZ97D)
    ChaseColor(green, 255)
    ChaseColor(blue, 0)
    ChaseColor(red, 255)
    ChaseColor(green, 0)
    ChaseColor(blue, 255)
    ChaseColor(red, 0)

    goto RULE_START


rule " • reset circular pan camera angle":
    @Condition angle == -10000

    angle = 0


rule "player":
    @Delimiter
    @Disabled


rule " • kick banned player":
    @Event eachPlayer
    @Condition "{}".format(eventPlayer) in banList

    removeFromGame(eventPlayer)


rule " • on death":
    @Event playerDied

    eventPlayer.baseInRadiusOf = null
    eventPlayer.baseSettledIn = null

    # reset to chill mode if player dies in their own base
    if (
        not eventPlayer.playerPrefs[prefsIndex.chillMode]
        and eventPlayer.playerPrefs[prefsIndex.arenaMode]
    ):
        eventPlayer.playerPrefs[prefsIndex.chillMode] = true
        async(CalibrateHero, AsyncBehavior.RESTART)

    # instant respawn
    if eventPlayer.baseVector and eventPlayer.playerPrefs[prefsIndex.instantRespawn]:
        eventPlayer.respawn()

    waitUntil(eventPlayer.isAlive(), 99999)
    # teleport to base upon respawn if it exists
    if eventPlayer.baseVector:
        eventPlayer.teleport(eventPlayer.baseVector)
        eventPlayer.settleImmediately = true


rule " • on spawn":
    @Event eachPlayer
    @Condition eventPlayer.hasSpawned()

    if eventPlayer.baseVector:
        wait(0.1)

        # restore position and facing direction after hero switch
        if eventPlayer.lastPosDir:
            eventPlayer.teleport(eventPlayer.lastPosDir[0])
            eventPlayer.setFacing(eventPlayer.lastPosDir[1], Relativity.TO_WORLD)

            eventPlayer.lastPosDir = null
        else:
            eventPlayer.teleport(eventPlayer.baseVector)

        # immediately enter base
        eventPlayer.settleImmediately = true


rule " • spectator mode":
    @Event eachPlayer
    @Condition eventPlayer.playerPrefs[prefsIndex.spectatorMode]
    @Condition eventPlayer.focusedPlayer.isAlive()

    eventPlayer.focusedPlayer = random.choice(
        [
            player
            for player in getAllPlayers()
            if player.hasSpawned()
            and not player.keyboardMode
            and not (
                player.playerPrefs[prefsIndex.chillMode]
                and player.playerPrefs[prefsIndex.invisibility]
            )
        ]
    )

    CircularPanCam()

    waitUntil(
        not eventPlayer.playerPrefs[prefsIndex.spectatorMode]
        or not eventPlayer.focusedPlayer in getAllPlayers()
        or not eventPlayer.focusedPlayer.hasSpawned()
        or eventPlayer.focusedPlayer.keyboardMode
        or (
            eventPlayer.focusedPlayer.playerPrefs[prefsIndex.chillMode]
            and eventPlayer.focusedPlayer.playerPrefs[prefsIndex.invisibility]
        ),
        10
    )

    if RULE_CONDITION:
        goto RULE_START


rule " • keyboard mode":
    @Event eachPlayer
    @Condition eventPlayer.keyboardMode
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)

    eventPlayer.keyboardChar = [
        char
        for char in KEYBOARD_DATA
        if char[1]
        < angleDifference(
            horizontalAngleOfDirection(eventPlayer.lastPosDir[1]),
            eventPlayer.getHorizontalFacingAngle()
        )
        + char[3]
        + 1.25
        and char[1]
        > angleDifference(
            horizontalAngleOfDirection(eventPlayer.lastPosDir[1]),
            eventPlayer.getHorizontalFacingAngle()
        )
        - char[3]
        - 1.25
        and char[2]
        < angleDifference(
            verticalAngleOfDirection(eventPlayer.lastPosDir[1]),
            eventPlayer.getVerticalFacingAngle()
        )
        + 1.25
        and char[2]
        > angleDifference(
            verticalAngleOfDirection(eventPlayer.lastPosDir[1]),
            eventPlayer.getVerticalFacingAngle()
        )
        - 1.25
    ][0][0]

    if eventPlayer.keyboardChar:
        if eventPlayer.keyboardChar == "back":
            eventPlayer.playerPrefs[prefsIndex.customMessage] = eventPlayer.playerPrefs[
                prefsIndex.customMessage
            ].substring(
                0, strLen(eventPlayer.playerPrefs[prefsIndex.customMessage]) - 1
            )

            waitUntil(not eventPlayer.isHoldingButton(Button.PRIMARY_FIRE), 0.6)

            if eventPlayer.isHoldingButton(Button.PRIMARY_FIRE):
                eventPlayer.playerPrefs[prefsIndex.customMessage] = ""
        else:
            eventPlayer.playerPrefs[prefsIndex.customMessage] = "{}{}".format(
                eventPlayer.playerPrefs[prefsIndex.customMessage],
                eventPlayer.keyboardChar
            )


rule " • keyboard mode • cursor bounds":
    @Event eachPlayer
    @Condition eventPlayer.keyboardMode

    if (
        angleDifference(
            horizontalAngleOfDirection(eventPlayer.lastPosDir[1]),
            eventPlayer.getHorizontalFacingAngle()
        )
        > 43.5
    ):
        eventPlayer.setFacing(
            angleToDirection(
                horizontalAngleOfDirection(eventPlayer.lastPosDir[1]) + 43.5,
                eventPlayer.getVerticalFacingAngle()
            ),
            Relativity.TO_WORLD
        )
    if (
        angleDifference(
            horizontalAngleOfDirection(eventPlayer.lastPosDir[1]),
            eventPlayer.getHorizontalFacingAngle()
        )
        < -43.5
    ):
        eventPlayer.setFacing(
            angleToDirection(
                horizontalAngleOfDirection(eventPlayer.lastPosDir[1]) - 43.5,
                eventPlayer.getVerticalFacingAngle()
            ),
            Relativity.TO_WORLD
        )
    if (
        angleDifference(
            verticalAngleOfDirection(eventPlayer.lastPosDir[1]),
            eventPlayer.getVerticalFacingAngle()
        )
        > 27
    ):
        eventPlayer.setFacing(
            angleToDirection(
                eventPlayer.getHorizontalFacingAngle(),
                verticalAngleOfDirection(eventPlayer.lastPosDir[1]) + 27
            ),
            Relativity.TO_WORLD
        )
    if (
        angleDifference(
            verticalAngleOfDirection(eventPlayer.lastPosDir[1]),
            eventPlayer.getVerticalFacingAngle()
        )
        < -21.7
    ):
        eventPlayer.setFacing(
            angleToDirection(
                eventPlayer.getHorizontalFacingAngle(),
                verticalAngleOfDirection(eventPlayer.lastPosDir[1]) - 21.7
            ),
            Relativity.TO_WORLD
        )

    wait(0.1)

    if RULE_CONDITION:
        goto RULE_START


rule " • third-person mode • ADS":
    @Event eachPlayer
    @Condition eventPlayer.playerPrefs[prefsIndex.thirdPersonMode]
    @Condition (
        isCurrOrDupHero(Hero.ANA)
        or isCurrOrDupHero(Hero.ASHE)
        or isCurrOrDupHero(Hero.WIDOWMAKER)
    )
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)

    if (
        eventPlayer.isLookingAtCenterOrb
        or eventPlayer.modMode
        or eventPlayer.playerPrefs[prefsIndex.spectatorMode]
    ):
        return

    eventPlayer.stopCamera()

    waitUntil(
        not eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)
        or eventPlayer.isLookingAtCenterOrb
        or eventPlayer.modMode
        or eventPlayer.isDead(),
        99999
    )

    ResetCam()


rule "moderator":
    @Delimiter
    @Disabled


rule " • toggle moderator mode":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.CROUCH)
    @Condition eventPlayer.isHoldingButton(Button.RELOAD)

    # abort if player isn't a mod, on base creation mode, on keyboard mode or in spectator mode
    if (
        not eventPlayer in modList.concat(hostPlayer)
        or eventPlayer.baseCreationMode
        or eventPlayer.keyboardMode
        or eventPlayer.playerPrefs[prefsIndex.spectatorMode]
    ):
        return

    if eventPlayer.modMode:
        eventPlayer.modMode = false
        eventPlayer.focusedPlayer = null

        eventPlayer.allowButton(Button.PRIMARY_FIRE)
        eventPlayer.allowButton(Button.SECONDARY_FIRE)
        eventPlayer.allowButton(Button.MELEE)
        eventPlayer.allowButton(Button.ABILITY_1)
        eventPlayer.allowButton(Button.ABILITY_2)
        eventPlayer.allowButton(Button.JUMP)
        ResetCam()
    else:
        eventPlayer.modMode = true

        # focus on player closest to crosshair if there are any
        if eventPlayer.getPlayerClosestToReticle(Team.ALL):
            eventPlayer.focusedPlayer = eventPlayer.getPlayerClosestToReticle(Team.ALL)
        else:
            eventPlayer.focusedPlayer = getAllPlayers()[0]

        eventPlayer.disallowButton(Button.PRIMARY_FIRE)
        eventPlayer.disallowButton(Button.SECONDARY_FIRE)
        eventPlayer.disallowButton(Button.MELEE)
        eventPlayer.disallowButton(Button.ABILITY_1)
        eventPlayer.disallowButton(Button.ABILITY_2)
        eventPlayer.disallowButton(Button.JUMP)
        ThirdPersonSpectateCam()


rule " • switch focused player":
    @Event eachPlayer
    @Condition eventPlayer.modMode
    @Condition eventPlayer.isHoldingButton(
        Button.JUMP
    ) or not eventPlayer.focusedPlayer in getAllPlayers()

    # focus on player if the focused player leaves
    if not eventPlayer.focusedPlayer in getAllPlayers():
        eventPlayer.focusedPlayer = eventPlayer

        smallMessage(eventPlayer, "player left, switching to you.")
    # focus on first player if switching from last player
    elif (
        getNumberOfPlayers(Team.ALL) < getAllPlayers().index(eventPlayer.focusedPlayer)
        + 2
    ):
        eventPlayer.focusedPlayer = getAllPlayers()[0]
    # focus on next player
    else:
        eventPlayer.focusedPlayer = getAllPlayers()[
            getAllPlayers().index(eventPlayer.focusedPlayer) + 1
        ]

    ThirdPersonSpectateCam()


rule " • sleep player":
    @Event eachPlayer
    @Condition eventPlayer.modMode
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)

    # disable sleeping the host and moderators other than the player, dead players, and players that haven't spawned
    if (
        eventPlayer.focusedPlayer in modList.concat(hostPlayer).exclude(eventPlayer)
        or eventPlayer.focusedPlayer.isDead()
        or not eventPlayer.focusedPlayer.hasSpawned()
    ):
        DebuffPlayerOnFocus()
        smallMessage(eventPlayer, "you can't sleep this player!")
    else:
        # temporarily disable base protection if needed
        if eventPlayer.focusedPlayer.hasStatusEffect(Status.PHASED_OUT):
            eventPlayer.focusedPlayer.clearStatusEffect(Status.PHASED_OUT)
            eventPlayer.focusedPlayer.setStatusEffect(null, Status.ASLEEP, 10)
            eventPlayer.focusedPlayer.setStatusEffect(null, Status.PHASED_OUT, 99999)
        else:
            eventPlayer.focusedPlayer.setStatusEffect(null, Status.ASLEEP, 10)

        DebuffFocusOnFocus()

        if eventPlayer.focusedPlayer != eventPlayer:
            bigMessage(
                eventPlayer.focusedPlayer, "you were put to sleep by a moderator."
            )

        bigMessage(eventPlayer, "player put to sleep for 10 seconds!")

    wait(1)

rule " • kill player":
    @Event eachPlayer
    @Condition eventPlayer.modMode
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)

    # disable killing the host and moderators other than the player, dead players, and players that haven't spawned
    if (
        eventPlayer.focusedPlayer in modList.concat(hostPlayer).exclude(eventPlayer)
        or eventPlayer.focusedPlayer.isDead()
        or not eventPlayer.focusedPlayer.hasSpawned()
    ):
        DebuffPlayerOnFocus()
        smallMessage(eventPlayer, "you can't kill this player!")
    else:
        # temporarily reset damage received if player is on chill mode
        if eventPlayer.focusedPlayer.playerPrefs[prefsIndex.chillMode]:
            eventPlayer.focusedPlayer.setDamageReceived(100)

        # temporarily disable base protection if needed
        if eventPlayer.focusedPlayer.hasStatusEffect(Status.PHASED_OUT):
            eventPlayer.focusedPlayer.clearStatusEffect(Status.PHASED_OUT)
            kill(eventPlayer.focusedPlayer, null)
            eventPlayer.focusedPlayer.setStatusEffect(null, Status.PHASED_OUT, 99999)
        else:
            kill(eventPlayer.focusedPlayer, null)

        if eventPlayer.focusedPlayer.playerPrefs[prefsIndex.chillMode]:
            eventPlayer.focusedPlayer.setDamageReceived(0)

        DebuffFocusOnFocus()

        if eventPlayer.focusedPlayer != eventPlayer:
            bigMessage(eventPlayer.focusedPlayer, "you were killed by a moderator.")

        bigMessage(eventPlayer, "player killed successfully!")

    wait(1)


rule " • delete base":
    @Event eachPlayer
    @Condition eventPlayer.modMode
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1)
    @Condition not eventPlayer.isHoldingButton(Button.MELEE)

    # disable deleting bases of the host and moderators other than the player
    if eventPlayer.focusedPlayer in modList.concat(hostPlayer).exclude(eventPlayer):
        DebuffPlayerOnFocus()
        smallMessage(
            eventPlayer,
            "you can't delete the host's/moderators' bases other than your own."
        )
    elif not eventPlayer.focusedPlayer.baseVector:
        DebuffPlayerOnFocus()
        smallMessage(eventPlayer, "this player doesn't have a base.")
    else:
        progressBarHud(
            eventPlayer,
            eventPlayer.modActionProgress,
            "deleting {} {}'s base...".format(
                heroIcon(eventPlayer.focusedPlayer.getCurrentHero()),
                eventPlayer.focusedPlayer
            ),
            HudPosition.TOP,
            2,
            Color.RED,
            Color.WHITE,
            ProgressHudReeval.VALUES,
            SpecVisibility.DEFAULT
        )

        eventPlayer.modProgressEntity = getLastCreatedText()
        chase(eventPlayer.modActionProgress, 100, duration = 0.6, ChaseReeval.NONE)

        waitUntil(
            eventPlayer.modActionProgress == 100
            or not eventPlayer.isHoldingButton(Button.ABILITY_1)
            or not eventPlayer.focusedPlayer.baseVector,
            0.6
        )

        if eventPlayer.modActionProgress == 100:
            # disable arena mode and base lock
            eventPlayer.focusedPlayer.playerPrefs[prefsIndex.arenaMode] = false
            eventPlayer.focusedPlayer.playerPrefs[prefsIndex.baseLock] = false
            eventPlayer.focusedPlayer.baseInRadiusOf = null
            eventPlayer.focusedPlayer.baseSettledIn = null
            eventPlayer.focusedPlayer.baseVector = null

            DebuffFocusOnFocus()

            if eventPlayer.focusedPlayer != eventPlayer:
                bigMessage(
                    eventPlayer.focusedPlayer, "your base was deleted by a moderator."
                )
            bigMessage(eventPlayer, "base deleted successfully!")

        destroyProgressBarHud(eventPlayer.modProgressEntity)
        stopChasingVariable(eventPlayer.modActionProgress)

        eventPlayer.modActionProgress = 0

    wait(1)


rule " • ban player":
    @Event eachPlayer
    @Condition eventPlayer.modMode
    @Condition eventPlayer.isHoldingButton(Button.MELEE)
    @Condition not eventPlayer.isHoldingButton(Button.ABILITY_1)

    # disable banning host and moderators
    if eventPlayer.focusedPlayer in modList.concat(hostPlayer):
        DebuffPlayerOnFocus()
        smallMessage(eventPlayer, "you can't ban the host / moderators.")
    else:
        # ! store focused player's name in case they leave during banning
        eventPlayer.playerToBan = "{}".format(eventPlayer.focusedPlayer)

        progressBarHud(
            eventPlayer,
            eventPlayer.modActionProgress,
            "banning {}...".format(eventPlayer.playerToBan),
            HudPosition.TOP,
            2,
            Color.RED,
            Color.WHITE,
            ProgressHudReeval.VALUES,
            SpecVisibility.DEFAULT
        )

        eventPlayer.modProgressEntity = getLastCreatedText()

        chase(eventPlayer.modActionProgress, 100, duration = 1.5, ChaseReeval.NONE)

        waitUntil(
            eventPlayer.modActionProgress == 100
            or not eventPlayer.isHoldingButton(Button.MELEE),
            1.5
        )

        if eventPlayer.modActionProgress == 100:
            banList.append(eventPlayer.playerToBan)

            DebuffPlayerOnFocus()
            bigMessage(eventPlayer, "player banned succesfully!")

        destroyProgressBarHud(eventPlayer.modProgressEntity)
        stopChasingVariable(eventPlayer.modActionProgress)

        eventPlayer.modActionProgress = 0
        eventPlayer.playerToBan = null

    wait(1)


rule " • promote / demote player":
    @Event eachPlayer
    @Condition eventPlayer.modMode
    @Condition eventPlayer == hostPlayer
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2)

    # disable promotion / demotion of the host
    if eventPlayer.focusedPlayer == hostPlayer:
        DebuffPlayerOnFocus()
        smallMessage(eventPlayer, "you can't promote / demote yourself.")
    elif eventPlayer.focusedPlayer in modList:
        modList.remove(eventPlayer.focusedPlayer)

        DebuffFocusOnFocus()
        smallMessage(eventPlayer, "player demoted succesfully!")
        bigMessage(eventPlayer.focusedPlayer, "you were demoted.")
    else:
        modList.append(eventPlayer.focusedPlayer)

        BuffFocusOnFocus()
        smallMessage(eventPlayer, "player promoted to moderator succesfully!")
        bigMessage(eventPlayer.focusedPlayer, "you were promoted to moderator!")

    wait(1)


rule "base":
    @Delimiter
    @Disabled


rule " • base preparation":
    @Event eachPlayer
    @Condition not eventPlayer.baseVector
    @Condition eventPlayer.isHoldingButton(Button.INTERACT)

    if eventPlayer.baseCreationMode:
        eventPlayer.baseCreationMode = false

        eventPlayer.allowButton(Button.PRIMARY_FIRE)
    else:
        chase(eventPlayer.baseCreationProgress, 100, duration = 0.6, ChaseReeval.NONE)

        # cancel base preparation on death or moderator mode
        waitUntil(
            eventPlayer.baseCreationProgress == 100
            or not eventPlayer.isHoldingButton(Button.INTERACT)
            or eventPlayer.isDead()
            or eventPlayer.modMode,
            0.6
        )

        if eventPlayer.baseCreationProgress == 100:
            # reset base radius
            eventPlayer.playerPrefs[prefsIndex.baseRadius] = defaultPrefs[
                prefsIndex.baseRadius
            ]
            eventPlayer.baseRadiusPrev = eventPlayer.playerPrefs[prefsIndex.baseRadius]
            eventPlayer.baseCreationMode = true

            eventPlayer.disallowButton(Button.PRIMARY_FIRE)

        stopChasingVariable(eventPlayer.baseCreationProgress)

        eventPlayer.baseCreationProgress = 0


rule " • base creation":
    @Event eachPlayer
    @Condition eventPlayer.baseCreationMode
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)

    if any(
        [
            player.baseVector
            and distance(eventPlayer.getPosition(), player.baseVector)
            <= player.playerPrefs[prefsIndex.baseRadius]
            + eventPlayer.playerPrefs[prefsIndex.baseRadius]
            for player in getAllPlayers()
        ]
    ):
        DebuffPlayer()
        smallMessage(eventPlayer, "bases can't overlap!")
    else:
        if eventPlayer.isInAir():
            if createWorkshopSetting(
                bool, "game preferences", "allow floating bases", true, 1
            ):
                StopMomentum()

                if createWorkshopSetting(
                    bool,
                    "game preferences",
                    "adjust floating bases automatically (disable gravity, enable base lock)",
                    false,
                    2
                ):
                    eventPlayer.playerPrefs[prefsIndex.inBaseGravity] = 0
                    eventPlayer.playerPrefs[prefsIndex.baseLock] = true

                    smallMessage(
                        eventPlayer,
                        "you created a floating base: gravity is disabled and base lock is enabled."
                    )
            else:
                DebuffPlayer()
                smallMessage(eventPlayer, "floating bases are not allowed!")

                return

        eventPlayer.baseVector = eventPlayer.getPosition()

        eventPlayer.settleImmediately = true
        eventPlayer.baseCreationMode = false

        eventPlayer.allowButton(Button.PRIMARY_FIRE)

        # display tips
        bigMessage(eventPlayer, "you have successfully created your base!")


rule " • base creation • third-person mode quick switch":
    @Disabled
    @Event eachPlayer
    @Condition eventPlayer.baseCreationMode
    @Condition eventPlayer.isHoldingButton(Button.RELOAD)

    if eventPlayer.playerPrefs[prefsIndex.thirdPersonMode]:
        eventPlayer.playerPrefs[prefsIndex.thirdPersonMode] = false
    else:
        eventPlayer.playerPrefs[prefsIndex.thirdPersonMode] = true

    ResetCam()


rule " • base detection / confinement":
    @Event eachPlayer
    @Condition isInDifferentBase()

    # don't let the dogs out
    if isConfined():
        async(Confine, AsyncBehavior.RESTART)
        return

    eventPlayer.baseInRadiusOf = (
        [
            player
            for player in getAllPlayers()
            if player.baseVector
            and eventPlayer
            in getPlayersInRadius(
                player.baseVector,
                player.playerPrefs[prefsIndex.baseRadius],
                Team.ALL,
                LosCheck.OFF
            )
        ]
    )[0]

    async(CalibrateHero, AsyncBehavior.RESTART)


rule " • base settlement / mode change":
    @Event eachPlayer
    @Condition (
        eventPlayer.baseInRadiusOfPrev != eventPlayer.baseInRadiusOf
        or eventPlayer.baseModePrev
        != eventPlayer.baseInRadiusOf.playerPrefs[prefsIndex.baseMode]
        or eventPlayer.arenaModePrev
        != eventPlayer.baseInRadiusOf.playerPrefs[prefsIndex.arenaMode]
    )

    eventPlayer.baseInRadiusOfPrev = eventPlayer.baseInRadiusOf
    eventPlayer.baseModePrev = eventPlayer.baseInRadiusOf.playerPrefs[
        prefsIndex.baseMode
    ]
    eventPlayer.arenaModePrev = eventPlayer.baseInRadiusOf.playerPrefs[
        prefsIndex.arenaMode
    ]

    # subroutines are split for better runtime at the cost of repetitive actions a.k.a element count
    if eventPlayer.baseInRadiusOf == eventPlayer:
        # don't re-enter base when changing modes
        if eventPlayer.baseSettledIn == eventPlayer:
            return

        async(SettleInOwnBase, AsyncBehavior.RESTART)
    elif eventPlayer.baseInRadiusOf.playerPrefs[prefsIndex.arenaMode]:
        async(SettleInArena, AsyncBehavior.RESTART)
    else:
        switch eventPlayer.baseInRadiusOf.playerPrefs[prefsIndex.baseMode]:
            case 1:
            case 2:
                async(SettleInFriendlyBase, AsyncBehavior.RESTART)
                break
            case 3:
                async(SettleInExclusiveBase, AsyncBehavior.RESTART)
                break

    eventPlayer.baseSettledIn = null


rule " • arena forfeit":
    @Event eachPlayer
    @Condition eventPlayer.baseSettledIn.playerPrefs[prefsIndex.arenaMode]
    @Condition eventPlayer.isHoldingButton(Button.MELEE)

    # disable forfeit in player's own arena and in moderator mode
    if eventPlayer.baseSettledIn == eventPlayer or eventPlayer.modMode:
        return

    eventPlayer.holdMeleeText = "forfeiting..."
    eventPlayer.holdMeleeColor = Color.RED

    chase(eventPlayer.holdMeleeProgress, 100, duration = 3, ChaseReeval.NONE)

    waitUntil(
        eventPlayer.holdMeleeProgress == 100
        or not eventPlayer.isHoldingButton(Button.MELEE)
        or eventPlayer.baseSettledIn == eventPlayer
        or eventPlayer.modMode,
        3
    )

    if eventPlayer.holdMeleeProgress == 100:
        kill(eventPlayer, null)

    stopChasingVariable(eventPlayer.holdMeleeProgress)

    eventPlayer.holdMeleeProgress = 0


rule " • stop arena damage modification":
    @Event eachPlayer
    @Condition not eventPlayer.baseSettledIn.playerPrefs[prefsIndex.arenaMode]

    ArenaDamageModification()


rule " • fast travel":
    @Event eachPlayer
    @Condition eventPlayer.playerPrefs[prefsIndex.chillMode]
    @Condition eventPlayer.playerPrefs[prefsIndex.fastTravel]
    @Condition eventPlayer.isHoldingButton(Button.MELEE)

    # disable fast travel in moderator mode, keyboard mode or spectator mode
    if (
        eventPlayer.modMode
        or eventPlayer.keyboardMode
        or eventPlayer.playerPrefs[prefsIndex.spectatorMode]
    ):
        return

    eventPlayer.baseToFastTravelTo = [
        player
        for player in getAllPlayers()
        .exclude(eventPlayer)
        .exclude(eventPlayer.baseInRadiusOf)
        if player.baseVector and player.playerPrefs[prefsIndex.baseMode] == 2
        and not player.playerPrefs[prefsIndex.arenaMode]
        and distance(
            eventPlayer.getEyePosition()
            + distance(eventPlayer.getEyePosition(), player.baseVector)
            * eventPlayer.getFacingDirection(),
            player.baseVector
        )
        <= player.playerPrefs[prefsIndex.baseRadius]
    ][0]

    if eventPlayer.baseToFastTravelTo:
        eventPlayer.holdMeleeText = "fast traveling to {} {}'s base...".format(
            heroIcon(eventPlayer.baseToFastTravelTo.getCurrentHero()),
            eventPlayer.baseToFastTravelTo
        )

        if eventPlayer.baseToFastTravelTo.playerPrefs[prefsIndex.baseColor] > 14:
            eventPlayer.holdMeleeColor = -1
        else:
            eventPlayer.holdMeleeColor = COLORS[
                eventPlayer.baseToFastTravelTo.playerPrefs[prefsIndex.baseColor]
            ]
    elif eventPlayer.baseVector and eventPlayer.baseInRadiusOf != eventPlayer:
        eventPlayer.baseToFastTravelTo = eventPlayer

        eventPlayer.holdMeleeText = "fast traveling to your base..."

        if eventPlayer.playerPrefs[prefsIndex.baseColor] > 14:
            eventPlayer.holdMeleeColor = -1
        else:
            eventPlayer.holdMeleeColor = COLORS[
                eventPlayer.playerPrefs[prefsIndex.baseColor]
            ]
    else:
        return

    chase(eventPlayer.holdMeleeProgress, 100, duration = 0.6, ChaseReeval.NONE)

    waitUntil(
        eventPlayer.holdMeleeProgress == 100
        or not eventPlayer.isHoldingButton(Button.MELEE)
        or (
            eventPlayer.baseToFastTravelTo != eventPlayer
            and (
                eventPlayer.baseToFastTravelTo.playerPrefs[prefsIndex.baseMode] != 2
                or eventPlayer.playerPrefs[prefsIndex.arenaMode]
            )
        )
        or not eventPlayer.baseToFastTravelTo.baseVector
        or eventPlayer
        in getPlayersInRadius(
            eventPlayer.baseToFastTravelTo.baseVector,
            eventPlayer.baseToFastTravelTo.playerPrefs[prefsIndex.baseRadius],
            Team.ALL,
            LosCheck.OFF
        )
        or eventPlayer.isDead(),
        0.6
    )

    if eventPlayer.holdMeleeProgress == 100:
        eventPlayer.settleImmediately = true

        eventPlayer.teleport(eventPlayer.baseToFastTravelTo.baseVector)

    stopChasingVariable(eventPlayer.holdMeleeProgress)

    eventPlayer.holdMeleeProgress = 0


rule "preferences":
    @Delimiter
    @Disabled


rule " • toggle preferences":
    @Event eachPlayer
    @Condition eventPlayer.baseSettledIn == eventPlayer
    @Condition distance(
        eventPlayer.getEyePosition()
        + distance(eventPlayer.getEyePosition(), eventPlayer.baseVector)
        * eventPlayer.getFacingDirection(),
        eventPlayer.baseVector
    ) <= CENTER_ORB_RADIUS

    # disable preferences in moderator mode, keyboard mode or spectator mode
    if (
        eventPlayer.modMode
        or eventPlayer.keyboardMode
        or eventPlayer.playerPrefs[prefsIndex.spectatorMode]
    ):
        return

    eventPlayer.isLookingAtCenterOrb = true

    eventPlayer.disallowButton(Button.PRIMARY_FIRE)
    eventPlayer.disallowButton(Button.SECONDARY_FIRE)
    eventPlayer.disallowButton(Button.MELEE)
    eventPlayer.disallowButton(Button.CROUCH)
    eventPlayer.disallowButton(Button.ABILITY_1)
    eventPlayer.disallowButton(Button.ABILITY_2)
    eventPlayer.disallowButton(Button.INTERACT)
    eventPlayer.disallowButton(Button.RELOAD)
    UpdatePrefsHUD()

    # get out of preferences if player leaves base, if player emotes, on keyboard mode or on spectator mode
    waitUntil(
        distance(
            eventPlayer.getEyePosition()
            + distance(eventPlayer.getEyePosition(), eventPlayer.baseVector)
            * eventPlayer.getFacingDirection(),
            eventPlayer.baseVector
        )
        > CENTER_ORB_RADIUS
        or eventPlayer.baseSettledIn != eventPlayer
        or eventPlayer.isCommunicatingEmote()
        or eventPlayer.keyboardMode
        or eventPlayer.playerPrefs[prefsIndex.spectatorMode],
        99999
    )

    eventPlayer.isLookingAtCenterOrb = false

    if not eventPlayer.keyboardMode:
        eventPlayer.allowButton(Button.PRIMARY_FIRE)
    eventPlayer.allowButton(Button.SECONDARY_FIRE)
    eventPlayer.allowButton(Button.MELEE)
    eventPlayer.allowButton(Button.CROUCH)
    eventPlayer.allowButton(Button.ABILITY_1)
    eventPlayer.allowButton(Button.ABILITY_2)
    eventPlayer.allowButton(Button.INTERACT)
    eventPlayer.allowButton(Button.RELOAD)


rule " • jump preferences":
    @Event eachPlayer
    @Condition eventPlayer.isLookingAtCenterOrb
    @Condition eventPlayer.isHoldingButton(Button.MELEE)

    if eventPlayer.prefsType:
        return

    if eventPlayer.prefsPage < prefsIndex.heroOutlineColor:
        eventPlayer.prefsPage = prefsIndex.heroOutlineColor
    elif eventPlayer.prefsPage < prefsIndex.baseMode:
        eventPlayer.prefsPage = prefsIndex.baseMode
    else:
        eventPlayer.prefsPage = 0

    ExplodeBase()
    BuffPlayer()
    UpdatePrefsHUD()


rule " • next item":
    @Event eachPlayer
    @Condition eventPlayer.isLookingAtCenterOrb
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)

    if eventPlayer.prefsPage < len(PREFS_TITLES[eventPlayer.prefsType]) - 1:
        eventPlayer.prefsPage += 1
    else:
        eventPlayer.prefsPage = 0

    UpdatePrefsHUD()


rule " • previous item":
    @Event eachPlayer
    @Condition eventPlayer.isLookingAtCenterOrb
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)

    if eventPlayer.prefsPage > 0:
        eventPlayer.prefsPage -= 1
    else:
        eventPlayer.prefsPage = len(PREFS_TITLES[eventPlayer.prefsType]) - 1

    UpdatePrefsHUD()


rule " • next option / increase":
    @Event eachPlayer
    @Condition eventPlayer.isLookingAtCenterOrb
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2)
    @Condition not eventPlayer.isHoldingButton(Button.ABILITY_1)

    if PREFS_DATA[eventPlayer.prefsType][eventPlayer.prefsPage][1] == 0:
        if (
            eventPlayer.playerPrefs[eventPlayer.prefsPage]
            < len(PREFS_DATA[eventPlayer.prefsType][eventPlayer.prefsPage][3]) - 1
        ):
            eventPlayer.playerPrefs[eventPlayer.prefsPage] += 1
        else:
            eventPlayer.playerPrefs[eventPlayer.prefsPage] = 0

        PrefsInteract()
    elif PREFS_DATA[eventPlayer.prefsType][eventPlayer.prefsPage][1] == 2:
        if eventPlayer.isHoldingButton(Button.CROUCH):
            eventPlayer.playerPrefs[eventPlayer.prefsPage] = PREFS_DATA[
                eventPlayer.prefsType
            ][eventPlayer.prefsPage][3][1]

            PrefsInteract()
            goto max
        elif (
            eventPlayer.playerPrefs[eventPlayer.prefsPage]
            < PREFS_DATA[eventPlayer.prefsType][eventPlayer.prefsPage][3][1]
        ):
            eventPlayer.playerPrefs[eventPlayer.prefsPage] += PREFS_DATA[
                eventPlayer.prefsType
            ][eventPlayer.prefsPage][3][2]

            PrefsInteract()
        else:
            max:
            ExplodeBase()
            BuffPlayer()
            return

    UpdatePrefsHUD()

    if not eventPlayer.isHoldingToAdjustPrefs:
        waitUntil(not eventPlayer.isHoldingButton(Button.ABILITY_2), 0.6)

    if eventPlayer.isHoldingButton(Button.ABILITY_2):
        if not eventPlayer.isHoldingToAdjustPrefs:
            eventPlayer.isHoldingToAdjustPrefs = true
    else:
        if eventPlayer.isHoldingToAdjustPrefs:
            eventPlayer.isHoldingToAdjustPrefs = false
        return

    wait(0.12)

    goto RULE_START


rule " • previous option / decrease":
    @Event eachPlayer
    @Condition eventPlayer.isLookingAtCenterOrb
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1)
    @Condition not eventPlayer.isHoldingButton(Button.ABILITY_2)

    if PREFS_DATA[eventPlayer.prefsType][eventPlayer.prefsPage][1] == 0:
        if eventPlayer.playerPrefs[eventPlayer.prefsPage] > 0:
            eventPlayer.playerPrefs[eventPlayer.prefsPage] -= 1
        else:
            eventPlayer.playerPrefs[eventPlayer.prefsPage] = (
                len(PREFS_DATA[eventPlayer.prefsType][eventPlayer.prefsPage][3]) - 1
            )
        PrefsInteract()
    elif PREFS_DATA[eventPlayer.prefsType][eventPlayer.prefsPage][1] == 2:
        if eventPlayer.isHoldingButton(Button.CROUCH):
            eventPlayer.playerPrefs[eventPlayer.prefsPage] = PREFS_DATA[
                eventPlayer.prefsType
            ][eventPlayer.prefsPage][3][0]

            PrefsInteract()
            goto min
        elif (
            eventPlayer.playerPrefs[eventPlayer.prefsPage]
            > PREFS_DATA[eventPlayer.prefsType][eventPlayer.prefsPage][3][0]
        ):
            eventPlayer.playerPrefs[eventPlayer.prefsPage] -= PREFS_DATA[
                eventPlayer.prefsType
            ][eventPlayer.prefsPage][3][2]

            PrefsInteract()
        else:
            min:
            ExplodeBase()
            DebuffPlayer()
            return

    UpdatePrefsHUD()

    if not eventPlayer.isHoldingToAdjustPrefs:
        waitUntil(not eventPlayer.isHoldingButton(Button.ABILITY_1), 0.6)

    if eventPlayer.isHoldingButton(Button.ABILITY_1):
        if not eventPlayer.isHoldingToAdjustPrefs:
            eventPlayer.isHoldingToAdjustPrefs = true
    else:
        if eventPlayer.isHoldingToAdjustPrefs:
            eventPlayer.isHoldingToAdjustPrefs = false
        return

    wait(0.12)

    goto RULE_START


rule " • reset option":
    @Event eachPlayer
    @Condition eventPlayer.isLookingAtCenterOrb
    @Condition eventPlayer.isHoldingButton(Button.RELOAD)

    if (
        PREFS_DATA[eventPlayer.prefsType][eventPlayer.prefsPage][1] == 0
        or PREFS_DATA[eventPlayer.prefsType][eventPlayer.prefsPage][1] == 2
    ):
        eventPlayer.playerPrefs[eventPlayer.prefsPage] = defaultPrefs[
            eventPlayer.prefsPage
        ]

        ExplodeBase()
        BuffPlayer()
        PrefsInteract()


rule " • toggle option / interact":
    @Event eachPlayer
    @Condition eventPlayer.isLookingAtCenterOrb
    @Condition eventPlayer.isHoldingButton(Button.INTERACT)

    switch PREFS_DATA[eventPlayer.prefsType][eventPlayer.prefsPage][1]:
        case 1:
            if eventPlayer.playerPrefs[eventPlayer.prefsPage]:
                eventPlayer.playerPrefs[eventPlayer.prefsPage] = false
            else:
                eventPlayer.playerPrefs[eventPlayer.prefsPage] = true

            PrefsInteract()
            break
        case 3:
            PrefsInteract()
            break
        case 4:
        case 6:
            chase(
                eventPlayer.prefsInteractProgress,
                100,
                duration = PREFS_DATA[eventPlayer.prefsType][eventPlayer.prefsPage][3],
                ChaseReeval.DESTINATION_AND_DURATION
            )

            waitUntil(
                eventPlayer.prefsInteractProgress == 100
                or not eventPlayer.isHoldingButton(Button.INTERACT)
                or not eventPlayer.isLookingAtCenterOrb,
                PREFS_DATA[eventPlayer.prefsType][eventPlayer.prefsPage][3]
            )

            if eventPlayer.prefsInteractProgress == 100:
                PrefsInteract()

            stopChasingVariable(eventPlayer.prefsInteractProgress)

            eventPlayer.prefsInteractProgress = 0
            break
        case 5:
            if eventPlayer.playerPrefs[
                PREFS_DATA[eventPlayer.prefsType][eventPlayer.prefsPage][3]
            ]:
                eventPlayer.playerPrefs[
                    PREFS_DATA[eventPlayer.prefsType][eventPlayer.prefsPage][3]
                ] = false
            else:
                eventPlayer.playerPrefs[
                    PREFS_DATA[eventPlayer.prefsType][eventPlayer.prefsPage][3]
                ] = true

            PrefsInteract()
            break


rule "hero":
    @Delimiter
    @Disabled


rule " • no cooldowns • primary fire":
    @Event eachPlayer
    @Condition eventPlayer.playerPrefs[prefsIndex.chillMode]
    @Condition eventPlayer.playerPrefs[prefsIndex.noCooldowns]
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)

    eventPlayer.setAbilityCooldown(Button.PRIMARY_FIRE, 0)
    wait()


rule " • no cooldowns • primary fire (moira)":
    @Event eachPlayer
    @Condition eventPlayer.playerPrefs[prefsIndex.chillMode]
    @Condition eventPlayer.playerPrefs[prefsIndex.noCooldowns]
    @Condition isCurrOrDupHero(Hero.MOIRA)
    @Condition eventPlayer.getAbilityResource(Button.PRIMARY_FIRE) < 10

    eventPlayer.setAbilityResource(Button.PRIMARY_FIRE, 100)


rule " • no cooldowns • secondary fire":
    @Event eachPlayer
    @Condition eventPlayer.playerPrefs[prefsIndex.chillMode]
    @Condition eventPlayer.playerPrefs[prefsIndex.noCooldowns]
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)

    if isCurrOrDupHero(Hero.SIGMA):
        wait(0.15)

    eventPlayer.setAbilityCooldown(Button.SECONDARY_FIRE, 0)

    switch eventPlayer.getCurrentHero():
        case Hero.BASTION:
            eventPlayer.cancelPrimaryAction()

    switch eventPlayer.getHeroOfDuplication():
        case Hero.BASTION:
            eventPlayer.cancelPrimaryAction()

rule " • no cooldowns • secondary fire (d.va)":
    @Event eachPlayer
    @Condition eventPlayer.playerPrefs[prefsIndex.chillMode]
    @Condition eventPlayer.playerPrefs[prefsIndex.noCooldowns]
    @Condition isCurrOrDupHero(Hero.DVA)
    @Condition eventPlayer.getAbilityResource(Button.SECONDARY_FIRE) < 10

    eventPlayer.setAbilityResource(Button.SECONDARY_FIRE, 100)


rule " • no cooldowns • ability 1":
    @Event eachPlayer
    @Condition eventPlayer.playerPrefs[prefsIndex.chillMode]
    @Condition eventPlayer.playerPrefs[prefsIndex.noCooldowns]
    @Condition eventPlayer.getAbilityCooldown(Button.ABILITY_1) > 0

    eventPlayer.setAbilityCooldown(Button.ABILITY_1, 0)


rule " • no cooldowns • ability 1 (tracer, symmetra)":
    @Event eachPlayer
    @Condition eventPlayer.playerPrefs[prefsIndex.chillMode]
    @Condition eventPlayer.playerPrefs[prefsIndex.noCooldowns]
    @Condition isCurrOrDupHero(Hero.TRACER) or isCurrOrDupHero(Hero.SYMMETRA)
    @Condition eventPlayer.getAbilityCharge(Button.ABILITY_1) < 3

    eventPlayer.setAbilityCharge(Button.ABILITY_1, 3)


rule " • no cooldowns • ability 1 (junkrat, zarya)":
    @Event eachPlayer
    @Condition eventPlayer.playerPrefs[prefsIndex.chillMode]
    @Condition eventPlayer.playerPrefs[prefsIndex.noCooldowns]
    @Condition isCurrOrDupHero(Hero.ZARYA) or isCurrOrDupHero(Hero.JUNKRAT)
    @Condition eventPlayer.getAbilityCharge(Button.ABILITY_1) < 2

    eventPlayer.setAbilityCharge(Button.ABILITY_1, 2)


rule " • no cooldowns • ability 2":
    @Event eachPlayer
    @Condition eventPlayer.playerPrefs[prefsIndex.chillMode]
    @Condition eventPlayer.playerPrefs[prefsIndex.noCooldowns]
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2)

    eventPlayer.setAbilityCooldown(Button.ABILITY_2, 0)

    switch eventPlayer.getCurrentHero():
        case Hero.MOIRA:
            waitUntil(
                eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)
                or eventPlayer.isHoldingButton(Button.SECONDARY_FIRE),
                99999
            )
        case Hero.ASHE:
        case Hero.PHARAH:
        case Hero.KIRIKO:
        case Hero.SOJOURN:
            wait(0.2)

    switch eventPlayer.getHeroOfDuplication():
        case Hero.MOIRA:
            waitUntil(
                eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)
                or eventPlayer.isHoldingButton(Button.SECONDARY_FIRE),
                99999
            )
        case Hero.ASHE:
        case Hero.PHARAH:
        case Hero.KIRIKO:
        case Hero.SOJOURN:  
            wait(0.2)

    switch eventPlayer.getCurrentHero():
        case Hero.ANA:
        case Hero.MCCREE:
        case Hero.SOLDIER:
        case Hero.BAPTISTE:
        case Hero.MOIRA:
        case Hero.ASHE:
        case Hero.JUNKRAT:
        case Hero.PHARAH:
        case Hero.KIRIKO:
        case Hero.SOJOURN:
            eventPlayer.cancelPrimaryAction()

    switch eventPlayer.getHeroOfDuplication():
        case Hero.ANA:
        case Hero.MCCREE:
        case Hero.SOLDIER:
        case Hero.BAPTISTE:
        case Hero.MOIRA:
        case Hero.ASHE:
        case Hero.JUNKRAT:
        case Hero.PHARAH:
        case Hero.KIRIKO:
        case Hero.SOJOURN:
            eventPlayer.cancelPrimaryAction()


rule " • no cooldowns • ability 2 (zarya, reinhardt)":
    @Event eachPlayer
    @Condition eventPlayer.playerPrefs[prefsIndex.chillMode]
    @Condition eventPlayer.playerPrefs[prefsIndex.noCooldowns]
    @Condition isCurrOrDupHero(Hero.ZARYA) or isCurrOrDupHero(Hero.REINHARDT)
    @Condition eventPlayer.getAbilityCharge(Button.ABILITY_2) < 2

    eventPlayer.setAbilityCharge(Button.ABILITY_2, 2)


rule " • no cooldowns • crouch":
    @Event eachPlayer
    @Condition eventPlayer.playerPrefs[prefsIndex.chillMode]
    @Condition eventPlayer.playerPrefs[prefsIndex.noCooldowns]
    @Condition eventPlayer.isHoldingButton(Button.CROUCH)

    eventPlayer.setAbilityCooldown(Button.CROUCH, 0)


rule " • no cooldowns • interact":
    @Disabled
    @Event eachPlayer
    @Condition eventPlayer.playerPrefs[prefsIndex.chillMode]
    @Condition eventPlayer.playerPrefs[prefsIndex.noCooldowns]
    @Condition eventPlayer.isHoldingButton(Button.INTERACT)

    eventPlayer.setAbilityCooldown(Button.INTERACT, 0)


rule " • no cooldowns • jump":
    @Disabled
    @Event eachPlayer
    @Condition eventPlayer.playerPrefs[prefsIndex.chillMode]
    @Condition eventPlayer.playerPrefs[prefsIndex.noCooldowns]
    @Condition eventPlayer.isHoldingButton(Button.JUMP)

    eventPlayer.setAbilityCooldown(Button.JUMP, 0)


rule " • fast ultimate":
    @Event eachPlayer
    @Condition eventPlayer.playerPrefs[prefsIndex.chillMode]
    @Condition eventPlayer.playerPrefs[prefsIndex.fastUltimate]
    @Condition (
        eventPlayer.getUltCharge() < 100 or eventPlayer.isHoldingButton(Button.ULTIMATE)
    )

    if eventPlayer.getUltCharge() < 100 / 3:
        eventPlayer.setUltCharge(100 / 3)

        wait(1, Wait.ABORT_WHEN_FALSE)

    if eventPlayer.getUltCharge() < 200 / 3:
        eventPlayer.setUltCharge(200 / 3)

        wait(1, Wait.ABORT_WHEN_FALSE)

    eventPlayer.setUltCharge(100)
    wait(0.5)

    if RULE_CONDITION:
        goto RULE_START


rule " • fast reload":
    @Event eachPlayer
    @Condition eventPlayer.playerPrefs[prefsIndex.chillMode]
    @Condition eventPlayer.playerPrefs[prefsIndex.fastReload]
    @Condition eventPlayer.getAmmo(0) == 0 or eventPlayer.getAmmo(1) == 0

    eventPlayer.setAmmo(0, eventPlayer.getMaxAmmo(0))
    eventPlayer.setAmmo(1, eventPlayer.getMaxAmmo(1))


rule "subroutines":
    @Delimiter
    @Disabled


def UpdateHUD():
    @Name " • update HUD"

    if eventPlayer.playerPrefs[prefsIndex.chillMode]:
        eventPlayer.HUDData[0] = abilityIconString(Hero.MEI, Button.ULTIMATE)
        eventPlayer.HUDData[1] = "chill mode"
        if eventPlayer.playerPrefs[prefsIndex.fastTravel]:
            eventPlayer.HUDData[1] = "{} • fast trvl".format(eventPlayer.HUDData[1])
        if eventPlayer.playerPrefs[prefsIndex.flight]:
            eventPlayer.HUDData[1] = "{} • flight".format(eventPlayer.HUDData[1])
        if not eventPlayer.playerPrefs[prefsIndex.environmentCollision]:
            eventPlayer.HUDData[1] = "{} • no coll".format(eventPlayer.HUDData[1])
        if eventPlayer.playerPrefs[prefsIndex.invisibility]:
            eventPlayer.HUDData[1] = "{} • invis".format(eventPlayer.HUDData[1])
        if eventPlayer.playerPrefs[prefsIndex.noCooldowns]:
            eventPlayer.HUDData[1] = "{} • no cd".format(eventPlayer.HUDData[1])
        if eventPlayer.playerPrefs[prefsIndex.fastUltimate]:
            eventPlayer.HUDData[1] = "{} • fast ult".format(eventPlayer.HUDData[1])
        if eventPlayer.playerPrefs[prefsIndex.fastReload]:
            eventPlayer.HUDData[1] = "{} • fast rld".format(eventPlayer.HUDData[1])
    else:
        eventPlayer.HUDData[0] = iconString(Icon.SKULL)
        eventPlayer.HUDData[1] = "kill mode"

    if eventPlayer.baseVector:
        if eventPlayer.playerPrefs[prefsIndex.arenaMode]:
            eventPlayer.HUDData[2] = abilityIconString(Hero.MCCREE, Button.ULTIMATE)
            eventPlayer.HUDData[3] = "arena"
        else:
            eventPlayer.HUDData[2] = BASE_MODE_ICONS[
                eventPlayer.playerPrefs[prefsIndex.baseMode]
            ]
            eventPlayer.HUDData[3] = PREFS_DATA[0][21][3][
                eventPlayer.playerPrefs[prefsIndex.baseMode]
            ]
        if eventPlayer.playerPrefs[prefsIndex.baseLock]:
            eventPlayer.HUDData[3] = "{} • base lock".format(eventPlayer.HUDData[3])
        if eventPlayer.playerPrefs[prefsIndex.inBaseGravity] != 100:
            eventPlayer.HUDData[3] = "{} • {} gravity".format(
                eventPlayer.HUDData[3],
                eventPlayer.playerPrefs[prefsIndex.inBaseGravity]
            )
        if eventPlayer.playerPrefs[prefsIndex.inBaseMovementSpeed] != 100:
            eventPlayer.HUDData[3] = "{} • {} speed".format(
                eventPlayer.HUDData[3],
                eventPlayer.playerPrefs[prefsIndex.inBaseMovementSpeed]
            )
    else:
        eventPlayer.HUDData[2] = abilityIconString(Hero.ZENYATTA, Button.ULTIMATE)
        eventPlayer.HUDData[3] = "none"

def UpdatePrefsHUD():
    @Name " • update preferences HUD"

    if eventPlayer.prefsPage < prefsIndex.heroOutlineColor:
        eventPlayer.prefsHUDData[0] = "hero"
    elif eventPlayer.prefsPage < prefsIndex.baseMode:
        eventPlayer.prefsHUDData[0] = "base"
    else:
        eventPlayer.prefsHUDData[0] = "game"

    switch PREFS_DATA[eventPlayer.prefsType][eventPlayer.prefsPage][1]:
        case 0:
            eventPlayer.prefsHUDData[1] = PREFS_DATA[eventPlayer.prefsType][
                eventPlayer.prefsPage
            ][3][eventPlayer.playerPrefs[eventPlayer.prefsPage]]
            eventPlayer.prefsHUDData[3] = "{} • {} of {} • {}".format(
                iconString(Icon.ARROW_LEFT),
                eventPlayer.playerPrefs[eventPlayer.prefsPage] + 1,
                len(PREFS_DATA[eventPlayer.prefsType][eventPlayer.prefsPage][3]),
                iconString(Icon.ARROW_RIGHT)
            )
            break
        case 1:
            if eventPlayer.playerPrefs[eventPlayer.prefsPage]:
                eventPlayer.prefsHUDData[1] = "on"
            else:
                eventPlayer.prefsHUDData[1] = "off"
            eventPlayer.prefsHUDData[3] = null
            break
        case 2:
            eventPlayer.prefsHUDData[1] = eventPlayer.playerPrefs[eventPlayer.prefsPage]
            eventPlayer.prefsHUDData[3] = null
            break
        case 5:
            if eventPlayer.playerPrefs[
                PREFS_DATA[eventPlayer.prefsType][eventPlayer.prefsPage][3]
            ]:
                eventPlayer.prefsHUDData[1] = "on"
            else:
                eventPlayer.prefsHUDData[1] = "off"
            eventPlayer.prefsHUDData[3] = null
            break
        case 6:
            eventPlayer.prefsHUDData[1] = eventPlayer.playerPrefs[
                prefsIndex.customMessage
            ]
            eventPlayer.prefsHUDData[3] = null
            break
        default:
            eventPlayer.prefsHUDData[1] = ""
            eventPlayer.prefsHUDData[3] = null

    if (
        not eventPlayer.playerPrefs[prefsIndex.chillMode]
        and PREFS_DATA[eventPlayer.prefsType][eventPlayer.prefsPage][2]
    ):
        eventPlayer.prefsHUDData[2] = Color.GRAY
    elif (
        PREFS_DATA[eventPlayer.prefsType][eventPlayer.prefsPage][1] == 5
        and PREFS_DATA[eventPlayer.prefsType][eventPlayer.prefsPage][4][
            eventPlayer.playerPrefs[
                PREFS_DATA[eventPlayer.prefsType][eventPlayer.prefsPage][3]
            ]
        ]
    ):
        eventPlayer.prefsHUDData[2] = PREFS_DATA[eventPlayer.prefsType][
            eventPlayer.prefsPage
        ][4][
            eventPlayer.playerPrefs[
                PREFS_DATA[eventPlayer.prefsType][eventPlayer.prefsPage][3]
            ]
        ]
    elif PREFS_DATA[eventPlayer.prefsType][eventPlayer.prefsPage][4][
        eventPlayer.playerPrefs[eventPlayer.prefsPage]
    ]:
        if eventPlayer.playerPrefs[eventPlayer.prefsPage] > 14:
            eventPlayer.prefsHUDData[2] = -1
        else:
            eventPlayer.prefsHUDData[2] = PREFS_DATA[eventPlayer.prefsType][
                eventPlayer.prefsPage
            ][4][eventPlayer.playerPrefs[eventPlayer.prefsPage]]
    else:
        eventPlayer.prefsHUDData[2] = Color.WHITE

    if (
        PREFS_DATA[eventPlayer.prefsType][eventPlayer.prefsPage][1] == 5
        and PREFS_DATA[eventPlayer.prefsType][eventPlayer.prefsPage][0][
            eventPlayer.playerPrefs[
                PREFS_DATA[eventPlayer.prefsType][eventPlayer.prefsPage][3]
            ]
        ]
    ):
        eventPlayer.prefsHUDData[4] = PREFS_DATA[eventPlayer.prefsType][
            eventPlayer.prefsPage
        ][0][
            eventPlayer.playerPrefs[
                PREFS_DATA[eventPlayer.prefsType][eventPlayer.prefsPage][3]
            ]
        ]
    elif PREFS_DATA[eventPlayer.prefsType][eventPlayer.prefsPage][0][
        eventPlayer.playerPrefs[eventPlayer.prefsPage]
    ]:
        eventPlayer.prefsHUDData[4] = PREFS_DATA[eventPlayer.prefsType][
            eventPlayer.prefsPage
        ][0][eventPlayer.playerPrefs[eventPlayer.prefsPage]]
    else:
        eventPlayer.prefsHUDData[4] = PREFS_DATA[eventPlayer.prefsType][
            eventPlayer.prefsPage
        ][0]

    UpdateHUD()


def CalibrateHero():
    @Name " • calibrate hero"

    if eventPlayer.playerPrefs[prefsIndex.chillMode]:
        eventPlayer.setHealth(eventPlayer.getMaxHealth())
        eventPlayer.setDamageDealt(0)
        eventPlayer.setDamageReceived(0)
        eventPlayer.setKnockbackReceived(25)

        if eventPlayer.playerPrefs[prefsIndex.flight]:
            eventPlayer.startAcceleration(
                Vector.UP,
                25 if eventPlayer.isHoldingButton(Button.JUMP) else 0,
                40,
                Relativity.TO_PLAYER,
                AccelReeval.DIRECTION_RATE_AND_MAX_SPEED
            )
        else:
            eventPlayer.stopAcceleration()
        if not eventPlayer.playerPrefs[prefsIndex.environmentCollision]:
            eventPlayer.disableEnvironmentCollision(false)
        else:
            eventPlayer.enableEnvironmentCollision()
        if eventPlayer.playerPrefs[prefsIndex.invisibility]:
            eventPlayer.setInvisibility(Invis.ENEMIES)
        else:
            eventPlayer.setInvisibility(Invis.NONE)
        if eventPlayer.playerPrefs[prefsIndex.heroScale] <= 100:
            eventPlayer.startScalingSize(
                eventPlayer.playerPrefs[prefsIndex.heroScale] / 100, false
            )
        elif not eventPlayer.playerPrefs[prefsIndex.environmentCollision]:
            eventPlayer.startScalingSize(
                eventPlayer.playerPrefs[prefsIndex.heroScale] / 100, false
            )
        else:
            eventPlayer.stopScalingSize()
        eventPlayer.setProjectileSpeed(
            eventPlayer.playerPrefs[prefsIndex.projectileSpeed]
        )
        eventPlayer.setProjectileGravity(
            eventPlayer.playerPrefs[prefsIndex.projectileGravity]
        )
    else:
        eventPlayer.setDamageDealt(100)
        eventPlayer.setDamageReceived(100)
        eventPlayer.setKnockbackReceived(100)

        eventPlayer.stopAcceleration()
        eventPlayer.enableEnvironmentCollision()
        eventPlayer.setInvisibility(Invis.NONE)
        eventPlayer.stopScalingSize()
        eventPlayer.setProjectileSpeed(100)
        eventPlayer.setProjectileGravity(100)

    if eventPlayer.baseInRadiusOf:
        eventPlayer.setGravity(
            eventPlayer.baseInRadiusOf.playerPrefs[prefsIndex.inBaseGravity]
        )
        eventPlayer.setMoveSpeed(
            eventPlayer.baseInRadiusOf.playerPrefs[prefsIndex.inBaseMovementSpeed]
        )
    else:
        eventPlayer.setGravity(100)
        if eventPlayer.playerPrefs[prefsIndex.chillMode]:
            eventPlayer.setMoveSpeed(eventPlayer.playerPrefs[prefsIndex.movementSpeed])
        else:
            eventPlayer.setMoveSpeed(100)

    # set base protection
    if eventPlayer.baseSettledIn == eventPlayer:
        if eventPlayer.baseSettledIn.playerPrefs[prefsIndex.arenaMode]:
            if eventPlayer.playerPrefs[prefsIndex.chillMode]:
                eventPlayer.setStatusEffect(null, Status.PHASED_OUT, 99999)
            else:
                eventPlayer.clearStatusEffect(Status.PHASED_OUT)
        else:
            eventPlayer.setStatusEffect(null, Status.PHASED_OUT, 99999)
    elif not eventPlayer.baseSettledIn.playerPrefs[prefsIndex.arenaMode] and (
        eventPlayer.baseSettledIn.playerPrefs[prefsIndex.baseMode] == 1
        or eventPlayer.baseSettledIn.playerPrefs[prefsIndex.baseMode] == 2
    ):
        eventPlayer.setStatusEffect(null, Status.PHASED_OUT, 99999)
    elif eventPlayer.hasStatusEffect(Status.PHASED_OUT):
        eventPlayer.clearStatusEffect(Status.PHASED_OUT)

    UpdateHUD()


def ThirdPersonCam():
    @Name " • enable third-person camera"

    # based on "Waitedboat4's Thirdperson Mod" (code 3F79Z)
    eventPlayer.startCamera(
        updateEveryTick(
            raycast(
                eventPlayer.getEyePosition(),
                eventPlayer.getEyePosition()
                + Vector.UP
                + eventPlayer.getFacingDirection() * -5,
                null,
                eventPlayer,
                false
            ).getHitPosition()
        ),
        updateEveryTick(
            raycast(
                eventPlayer.getEyePosition(),
                eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 100,
                null,
                eventPlayer,
                false
            ).getHitPosition()
        ),
        0
    )


def ThirdPersonSpectateCam():
    @Name " • enable third-person spectator camera"

    # based on "Waitedboat4's Thirdperson Mod" (code 3F79Z)
    eventPlayer.startCamera(
        updateEveryTick(
            raycast(
                eventPlayer.focusedPlayer.getEyePosition(),
                eventPlayer.focusedPlayer.getEyePosition()
                + Vector.UP
                + eventPlayer.focusedPlayer.getFacingDirection() * -5,
                null,
                eventPlayer.focusedPlayer,
                false
            ).getHitPosition()
        ),
        updateEveryTick(
            raycast(
                eventPlayer.focusedPlayer.getEyePosition(),
                eventPlayer.focusedPlayer.getEyePosition() + eventPlayer.focusedPlayer.getFacingDirection() * 100,
                null,
                eventPlayer.focusedPlayer,
                false
            ).getHitPosition()
        ),
        0
    )


def CircularPanCam():
    @Name " • enable circular pan camera"

    eventPlayer.startCamera(
        updateEveryTick(
            raycast(
                eventPlayer.focusedPlayer.getEyePosition(),
                eventPlayer.focusedPlayer.getEyePosition()
                + vect(SPIN_RADIUS * cosDeg(angle), 0, SPIN_RADIUS * sinDeg(angle)),
                null,
                eventPlayer,
                false
            ).getHitPosition()
        ),
        updateEveryTick(eventPlayer.focusedPlayer.getEyePosition()),
        0
    )


def ResetCam():
    @Name " • reset camera"

    if eventPlayer.playerPrefs[prefsIndex.thirdPersonMode]:
        ThirdPersonCam()
    else:
        eventPlayer.stopCamera()


def Confine():
    @Name " • confine"

    # push player towards base
    eventPlayer.applyImpulse(
        directionTowards(
            eventPlayer.getPosition(), eventPlayer.baseInRadiusOf.baseVector
        ),
        10 if eventPlayer.isOnGround() else 0.00001,
        Relativity.TO_WORLD,
        Impulse.CANCEL_CONTRARY_MOTION_XYZ
    )

    # teleport player to base if they get too far away
    if not eventPlayer in getPlayersInRadius(
        eventPlayer.baseSettledIn.baseVector,
        eventPlayer.baseSettledIn.playerPrefs[prefsIndex.baseRadius] + 3,
        Team.ALL,
        LosCheck.OFF
    ):
        # break widow's grapple
        eventPlayer.cancelPrimaryAction()
        eventPlayer.teleport(
            directionTowards(
                eventPlayer.baseSettledIn.baseVector, eventPlayer.getPosition()
            )
            * (eventPlayer.baseSettledIn.playerPrefs[prefsIndex.baseRadius])
            + eventPlayer.baseSettledIn.baseVector
        )

    wait(0.1)

    if isInDifferentBase():
        if isConfined():
            goto RULE_START


def AnimateCenterOrb():
    @Name " • animate center orb"

    eventPlayer.centerOrbRadiusT = 0

    chase(eventPlayer.centerOrbRadiusT, 1, duration = 0.6, ChaseReeval.NONE)

    wait(0.6)

    stopChasingVariable(eventPlayer.centerOrbRadiusT)


def SettleInOwnBase():
    @Name " • enter own base"

    chase(eventPlayer.baseSettlementProgress, 100, duration = 0.6, ChaseReeval.NONE)

    waitUntil(
        eventPlayer.baseSettlementProgress == 100
        or eventPlayer.settleImmediately
        or eventPlayer.baseInRadiusOf != eventPlayer,
        0.6
    )

    if eventPlayer.baseSettlementProgress == 100 or eventPlayer.settleImmediately:
        eventPlayer.baseSettledIn = eventPlayer.baseInRadiusOf
        eventPlayer.settleImmediately = false

        # this subroutine is most likely already in async, so we don't need to async CalibrateHero
        CalibrateHero()
        async(AnimateCenterOrb, AsyncBehavior.RESTART)
        BuffPlayer()

    stopChasingVariable(eventPlayer.baseSettlementProgress)

    eventPlayer.baseSettlementProgress = 0


def SettleInFriendlyBase():
    @Name " • enter friendly base / waypoint"

    chase(eventPlayer.baseSettlementProgress, 100, duration = 0.6, ChaseReeval.NONE)

    if eventPlayer.baseInRadiusOf.playerPrefs[prefsIndex.baseMode] == 1:
        waitUntil(
            eventPlayer.baseSettlementProgress == 100
            or eventPlayer.settleImmediately
            or eventPlayer.baseInRadiusOf.playerPrefs[prefsIndex.baseMode] != 1
            or eventPlayer.baseInRadiusOf.playerPrefs[prefsIndex.arenaMode]
            or eventPlayer.baseInRadiusOfPrev != eventPlayer.baseInRadiusOf,
            0.6
        )
    elif eventPlayer.baseInRadiusOf.playerPrefs[prefsIndex.baseMode] == 2:
        waitUntil(
            eventPlayer.baseSettlementProgress == 100
            or eventPlayer.settleImmediately
            or eventPlayer.baseInRadiusOf.playerPrefs[prefsIndex.baseMode] != 2
            or eventPlayer.baseInRadiusOf.playerPrefs[prefsIndex.arenaMode]
            or eventPlayer.baseInRadiusOfPrev != eventPlayer.baseInRadiusOf,
            0.6
        )

    if eventPlayer.baseSettlementProgress == 100 or eventPlayer.settleImmediately:
        eventPlayer.baseSettledIn = eventPlayer.baseInRadiusOf
        eventPlayer.settleImmediately = false

        # this subroutine is most likely already in async, so we don't need to async CalibrateHero
        CalibrateHero()
        BuffPlayer()

    stopChasingVariable(eventPlayer.baseSettlementProgress)

    eventPlayer.baseSettlementProgress = 0


def SettleInExclusiveBase():
    @Name " • enter exclusive base"

    eventPlayer.applyImpulse(
        directionTowards(
            eventPlayer.baseInRadiusOf.baseVector, eventPlayer.getPosition()
        ),
        10 if eventPlayer.isOnGround() else 0.00001,
        Relativity.TO_WORLD,
        Impulse.CANCEL_CONTRARY_MOTION_XYZ
    )

    wait(0.1)

    if [
        player
        for player in getAllPlayers()
        if player.baseVector
        and eventPlayer
        in getPlayersInRadius(
            player.baseVector,
            player.playerPrefs[prefsIndex.baseRadius],
            Team.ALL,
            LosCheck.OFF
        )
    ][0].playerPrefs[prefsIndex.baseMode] == 3:
        goto RULE_START


def SettleInArena():
    @Name " • enter arena"

    chase(eventPlayer.baseSettlementProgress, 100, duration = 3, ChaseReeval.NONE)

    waitUntil(
        eventPlayer.baseSettlementProgress == 100
        or eventPlayer.baseInRadiusOf == eventPlayer
        or not eventPlayer.baseInRadiusOf.playerPrefs[prefsIndex.arenaMode]
        or eventPlayer.baseInRadiusOfPrev != eventPlayer.baseInRadiusOf,
        3
    )

    if eventPlayer.baseSettlementProgress == 100:
        eventPlayer.baseSettledIn = eventPlayer.baseInRadiusOf
        eventPlayer.playerPrefs[prefsIndex.chillMode] = false

        # this subroutine is most likely already in async, so we don't need to async CalibrateHero
        CalibrateHero()
        DebuffPlayer()
        bigMessage(eventPlayer, "welcome to the stage.")

    stopChasingVariable(eventPlayer.baseSettlementProgress)

    eventPlayer.baseSettlementProgress = 0


def ArenaDamageModification():
    @Name " • arena damage modifications"

    if eventPlayer.baseSettledIn.playerPrefs[prefsIndex.arenaMode]:
        startDamageModification(
            [
                player
                for player in getAllPlayers()
                if player.baseSettledIn == eventPlayer
            ],
            getAllPlayers().exclude(
                [
                    player
                    for player in getAllPlayers()
                    if player.baseSettledIn == eventPlayer
                ]
            ),
            0,
            DamageReeval.RECEIVERS_AND_DAMAGERS
        )

        eventPlayer.arenaDamageModification[0] = getLastDamageModification()

        startDamageModification(
            getAllPlayers().exclude(
                [
                    player
                    for player in getAllPlayers()
                    if player.baseSettledIn == eventPlayer
                ]
            ),
            [
                player
                for player in getAllPlayers()
                if player.baseSettledIn == eventPlayer
            ],
            0,
            DamageReeval.RECEIVERS_AND_DAMAGERS
        )

        eventPlayer.arenaDamageModification[1] = getLastDamageModification()
    else:
        stopDamageModification(eventPlayer.arenaDamageModification[0])
        stopDamageModification(eventPlayer.arenaDamageModification[1])

        eventPlayer.arenaDamageModification = null


def PrefsInteract():
    @Name " • preferences interactions"

    switch eventPlayer.prefsType:
        case 0:
            switch eventPlayer.prefsPage:
                case prefsIndex.chillMode:
                case prefsIndex.flight:
                case prefsIndex.environmentCollision:
                case prefsIndex.invisibility:
                case prefsIndex.heroScale:
                case prefsIndex.projectileSpeed:
                case prefsIndex.projectileGravity:
                case prefsIndex.inBaseGravity:
                case prefsIndex.inBaseMovementSpeed:
                    async(CalibrateHero, AsyncBehavior.RESTART)
                    break
                case prefsIndex.thirdPersonMode:
                    ResetCam()
                    break
                case prefsIndex.spectatorMode:
                    eventPlayer.playerPrefs[prefsIndex.spectatorMode] = true

                    eventPlayer.disableHeroHUD()
                    eventPlayer.setStatusEffect(eventPlayer, Status.ROOTED, 99999)

                    waitUntil(eventPlayer.isHoldingButton(Button.JUMP), 99999)

                    eventPlayer.playerPrefs[prefsIndex.spectatorMode] = false

                    eventPlayer.enableHeroHud()
                    eventPlayer.clearStatusEffect(Status.ROOTED)
                    ResetCam()
                    break
                case prefsIndex.customMessage:
                    eventPlayer.keyboardMode = true
                    eventPlayer.lastPosDir = [
                        eventPlayer.getPosition(),
                        vect(
                            eventPlayer.getFacingDirection().x,
                            0,
                            eventPlayer.getFacingDirection().z
                        ),
                    ]

                    eventPlayer.disableHeroHUD()
                    eventPlayer.setStatusEffect(eventPlayer, Status.ROOTED, 99999)
                    eventPlayer.setFacing(
                        eventPlayer.lastPosDir[1], Relativity.TO_WORLD
                    )
                    eventPlayer.setInvisibility(Invis.ALL)
                    eventPlayer.startCamera(
                        eventPlayer.getEyePosition(),
                        eventPlayer.getEyePosition() + eventPlayer.lastPosDir[1],
                        0
                    )

                    waitUntil(
                        eventPlayer.isHoldingButton(Button.JUMP)
                        or eventPlayer.isDead(),
                        99999
                    )

                    eventPlayer.keyboardMode = false

                    eventPlayer.enableHeroHud()
                    eventPlayer.clearStatusEffect(Status.ROOTED)
                    eventPlayer.allowButton(Button.PRIMARY_FIRE)
                    eventPlayer.setFacing(
                        eventPlayer.lastPosDir[1], Relativity.TO_WORLD
                    )
                    async(CalibrateHero, AsyncBehavior.RESTART)
                    ResetCam()

                    eventPlayer.lastPosDir = null

                    break
                case prefsIndex.switchHero:
                    eventPlayer.lastPosDir = [
                        eventPlayer.getPosition(),
                        eventPlayer.getFacingDirection(),
                    ]

                    eventPlayer.setAllowedHeroes(
                        getAllHeroes().exclude(eventPlayer.getCurrentHero())
                    )
                    eventPlayer.resetHeroAvailability()
                    break
                case prefsIndex.packBase:
                    eventPlayer.playerPrefs[prefsIndex.arenaMode] = false
                    eventPlayer.playerPrefs[prefsIndex.baseLock] = false
                    eventPlayer.baseInRadiusOf = null
                    eventPlayer.baseSettledIn = null
                    eventPlayer.baseVector = null
                    break
                case prefsIndex.heroOutlineColor:
                    eventPlayer.startForcingOutlineFor(
                        getAllPlayers(),
                        true,
                        COLORS[
                            eventPlayer.playerPrefs[prefsIndex.heroOutlineColor]
                        ],
                        OutlineVisibility.DEFAULT
                    )
                    break
                case prefsIndex.voicelinePitch:
                    eventPlayer.startModifyingVoicelinePitch(
                        eventPlayer.playerPrefs[prefsIndex.voicelinePitch] / 100,
                        false
                    )
                    break
                case prefsIndex.arenaMode:
                    eventPlayer.playerPrefs[prefsIndex.arenaMode] = true
                    eventPlayer.prefsType = 1
                    eventPlayer.prefsPage = 0
                    ArenaDamageModification()
                    async(CalibrateHero, AsyncBehavior.RESTART)
                    playEffect(
                        getAllPlayers(),
                        DynamicEffect.EXPLOSION_SOUND,
                        null,
                        eventPlayer.baseVector,
                        100
                    )
                    break
                case prefsIndex.baseRadius:
                    if eventPlayer.playerPrefs[
                        prefsIndex.baseRadius
                    ] > eventPlayer.baseRadiusPrev and (
                        any(
                            [
                                player != eventPlayer
                                and player.baseVector
                                and distance(
                                    eventPlayer.baseVector, player.baseVector
                                )
                                <= player.playerPrefs[prefsIndex.baseRadius]
                                + eventPlayer.playerPrefs[prefsIndex.baseRadius]
                                for player in getAllPlayers()
                            ]
                        )
                    ):
                        eventPlayer.playerPrefs[
                            prefsIndex.baseRadius
                        ] = eventPlayer.baseRadiusPrev

                        DebuffPlayer()
                        smallMessage(eventPlayer, "bases can't overlap!")
                    else:
                        eventPlayer.baseRadiusPrev = eventPlayer.playerPrefs[
                            prefsIndex.baseRadius
                        ]

                    eventPlayer.cubicBezier = (
                        1
                        - CENTER_ORB_RADIUS
                        / eventPlayer.playerPrefs[prefsIndex.baseRadius]
                    )
                    break
            break
        case 1:
            switch eventPlayer.prefsPage:
                case 0:
                    eventPlayer.playerPrefs[prefsIndex.arenaMode] = false
                    eventPlayer.prefsType = 0
                    eventPlayer.prefsPage = prefsIndex.arenaMode

                    ArenaDamageModification()
                    async(CalibrateHero, AsyncBehavior.RESTART)
                    playEffect(
                        getAllPlayers(),
                        DynamicEffect.BUFF_EXPLOSION_SOUND,
                        null,
                        eventPlayer.baseVector,
                        100
                    )
                case 1:
                    async(CalibrateHero, AsyncBehavior.RESTART)
                    break
            break

    UpdatePrefsHUD()

