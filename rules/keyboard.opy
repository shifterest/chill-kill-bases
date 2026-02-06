#!mainFile "../main.opy"

rule "Keyboard":
    @Disabled
    @Delimiter


rule "— Input key":
    @Event eachPlayer
    @Condition eventPlayer.uiState == UIState.KEYBOARD_INPUT
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)

    eventPlayer.keyboard_input_character = [
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
            horizontalAngleOfDirection(eventPlayer.previous_position_direction[1]),
            eventPlayer.getHorizontalFacingAngle()
        )
        + char[Key.HALF_WIDTH] + 1.25
        and char[Key.ANGLE_HORIZONTAL] > angleDifference(
            horizontalAngleOfDirection(eventPlayer.previous_position_direction[1]),
            eventPlayer.getHorizontalFacingAngle()
        )
        - char[Key.HALF_WIDTH] - 1.25
        and char[Key.ANGLE_VERTICAL] < angleDifference(
            verticalAngleOfDirection(eventPlayer.previous_position_direction[1]),
            eventPlayer.getVerticalFacingAngle()
        )
        + 1.25
        and char[Key.ANGLE_VERTICAL] > angleDifference(
            verticalAngleOfDirection(eventPlayer.previous_position_direction[1]),
            eventPlayer.getVerticalFacingAngle()
        )
        - 1.25
    ][0][Key.CHAR]

    if eventPlayer.keyboard_input_character:
        switch eventPlayer.keyboard_input_character:
            case SpecialChar.BACKSPACE:
                eventPlayer.preferences[Preference.CUSTOM_MESSAGE] = eventPlayer.preferences[Preference.CUSTOM_MESSAGE].substring(
                    0, strLen(eventPlayer.preferences[Preference.CUSTOM_MESSAGE]) - 1
                )

                waitUntil(not eventPlayer.isHoldingButton(Button.PRIMARY_FIRE), 0.6)
                
                if eventPlayer.isHoldingButton(Button.PRIMARY_FIRE):
                    eventPlayer.preferences[Preference.CUSTOM_MESSAGE] = ""
                break
            case SpecialChar.EXIT:
                eventPlayer.uiState = UIState.NORMAL
                eventPlayer.enableHeroHud()
                eventPlayer.clearStatusEffect(Status.ROOTED)
                eventPlayer.setFacing(eventPlayer.previous_position_direction[1], Relativity.TO_WORLD)
                UpdateMessage()
                UpdateInvisibility()
                UpdateAbilities()
                async(UpdateCamera, AsyncBehavior.RESTART)
                eventPlayer.previous_position_direction = null
                break
            default:
                eventPlayer.preferences[Preference.CUSTOM_MESSAGE] = "{}{}".format(
                    eventPlayer.preferences[Preference.CUSTOM_MESSAGE], eventPlayer.keyboard_input_character
                )


rule "— Keep cursor in bounds":
    @Event eachPlayer
    @Condition eventPlayer.uiState == UIState.KEYBOARD_INPUT

    do:
        if angleDifference(horizontalAngleOfDirection(eventPlayer.previous_position_direction[1]), eventPlayer.getHorizontalFacingAngle()) > 43.5:
            eventPlayer.setFacing(
                angleToDirection(horizontalAngleOfDirection(eventPlayer.previous_position_direction[1]) + 43.5, eventPlayer.getVerticalFacingAngle()),
                Relativity.TO_WORLD
            )
        if angleDifference(horizontalAngleOfDirection(eventPlayer.previous_position_direction[1]), eventPlayer.getHorizontalFacingAngle()) < -43.5:
            eventPlayer.setFacing(
                angleToDirection(horizontalAngleOfDirection(eventPlayer.previous_position_direction[1]) - 43.5, eventPlayer.getVerticalFacingAngle()),
                Relativity.TO_WORLD
            )
        if angleDifference(verticalAngleOfDirection(eventPlayer.previous_position_direction[1]), eventPlayer.getVerticalFacingAngle()) > 27:
            eventPlayer.setFacing(
                angleToDirection(eventPlayer.getHorizontalFacingAngle(), verticalAngleOfDirection(eventPlayer.previous_position_direction[1]) + 27),
                Relativity.TO_WORLD
            )
        if angleDifference(verticalAngleOfDirection(eventPlayer.previous_position_direction[1]), eventPlayer.getVerticalFacingAngle()) < -21.7:
            eventPlayer.setFacing(
                angleToDirection(eventPlayer.getHorizontalFacingAngle(), verticalAngleOfDirection(eventPlayer.previous_position_direction[1]) - 21.7),
                Relativity.TO_WORLD
            )
        wait(0.75)
    while RULE_CONDITION