#!mainFile "../main.opy"

rule "UNO":
    @Delimiter
    @Disabled


rule "— UNO • Start game":
    @Condition unoHasStarted

    unoIsBusy = true
    unoChallengeIsSuccessful = false
    unoCalled = false
    uno_direction = UnoDirection.CLOCKWISE
    uno_winner = null
    uno_unshuffled_deck = []
    uno_discard_pile = []
    uno_top_card = null
    uno_leavers = []
    uno_player_index = 0
    uno_previous_player = null
    uno_pending_penalty_draw = 0
    uno_pending_draw = 1
    uno_timer = 0

    for uno_i in range(9):
        uno_unshuffled_deck.append([
            [ExtendedColor.RED,     UnoCardType.NUMBER, uno_i],
            [ExtendedColor.YELLOW,  UnoCardType.NUMBER, uno_i],
            [ExtendedColor.GREEN,   UnoCardType.NUMBER, uno_i],
            [ExtendedColor.BLUE,    UnoCardType.NUMBER, uno_i],
        ])

    for uno_i in range(1, 9):
        uno_unshuffled_deck.append([
            [ExtendedColor.RED,     UnoCardType.NUMBER, uno_i],
            [ExtendedColor.YELLOW,  UnoCardType.NUMBER, uno_i],
            [ExtendedColor.GREEN,   UnoCardType.NUMBER, uno_i],
            [ExtendedColor.BLUE,    UnoCardType.NUMBER, uno_i],
        ])

    for uno_i in range(1):
        uno_unshuffled_deck.append([
            [ExtendedColor.RED,     UnoCardType.SKIP],
            [ExtendedColor.YELLOW,  UnoCardType.SKIP],
            [ExtendedColor.GREEN,   UnoCardType.SKIP],
            [ExtendedColor.BLUE,    UnoCardType.SKIP],
            [ExtendedColor.RED,     UnoCardType.REVERSE],
            [ExtendedColor.YELLOW,  UnoCardType.REVERSE],
            [ExtendedColor.GREEN,   UnoCardType.REVERSE],
            [ExtendedColor.BLUE,    UnoCardType.REVERSE],
            [ExtendedColor.RED,     UnoCardType.DRAW_TWO],
            [ExtendedColor.YELLOW,  UnoCardType.DRAW_TWO],
            [ExtendedColor.GREEN,   UnoCardType.DRAW_TWO],
            [ExtendedColor.BLUE,    UnoCardType.DRAW_TWO],
        ])

    for uno_i in range(3):
        uno_unshuffled_deck.append([
            [null,                  UnoCardType.WILD],
            [null,                  UnoCardType.WILD_DRAW_FOUR],
        ])

    bigMessage(uno_players, "Shuffling deck...")
    UpdateGlobalUnoHUD()
    wait(4)
    uno_deck = random.shuffle(uno_unshuffled_deck)

    waitUntil(not unoIsBusy, 1)

    UnoBeginDiscardPile()
    async(UnoStartTurn, AsyncBehavior.RESTART)


rule "— UNO • Initialize players in queue":
    @Condition unoHasStarted
    @Condition len(uno_deck) > 0
    @Condition len(uno_player_queue) > 0

    unoIsBusy = true

    # Reset all hands
    for uno_i in range(len(uno_player_queue) - 1):
        uno_player_queue[uno_i].uno_hand = []

    bigMessage(uno_players, "Dealing cards...")
    for uno_i in range(6):
        for uno_j in range(len(uno_player_queue) - 1):
            if len(uno_deck) == 0:
                UnoReshuffle()
            uno_player_queue[uno_j].uno_hand.append([uno_deck[0]])
            del uno_deck[0]
    wait(4)

    uno_players.append(uno_player_queue)
    uno_player_queue = []

    unoIsBusy = false


rule "— UNO • Player left":
    @Event playerLeft
    @Condition unoHasStarted

    waitUntil(not unoIsBusy, 1)
    UnoFixPlayerState()


