#!mainFile "../main.opy"

rule "UNO":
    @Delimiter
    @Disabled


rule "— UNO • Draw UNO HUD":
    @Condition isGameInProgress()
    @Condition isInitialized

    # Timer
    createProgressBarInWorldText(
        localPlayer if localPlayer.isPlayingUno else null,
        uno_timer,
        null,
        orb_vector(1),
        0.6,
        Clip.NONE,
        rainbow_rgb(),
        Color.WHITE,
        ProgressWorldTextReeval.VISIBILITY_POSITION_VALUES_AND_COLOR,
        SpecVisibility.NEVER
    )
    # Header
    createInWorldText(
        localPlayer if localPlayer.isPlayingUno else null,
        f"Playing UNO | {buttonToString(Button.MELEE)} • Leave game",
        orb_vector(0.9),
        0.9,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR,
        rainbow_rgb(),
        SpecVisibility.NEVER
    )
    # Top card
    createInWorldText(
        localPlayer if localPlayer.isPlayingUno else null,
        global_uno_hud[GlobalUnoHUD.TOP_CARD],
        orb_vector(0.8),
        1.5,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR,
        extended_color_data[global_uno_hud[GlobalUnoHUD.TOP_CARD_COLOR]],
        SpecVisibility.NEVER
    )
    # Current player
    createInWorldText(
        localPlayer if localPlayer.isPlayingUno else null,
        localPlayer.uno_hud[UnoHUD.CURRENT_TURN_DETAILS],
        orb_vector(0.7),
        0.9,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
        Color.WHITE,
        SpecVisibility.NEVER
    )
    # Current card
    createInWorldText(
        localPlayer if localPlayer.isPlayingUno else null,
        localPlayer.uno_hud[UnoHUD.CURRENT_CARD],
        orb_vector(0.5),
        1.5,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR,
        extended_color_data[localPlayer.uno_hud[UnoHUD.CURRENT_CARD_COLOR]],
        SpecVisibility.NEVER
    )
    # Card counter and hotkeys
    createInWorldText(
        localPlayer if localPlayer.isPlayingUno else null,
        "{} {} • {} • {} {}{}{}{}{}{}{}{}".format(
            buttonToString(Button.PRIMARY_FIRE),
            iconString(Icon.ARROW_LEFT),
            localPlayer.uno_hud[UnoHUD.CURRENT_TOTAL_CARDS],
            iconString(Icon.ARROW_RIGHT),
            buttonToString(Button.SECONDARY_FIRE),
            f"  |  {buttonToString(Button.JUMP)} • Play"
            if localPlayer.uno_hud[UnoHUD.PLAY] else "",
            f"  |  {buttonToString(Button.INTERACT)} • Cycle color"
            if localPlayer.uno_hud[UnoHUD.PLAY] else "",
            f"  |  {buttonToString(Button.ABILITY_1)} • Draw"
            if localPlayer.uno_hud[UnoHUD.DRAW] else "",
            f"  |  {buttonToString(Button.ABILITY_2)} • Skip"
            if localPlayer.uno_hud[UnoHUD.SKIP] else "",
            f"  |  {iconString(Icon.WARNING)} {buttonToString(Button.RELOAD)} • Challenge wild +4"
            if localPlayer.uno_hud[UnoHUD.CHALLENGE] else "",
            f"  |  {iconString(Icon.WARNING)} {buttonToString(Button.ULTIMATE)} • Call UNO!"
            if localPlayer.uno_hud[UnoHUD.CALL] else "",
            f"  |  {buttonToString(Button.ULTIMATE)} • Catch UNO!"
            if localPlayer.uno_hud[UnoHUD.CATCH] else ""
        ),
        orb_vector(0.4),
        0.9,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR,
        rainbow_rgb()
        if localPlayer.uno_hud[UnoHUD.CURRENT_CARD_COLOR] == ExtendedColor.RAINBOW
        else extended_color_data[localPlayer.uno_hud[UnoHUD.CURRENT_CARD_COLOR]],
        SpecVisibility.NEVER
    )
    # Description
    createInWorldText(
        localPlayer if localPlayer.isPlayingUno else null,
        localPlayer.uno_hud[UnoHUD.DETAILS],
        orb_vector(0.2),
        0.9,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
        Color.WHITE,
        SpecVisibility.NEVER
    )


