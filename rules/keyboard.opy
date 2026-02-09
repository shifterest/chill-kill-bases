#!mainFile "../main.opy"

rule "Keyboard":
    @Disabled
    @Delimiter


rule "— Draw keyboard HUD":
    @Condition isGameInProgress()
    @Condition isInitialized

    # Cursor
    createInWorldText(
        localPlayer if localPlayer.uiState == UIState.KEYBOARD_INPUT else null,
        "▲",
        updateEveryFrame(
            localPlayer.getEyePosition()
            + vect(
                min(43.5, max(-43.5, angleDifference(horizontalAngleOfDirection(localPlayer.last_transform[1]), localPlayer.getHorizontalFacingAngle()))) / 35
                * cosDeg(horizontalAngleOfDirection(localPlayer.last_transform[1]))
                + sinDeg(horizontalAngleOfDirection(localPlayer.last_transform[1])),
                -min(27, max(-21.7, angleDifference(verticalAngleOfDirection( localPlayer.last_transform[1]), localPlayer.getVerticalFacingAngle()))) / 35,
                -min(43.5, max(-43.5, angleDifference(horizontalAngleOfDirection( localPlayer.last_transform[1]), localPlayer.getHorizontalFacingAngle()))) / 35
                * sinDeg(horizontalAngleOfDirection(localPlayer.last_transform[1]))
                + cosDeg(horizontalAngleOfDirection(localPlayer.last_transform[1]))
            )
        ),
        2,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_POSITION,
        Color.ORANGE,
        SpecVisibility.NEVER
    )
    # Keyboard debug
    createInWorldText(
        localPlayer if localPlayer.uiState == UIState.KEYBOARD_INPUT else null,
        "H: {}  |  V: {}".format(
            angleDifference(horizontalAngleOfDirection(localPlayer.last_transform[1]), localPlayer.getHorizontalFacingAngle()),
            angleDifference(verticalAngleOfDirection(localPlayer.last_transform[1]), localPlayer.getVerticalFacingAngle())
        ),
        menu_vector(localPlayer, 0, 0.35),
        1.5,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
        Color.YELLOW,
        SpecVisibility.NEVER
    )
    # Keys
    createInWorldText(
        localPlayer if localPlayer.uiState == UIState.KEYBOARD_INPUT else null,
        "{}{}".format(
            localPlayer.settings[Setting.CUSTOM_MESSAGE],
            "|" if getTotalTimeElapsed() % 1 <= 0.5 else " "
        ),
        menu_vector(localPlayer, 0, 0.3),
        2.5,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
        Color.WHITE,
        SpecVisibility.NEVER
    )
    createInWorldText(
        localPlayer if localPlayer.uiState == UIState.KEYBOARD_INPUT else null,
        "♥     ♡     ツ     ♪     ★     ▲     ▼",
        menu_vector(localPlayer, 0, 0.15),
        2.5,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_POSITION,
        Color.WHITE,
        SpecVisibility.NEVER
    )
    createInWorldText(
        localPlayer if localPlayer.uiState == UIState.KEYBOARD_INPUT else null,
        "~     !     @     #     $     %     ^     &     *     (     )     _     +     backspace",
        menu_vector(localPlayer, 0, 0.05),
        2.5,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_POSITION,
        Color.WHITE,
        SpecVisibility.NEVER
    )
    createInWorldText(
        localPlayer if localPlayer.uiState == UIState.KEYBOARD_INPUT else null,
        "`     1     2     3     4     5     6     7     8     9     0     -     =     {     [     |     ",
        menu_vector(localPlayer, 0, -0.05),
        2.5,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_POSITION,
        Color.WHITE,
        SpecVisibility.NEVER
    )
    createInWorldText(
        localPlayer if localPlayer.uiState == UIState.KEYBOARD_INPUT else null,
        "q     w     e     r     t     y     u     i     o     p          }     ]     \\",
        menu_vector(localPlayer, 0, -0.2),
        2.5,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_POSITION,
        Color.WHITE,
        SpecVisibility.NEVER
    )
    createInWorldText(
        localPlayer if localPlayer.uiState == UIState.KEYBOARD_INPUT else null,
        "a     s     d     f     g     h     j     k     l     :     ;     \"     '",
        menu_vector(localPlayer, 0, -0.3),
        2.5,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_POSITION,
        Color.WHITE,
        SpecVisibility.NEVER
    )
    createInWorldText(
        localPlayer if localPlayer.uiState == UIState.KEYBOARD_INPUT else null,
        "          z     x     c     v     b     n     m     <     >     ,     .     ?     /",
        menu_vector(localPlayer, 0, -0.4),
        2.5,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_POSITION,
        Color.WHITE,
        SpecVisibility.NEVER
    )
    createInWorldText(
        localPlayer if localPlayer.uiState == UIState.KEYBOARD_INPUT else null,
        "space     •     exit",
        menu_vector(localPlayer, 0, -0.55),
        2.5,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_POSITION,
        Color.WHITE,
        SpecVisibility.NEVER
    )