rule "— UNO • Leave game":
    @Event eachPlayer
    @Condition eventPlayer.isPlayingUno
    @Condition eventPlayer.isViewingPreferences
    @Condition eventPlayer.isHoldingButton(Button.MELEE)

    chaseInteractionProgress(
        1.5,
        not eventPlayer.isPlayingUno or not eventPlayer.isHoldingButton(Button.MELEE)
    )
    if eventPlayer.interaction_progress == 100:
        waitUntil(not unoIsBusy, 1)
        uno_leavers.append(eventPlayer)
        uno_players.remove(eventPlayer)
        eventPlayer.isPlayingUno = false
        iconMessage(eventPlayer, Icon.CHECKMARK, "Left UNO")
    stopChasingVariable(eventPlayer.interaction_progress)
    eventPlayer.interaction_progress = 0


rule "— UNO • Navigate cards":
    @Event eachPlayer
    @Condition eventPlayer.isPlayingUno
    @Condition eventPlayer.isViewingPreferences
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) or eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)

    eventPlayer.preference_adjustment = -1 if eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) else 1

    eventPlayer.uno_selected_card = (
        eventPlayer.uno_selected_card
        + eventPlayer.preference_adjustment
        + len(eventPlayer.uno_hand) + 1
    ) % (
        len(eventPlayer.uno_hand) + 1
    )


rule "— UNO • Play card":
    @Event eachPlayer
    @Condition not unoIsBusy
    @Condition eventPlayer.isPlayingUno
    @Condition eventPlayer.isViewingPreferences
    @Condition eventPlayer == uno_players[uno_player_index]
    @Condition eventPlayer.isHoldingButton(Button.JUMP)

    if (
        eventPlayer.uno_hand[eventPlayer.uno_selected_card][UnoCard.COLOR] == uno_top_card[UnoCard.COLOR]
        or eventPlayer.uno_hand[eventPlayer.uno_selected_card][UnoCard.TYPE] == uno_top_card[UnoCard.TYPE]
        or eventPlayer.uno_hand[eventPlayer.uno_selected_card][UnoCard.VALUE] == uno_top_card[UnoCard.VALUE]
        or eventPlayer.uno_hand[eventPlayer.uno_selected_card][UnoCard.TYPE] == UnoCardType.WILD
        or eventPlayer.uno_hand[eventPlayer.uno_selected_card][UnoCard.TYPE] == UnoCardType.WILD_DRAW_FOUR
    ):
        eventPlayer.isTakingTurn = true
        uno_discard_pile.append([uno_top_card])
        uno_top_card = eventPlayer.uno_hand[eventPlayer.uno_selected_card]
        del eventPlayer.uno_hand[eventPlayer.uno_selected_card]
        switch uno_top_card[UnoCard.TYPE]:
            case UnoCardType.REVERSE:
                uno_direction *= -1
                break
            case UnoCardType.SKIP:
                uno_player_index = (uno_player_index + uno_direction + len(uno_players)) % len(uno_players)
                break
            case UnoCardType.DRAW_TWO:
                uno_pending_penalty_draw += 2
                break
            case UnoCardType.WILD_DRAW_FOUR:
                uno_pending_penalty_draw += 4
                break
        wait(0.1)
        eventPlayer.isTakingTurn = false
    else:
        iconMessage(eventPlayer, Icon.NO, "You cannot play this card")
    wait(0.1)