def UpdateGlobalUnoHUD():
    @Name "— Update global UNO HUD"

    global_uno_hud[GlobalUnoHUD.TOP_CARD] = "Top card: {} {} ({})".format(
        [i for i in uno_icon_data if i[IconData.KIND] == uno_top_card[UnoCard.KIND]][0][IconData.ICON],
        [c for c in uno_card_data if c[CardData.KIND] == uno_top_card[UnoCard.KIND]][0][CardData.NAME],
        uno_top_card[UnoCard.COLOR]
    )
    global_uno_hud[GlobalUnoHUD.TOP_CARD_COLOR] = extended_color_data[uno_top_card[UnoCard.COLOR]]


def UpdateUnoHUD():
    @Name "— Update UNO HUD"

    eventPlayer.uno_hud[UnoHUD.CURRENT_TURN_DETAILS] = "Current turn: {} | {}".format(
        uno_players[uno_player_index],
        "{} until your turn".format(
            (
                (uno_players.index(eventPlayer) - uno_player_index)
                * uno_direction
            ) % len(uno_players)
        ) if (
            (
                (uno_players.index(eventPlayer) - uno_player_index)
                * uno_direction
            ) % len(uno_players)
        ) != 1 else "Your turn next"
    )
    eventPlayer.uno_hud[UnoHUD.CURRENT_CARD] = "{} {} ({})".format(
        [
            i for i in uno_icon_data
            if i[IconData.KIND] == eventPlayer.uno_hand[eventPlayer.uno_selected_card][UnoCard.KIND]
        ][0][IconData.ICON],
        [
            c for c in uno_card_data 
            if c[CardData.KIND] == eventPlayer.uno_hand[eventPlayer.uno_selected_card][UnoCard.KIND]
        ][0][CardData.NAME],
        eventPlayer.uno_hand[eventPlayer.uno_selected_card][UnoCard.COLOR] 
        if eventPlayer.uno_hand[eventPlayer.uno_selected_card][UnoCard.COLOR]
        else "Wild"
    )
    eventPlayer.uno_hud[UnoHUD.CURRENT_TOTAL_CARDS] = "{} of {}".format(
        eventPlayer.uno_selected_card + 1,
        len(eventPlayer.uno_hand)
    )
    eventPlayer.uno_hud[UnoHUD.CURRENT_CARD_COLOR] = extended_color_data[
        eventPlayer.uno_hand[eventPlayer.uno_selected_card][UnoCard.COLOR]
        if eventPlayer.uno_hand[eventPlayer.uno_selected_card][UnoCard.COLOR]
        else ExtendedColor.RAINBOW
    ]
    eventPlayer.uno_hud[UnoHUD.DETAILS] = ""
    eventPlayer.uno_hud[UnoHUD.PLAY] = uno_players.index(eventPlayer) == uno_player_index
    eventPlayer.uno_hud[UnoHUD.DRAW] = uno_players.index(eventPlayer) == uno_player_index and uno_pending_draw > 0
    eventPlayer.uno_hud[UnoHUD.SKIP] = uno_players.index(eventPlayer) == uno_player_index and uno_pending_draw == 0
    eventPlayer.uno_hud[UnoHUD.CHALLENGE] = false
    eventPlayer.uno_hud[UnoHUD.CALL] = len(eventPlayer.uno_hand) == 1
    eventPlayer.uno_hud[UnoHUD.CATCH] = false