rule "— Input key":
    @Event eachPlayer
    @Condition eventPlayer.uiState == UIState.KEYBOARD_INPUT
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)

    eventPlayer.keyboard_input_char = [
        char for char in [
            ["♥", 12.9, -4.8],
            ["♡", 8.5, -4.8],
            ["ツ", 4, -4.8],
            ["♪", -0.5, -4.8],
            ["★", -4.5, -4.8],
            ["▲", -8.7, -4.8],
            ["▼", -13, -4.8],
            ["~", 26.3, -1.3],
            ["!", 23.3, -1.3],
            ["@", 19.8, -1.3],
            ["#", 17.1, -1.3],
            ["$", 16, -1.3],
            ["%", 9.1, -1.3],
            ["^", 5.5, -1.3],
            ["&", 2.1, -1.3],
            ["*", -1.1, -1.3],
            ["(", -4, -1.3],
            [")", -6.7, -1.3],
            ["_", -9.8, -1.3],
            ["+", -13, -1.3],
            [SpecialChar.BACKSPACE, -21.4, -1.3, 5.5],
            ["`", 25.2, 2.3],
            ["1", 22.5, 2.3],
            ["2", 19.3, 2.3],
            ["3", 15.9, 2.3],
            ["4", 12.6, 2.3],
            ["5", 9.2, 2.3],
            ["6", 5.8, 2.3],
            ["7", 2.4, 2.3],
            ["8", -1, 2.3],
            ["9", -4.3, 2.3],
            ["0", -7.7, 2.3],
            ["-", -10.9, 2.3],
            ["=", -14, 2.3],
            ["{", -17.2, 2.3],
            ["[", -20.1, 2.3],
            ["|", -23, 2.3],
            ["q", 20.9, 7.5],
            ["w", 17, 7.5],
            ["e", 13.5, 7.5],
            ["r", 10, 7.5],
            ["t", 6.7, 7.5],
            ["y", 3.4, 7.5],
            ["u", 0, 7.5],
            ["i", -3.2, 7.5],
            ["o", -6.3, 7.5],
            ["p", -9.8, 7.5],
            ["}", -15.1, 7.5],
            ["]", -18.1, 7.5],
            ["\\", -21.1, 7.5],
            ["a", 19.1, 11],
            ["s", 15.7, 11],
            ["d", 12.3, 11],
            ["f", 9, 11],
            ["g", 5.4, 11],
            ["h", 2, 11],
            ["j", -1.3, 11],
            ["k", -4.6, 11],
            ["l", -8, 11],
            [":", -11, 11],
            [";", -13.6, 11],
            ["\"", -16.5, 11],
            ["'", -19.4, 11],
            ["z", 17.3, 14.5],
            ["x", 13.9, 14.5],
            ["c", 10.6, 14.5],
            ["v", 7.1, 14.5],
            ["b", 3.7, 14.5],
            ["n", 0.2, 14.5],
            ["m", -3.4, 14.5],
            ["<", -7, 14.5],
            [">", -10.2, 14.5],
            [",", -13, 14.5],
            [".", -15.8, 14.5],
            ["?", -18.7, 14.5],
            ["/", -21.9, 14.5],
            [" ", 4.6, 19.8, 3],
            [SpecialChar.EXIT, -5.9, 19.8, 2.5],
        ]
        if char[Key.ANGLE_HORIZONTAL] < angleDifference(
            horizontalAngleOfDirection(eventPlayer.last_transform[1]),
            eventPlayer.getHorizontalFacingAngle()
        )
        + char[Key.HALF_WIDTH] + 1.25
        and char[Key.ANGLE_HORIZONTAL] > angleDifference(
            horizontalAngleOfDirection(eventPlayer.last_transform[1]),
            eventPlayer.getHorizontalFacingAngle()
        )
        - char[Key.HALF_WIDTH] - 1.25
        and char[Key.ANGLE_VERTICAL] < angleDifference(
            verticalAngleOfDirection(eventPlayer.last_transform[1]),
            eventPlayer.getVerticalFacingAngle()
        )
        + 1.25
        and char[Key.ANGLE_VERTICAL] > angleDifference(
            verticalAngleOfDirection(eventPlayer.last_transform[1]),
            eventPlayer.getVerticalFacingAngle()
        )
        - 1.25
    ][0][Key.CHAR]

    if eventPlayer.keyboard_input_char:
        switch eventPlayer.keyboard_input_char:
            case SpecialChar.BACKSPACE:
                eventPlayer.settings[Setting.CUSTOM_MESSAGE] = eventPlayer.settings[Setting.CUSTOM_MESSAGE].substring(
                    0, strLen(eventPlayer.settings[Setting.CUSTOM_MESSAGE]) - 1
                )

                waitUntil(not eventPlayer.isHoldingButton(Button.PRIMARY_FIRE), 0.6)
                
                if eventPlayer.isHoldingButton(Button.PRIMARY_FIRE):
                    eventPlayer.settings[Setting.CUSTOM_MESSAGE] = ""
                break
            case SpecialChar.EXIT:
                eventPlayer.uiState = UIState.NORMAL
                eventPlayer.enableHeroHud()
                eventPlayer.clearStatusEffect(Status.ROOTED)
                restoreTransform()
                UpdateMessage()
                UpdateInvisibility()
                UpdateAbilities()
                async(UpdateCamera, AsyncBehavior.RESTART)
                eventPlayer.last_transform = null
                break
            default:
                eventPlayer.settings[Setting.CUSTOM_MESSAGE] = "{}{}".format(
                    eventPlayer.settings[Setting.CUSTOM_MESSAGE], eventPlayer.keyboard_input_char
                )