rule "— UNO • Cycle color":
    @Event eachPlayer
    @Condition not unoIsBusy
    @Condition eventPlayer.isPlayingUno
    @Condition eventPlayer.isViewingPreferences
    @Condition eventPlayer == uno_players[uno_player_index]
    @Condition eventPlayer.isHoldingButton(Button.INTERACT)
    @Condition (
        eventPlayer.uno_hand[eventPlayer.uno_selected_card][UnoCard.TYPE] == UnoCardType.WILD
        or eventPlayer.uno_hand[eventPlayer.uno_selected_card][UnoCard.TYPE] == UnoCardType.WILD_DRAW_FOUR
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


rule "— UNO • Draw cards":
    @Event eachPlayer
    @Condition not unoIsBusy
    @Condition eventPlayer.isPlayingUno
    @Condition eventPlayer.isViewingPreferences
    @Condition eventPlayer == uno_players[uno_player_index]
    @Condition eventPlayer.isHoldingButton(Button.RELOAD)
    @Condition uno_pending_penalty_draw > 0 or uno_pending_draw > 0

    # If drawing as a penalty, skip regular draws
    for uno_i in range(
        (
            uno_pending_penalty_draw
            if uno_pending_penalty_draw > 0
            else uno_pending_draw
        ) - 1
    ):
        if len(uno_deck) == 0:
            UnoReshuffle()
        eventPlayer.uno_hand.append([uno_deck[0]])
        del uno_deck[0]
    if uno_pending_penalty_draw > 0:
        eventPlayer.isTakingTurn = true
        uno_pending_penalty_draw = 0
        uno_pending_draw = 0
        wait(0.1)
        eventPlayer.isTakingTurn = false
    eventPlayer.uno_selected_card = len(eventPlayer.uno_hand) - 1


rule "— UNO • Challenge Wild +4":
    @Event eachPlayer
    @Condition not unoIsBusy
    @Condition eventPlayer.isPlayingUno
    @Condition eventPlayer.isViewingPreferences
    @Condition eventPlayer == uno_players[uno_player_index]
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE)
    @Condition uno_previous_player in getAllPlayers()
    @Condition uno_top_card[UnoCard.TYPE] == UnoCardType.WILD_DRAW_FOUR

    eventPlayer.isTakingTurn = true
    bigMessage(uno_players, f"{eventPlayer} challenged {uno_previous_player}!")
    wait(4)

    for uno_i in range(len(uno_previous_player.uno_hand)):
        if uno_previous_player.uno_hand[uno_i][UnoCard.COLOR] == uno_discard_pile[0][UnoCard.COLOR]:
            unoChallengeIsSuccessful = true
            break

    if unoChallengeIsSuccessful:
        bigMessage(uno_players, f"Challenge successful! {uno_previous_player} draws {uno_pending_penalty_draw} cards.")
        UnoDrawChallenged()
        unoChallengeIsSuccessful = false
    else:
        bigMessage(uno_players, f"Too bad, the challenge failed! {eventPlayer} draws {uno_pending_penalty_draw + 2} cards.")
        uno_pending_penalty_draw += 2
    wait(4)
    eventPlayer.isTakingTurn = false


rule "— UNO • Call UNO!":
    @Event eachPlayer
    @Condition not unoIsBusy
    @Condition eventPlayer.isPlayingUno
    @Condition eventPlayer.isViewingPreferences
    @Condition eventPlayer == uno_players[uno_player_index]
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1)
    @Condition len(eventPlayer.uno_hand) == 1

    unoCalled = true
    bigMessage(uno_players, f"{eventPlayer} called UNO!")


rule "— UNO • Catch UNO!":
    @Event eachPlayer
    @Condition not unoIsBusy
    @Condition eventPlayer.isPlayingUno
    @Condition eventPlayer.isViewingPreferences
    @Condition eventPlayer == uno_players[uno_player_index]
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1)
    @Condition len(uno_previous_player.uno_hand) == 1

    uno_pending_penalty_draw += 2
    UnoDrawCaught()
    bigMessage(uno_players, f"{uno_previous_player} didn't call UNO on time! Draw {uno_pending_penalty_draw} cards.")