def UnoStartGame():
    @Name "— UNO • Start game"
    
    uno_unshuffled_deck = []
    uno_discard_pile = []
    uno_top_card = null
    uno_leavers = []
    uno_player_index = 0
    uno_direction = UnoDirection.CLOCKWISE
    uno_pending_penalty_draw = 0
    uno_pending_draw = 1
    uno_must_call_player = null
    uno_challenge_players = null
    unoIsBusy = true

    for uno_i in range(9):
        uno_unshuffled_deck.append([
            [ExtendedColor.RED,     UnoCardKind.NUMBER, uno_i],
            [ExtendedColor.YELLOW,  UnoCardKind.NUMBER, uno_i],
            [ExtendedColor.GREEN,   UnoCardKind.NUMBER, uno_i],
            [ExtendedColor.BLUE,    UnoCardKind.NUMBER, uno_i],
        ])

    for uno_i in range(1, 9):
        uno_unshuffled_deck.append([
            [ExtendedColor.RED,     UnoCardKind.NUMBER, uno_i],
            [ExtendedColor.YELLOW,  UnoCardKind.NUMBER, uno_i],
            [ExtendedColor.GREEN,   UnoCardKind.NUMBER, uno_i],
            [ExtendedColor.BLUE,    UnoCardKind.NUMBER, uno_i],
        ])

    for uno_i in range(1):
        uno_unshuffled_deck.append([
            [ExtendedColor.RED,     UnoCardKind.SKIP],
            [ExtendedColor.YELLOW,  UnoCardKind.SKIP],
            [ExtendedColor.GREEN,   UnoCardKind.SKIP],
            [ExtendedColor.BLUE,    UnoCardKind.SKIP],
            [ExtendedColor.RED,     UnoCardKind.REVERSE],
            [ExtendedColor.YELLOW,  UnoCardKind.REVERSE],
            [ExtendedColor.GREEN,   UnoCardKind.REVERSE],
            [ExtendedColor.BLUE,    UnoCardKind.REVERSE],
            [ExtendedColor.RED,     UnoCardKind.DRAW_TWO],
            [ExtendedColor.YELLOW,  UnoCardKind.DRAW_TWO],
            [ExtendedColor.GREEN,   UnoCardKind.DRAW_TWO],
            [ExtendedColor.BLUE,    UnoCardKind.DRAW_TWO],
        ])

    for uno_i in range(3):
        uno_unshuffled_deck.append([
            [null,                  UnoCardKind.WILD],
            [null,                  UnoCardKind.WILD_DRAW_FOUR],
        ])

    bigMessage(uno_players, "Shuffling deck...")
    wait(4)
    uno_deck = random.shuffle(uno_unshuffled_deck)

    bigMessage(uno_players, "Dealing cards...")
    wait(4)
    for uno_i in range(6):
        for uno_j in range(len(uno_players) - 1):
            uno_players[uno_j].uno_hand.append([uno_deck[0]])
            del uno_deck[0]

    UnoBeginDiscardPile()
    async(UnoStartTurn, AsyncBehavior.RESTART)


def UnoBeginDiscardPile():
    @Name "— UNO • Begin discard pile"

    uno_top_card = uno_deck[0]
    del uno_deck[0]

    if uno_top_card[UnoCard.KIND] == UnoCardKind.WILD_DRAW_FOUR:
        uno_deck.append([uno_top_card])
        uno_top_card = null
        goto RULE_START


def UnoStartTurn():
    @Name "— UNO • Begin turn"

    bigMessage(uno_players, f"Beginning {uno_players[uno_player_index]}'s turn")

    unoIsBusy = false
    chaseOverTime(uno_timer, 100, uno_timer_duration, ChaseTimeReeval.NONE)
    waitUntil(
        uno_timer == 100
        or not uno_players[uno_player_index].isPlayingUno
        or uno_players[uno_player_index].isTakingTurn
        or uno_players[uno_player_index].isChallenging,
        uno_timer_duration
    )
    stopChasingVariable(uno_timer)

    unoIsBusy = true
    waitUntil(uno_players[uno_player_index].isTakingTurn, 1)

    async(UnoStartTurn, AsyncBehavior.RESTART)