rule "— Keep cursor in bounds":
    @Event eachPlayer
    @Condition eventPlayer.uiState == UIState.KEYBOARD_INPUT

    do:
        if angleDifference(horizontalAngleOfDirection(eventPlayer.last_transform[1]), eventPlayer.getHorizontalFacingAngle()) > 43.5:
            eventPlayer.setFacing(
                angleToDirection(horizontalAngleOfDirection(eventPlayer.last_transform[1]) + 43.5, eventPlayer.getVerticalFacingAngle()),
                Relativity.TO_WORLD
            )
        if angleDifference(horizontalAngleOfDirection(eventPlayer.last_transform[1]), eventPlayer.getHorizontalFacingAngle()) < -43.5:
            eventPlayer.setFacing(
                angleToDirection(horizontalAngleOfDirection(eventPlayer.last_transform[1]) - 43.5, eventPlayer.getVerticalFacingAngle()),
                Relativity.TO_WORLD
            )
        if angleDifference(verticalAngleOfDirection(eventPlayer.last_transform[1]), eventPlayer.getVerticalFacingAngle()) > 27:
            eventPlayer.setFacing(
                angleToDirection(eventPlayer.getHorizontalFacingAngle(), verticalAngleOfDirection(eventPlayer.last_transform[1]) + 27),
                Relativity.TO_WORLD
            )
        if angleDifference(verticalAngleOfDirection(eventPlayer.last_transform[1]), eventPlayer.getVerticalFacingAngle()) < -21.7:
            eventPlayer.setFacing(
                angleToDirection(eventPlayer.getHorizontalFacingAngle(), verticalAngleOfDirection(eventPlayer.last_transform[1]) - 21.7),
                Relativity.TO_WORLD
            )
        wait(0.75)
    while RULE_CONDITION