def UnoFixPlayerState():
    @Name "— UNO • Fix player state"

    unoIsBusy = true

    # Check if the current player is still in the game
    # If not, iterate the player list until a valid one is found
    for uno_i in range(len(uno_players) - 1):
        if (
            uno_players[uno_player_index] in getAllPlayers()
            and not uno_players[uno_player_index] in uno_leavers
        ):
            uno_temp = uno_players[uno_player_index]
            break
        else:
            uno_player_index = (
                uno_player_index + uno_direction + len(uno_players)
            ) % len(uno_players)

    # Prune invalid players
    uno_players = [
        p for p in uno_players
        if p in getAllPlayers()
        and not p in uno_leavers
    ]
    uno_player_index = uno_players.index(uno_temp)
    uno_temp = null

    unoIsBusy = false


def UnoBeginDiscardPile():
    @Name "— UNO • Begin discard pile"

    unoIsBusy = true

    uno_top_card = uno_deck[0]
    del uno_deck[0]

    # Return Wild +4 since it can't be a top card
    if uno_top_card[UnoCard.TYPE] == UnoCardType.WILD_DRAW_FOUR:
        uno_deck.append([uno_top_card])
        uno_top_card = null
        goto RULE_START

    unoIsBusy = false


def UnoStartTurn():
    @Name "— UNO • Begin turn"

    # Reset variables
    uno_pending_draw = 1
    uno_timer = 0
    unoChallengeIsSuccessful = false
    unoCalled = false
    unoIsBusy = false
    bigMessage(uno_players, f"Beginning {uno_players[uno_player_index]}'s turn")

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
    # Wait until the player has finished their turn
    waitUntil(not uno_players[uno_player_index].isTakingTurn, uno_timer_duration)
    uno_previous_player = uno_players[uno_player_index]
    uno_player_index = (uno_player_index + uno_direction + len(uno_players)) % len(uno_players)
    async(UnoStartTurn, AsyncBehavior.RESTART)


def UnoReshuffle():
    @Name "— UNO • Reshuffle"

    unoIsBusy = true

    bigMessage(uno_players, f"Deck is empty! Reshuffling discard pile...")
    uno_deck = random.shuffle(uno_discard_pile)
    uno_discard_pile = []

    unoIsBusy = false


def UnoCheckWinner():
    @Name "— UNO • Check winner"

    unoIsBusy = true

    uno_winner = [p for p in eventPlayer if len(eventPlayer.uno_hand) == 0][0]
    # Don't declare a winner if there are pending penalty draws
    if uno_winner and uno_pending_penalty_draw == 0:
        for uno_i in range(len(uno_players) - 1):
            for uno_j in range(len(uno_players[uno_i].uno_hand) - 1):
                switch uno_players[uno_i].uno_hand[uno_j][UnoCard.TYPE]:
                    case UnoCardType.NUMBER:
                        uno_winner.uno_points += uno_players[uno_i].uno_hand[uno_j][UnoCard.VALUE]
                        break
                    case UnoCardType.DRAW_TWO:
                    case UnoCardType.REVERSE:
                    case UnoCardType.SKIP:
                        uno_winner.uno_points += 20
                        break
                    case UnoCardType.WILD:
                    case UnoCardType.WILD_DRAW_FOUR:
                        uno_winner.uno_points += 50
                        break

    unoIsBusy = false


def UnoDrawChallenged():
    @Name "— UNO • Draw for challenged player"

    unoIsBusy = true

    for uno_i in range(uno_pending_penalty_draw - 1):
        if len(uno_deck) == 0:
            UnoReshuffle()
        uno_previous_player.uno_hand.append([uno_deck[0]])
        del uno_deck[0]
    uno_previous_player.isTakingTurn = true
    uno_pending_penalty_draw = 0
    wait(0.1)
    uno_previous_player.isTakingTurn = false

    unoIsBusy = false


def UnoDrawCaught():
    @Name "— UNO • Draw for caught player"

    unoIsBusy = true

    for uno_i in range(uno_pending_penalty_draw - 1):
        if len(uno_deck) == 0:
            UnoReshuffle()
        uno_previous_player.uno_hand.append([uno_deck[0]])
        del uno_deck[0]
    uno_pending_penalty_draw = 0

    unoIsBusy = false