def UnoCheckWinner():
    @Name "— UNO • Check winner"

    uno_winner = [p for p in eventPlayer if len(eventPlayer.uno_hand) == 0][0]
    if uno_winner:
        if not uno_winner.uno_points:
            uno_winner.uno_points = 0
        for uno_i in range(len(uno_players) - 1):
            for uno_j in range(len(uno_players[uno_i].uno_hand) - 1):
                switch uno_players[uno_i].uno_hand[uno_j][UnoCard.KIND]:
                    case UnoCardKind.NUMBER:
                        uno_winner.uno_points += uno_players[uno_i].uno_hand[uno_j][UnoCard.VALUE]
                        break
                    case UnoCardKind.DRAW_TWO:
                    case UnoCardKind.REVERSE:
                    case UnoCardKind.SKIP:
                        uno_winner.uno_points += 20
                        break
                    case UnoCardKind.WILD:
                    case UnoCardKind.WILD_DRAW_FOUR:
                        uno_winner.uno_points += 50
                        break


rule "— UNO • Play card":
    @Event eachPlayer
    @Condition eventPlayer.isPlayingUno
    @Condition eventPlayer == uno_players[uno_player_index]
    @Condition eventPlayer.isHoldingButton(Button.JUMP)

    if (
        eventPlayer.uno_hand[eventPlayer.uno_selected_card][UnoCard.COLOR] == uno_top_card[UnoCard.COLOR]
        or eventPlayer.uno_hand[eventPlayer.uno_selected_card][UnoCard.KIND] == uno_top_card[UnoCard.KIND]
        or eventPlayer.uno_hand[eventPlayer.uno_selected_card][UnoCard.VALUE] == uno_top_card[UnoCard.VALUE]
        or eventPlayer.uno_hand[eventPlayer.uno_selected_card][UnoCard.KIND] == UnoCardKind.WILD
        or eventPlayer.uno_hand[eventPlayer.uno_selected_card][UnoCard.KIND] == UnoCardKind.WILD_DRAW_FOUR
    ):
        eventPlayer.isTakingTurn = true
        uno_discard_pile.append([uno_top_card])
        uno_top_card = eventPlayer.uno_hand[eventPlayer.uno_selected_card]
        del eventPlayer.uno_hand[eventPlayer.uno_selected_card]
        wait(0.5)
        eventPlayer.isTakingTurn = false
    else:
        iconMessage(eventPlayer, Icon.NO, "You cannot play this card")
    wait(0.1)


rule "— UNO • Cycle color":
    @Event eachPlayer
    @Condition eventPlayer.isPlayingUno
    @Condition eventPlayer == uno_players[uno_player_index]
    @Condition eventPlayer.isHoldingButton(Button.INTERACT)
    @Condition (
        eventPlayer.uno_hand[eventPlayer.uno_selected_card][UnoCard.KIND] == UnoCardKind.WILD
        or eventPlayer.uno_hand[eventPlayer.uno_selected_card][UnoCard.KIND] == UnoCardKind.WILD_DRAW_FOUR
    )

    if eventPlayer.uno_hand[eventPlayer.uno_selected_card][UnoCard.COLOR]:
        eventPlayer.uno_hand[eventPlayer.uno_selected_card][UnoCard.COLOR] = uno_color_data[
            (
                uno_color_data.index(
                    eventPlayer.uno_hand[eventPlayer.uno_selected_card][UnoCard.COLOR]
                ) + 1
            ) % len(uno_color_data)
        ]
    else:
        eventPlayer.uno_hand[eventPlayer.uno_selected_card][UnoCard.COLOR] = random.choice(uno_color_data)
    wait(0.1)


rule "— UNO • Draw card":
    @Event eachPlayer
    @Condition eventPlayer.isPlayingUno
    @Condition eventPlayer == uno_players[uno_player_index]
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1)
    @Condition uno_pending_draw > 0

    eventPlayer.uno_hand.append([uno_deck[0]])
    eventPlayer.uno_selected_card = len(uno_deck) - 1
    del uno_deck[0]
    wait(0.1)


rule "— UNO • Skip turn":
    @Event eachPlayer
    @Condition eventPlayer.isPlayingUno
    @Condition eventPlayer == uno_players[uno_player_index]
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2)

    eventPlayer.isTakingTurn = true
    wait(0.5)
    eventPlayer.isTakingTurn = false