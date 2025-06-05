#!mainFile "../main.opy"

rule "Moderator":
    @Disabled
    @Delimiter


rule "— Give host moderator":
    @Condition not "{}".format(hostPlayer) in moderator_list

    moderator_list.append("{}".format(hostPlayer))
    async(UpdateModeratorListHUD, AsyncBehavior.RESTART)


rule "— Toggle moderator mode":
    @Event eachPlayer
    @Condition eventPlayer in [p for p in getAllPlayers() if "{}".format(p) in moderator_list.concat(god_list)].concat(hostPlayer)
    @Condition eventPlayer.isHoldingButton(Button.CROUCH)
    @Condition eventPlayer.isHoldingButton(Button.RELOAD)
    @Condition not eventPlayer.isViewingPreferences
    @Condition not eventPlayer.isInBaseCreationMode
    @Condition not eventPlayer.isUsingKeyboard

    waitUntil(
        not eventPlayer.isHoldingButton(Button.CROUCH)
        and not eventPlayer.isHoldingButton(Button.RELOAD),
        Math.INFINITY
    )

    eventPlayer.isInModeratorMode = true
    eventPlayer.focused_player = eventPlayer.getRealPlayerClosestToReticle(Team.ALL)
    ThirdPersonSpectatorCamera()
    UpdateAbilities()

    waitUntil(
        not eventPlayer in [p for p in getAllPlayers() if "{}".format(p) in moderator_list.concat(god_list)].concat(hostPlayer)
        or eventPlayer.isHoldingButton(Button.CROUCH)
        and eventPlayer.isHoldingButton(Button.RELOAD),
        Math.INFINITY
    )

    eventPlayer.isInModeratorMode = false
    eventPlayer.focused_player = null
    async(UpdateCamera, AsyncBehavior.RESTART)
    UpdateAbilities()


rule "— Switch player on leave":
    @Event eachPlayer
    @Condition eventPlayer.isInModeratorMode
    @Condition not eventPlayer.focused_player in getAllPlayers()

    eventPlayer.focused_player = eventPlayer


rule "— Switch to next player":
    @Event eachPlayer
    @Condition eventPlayer.isInModeratorMode
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)

    if getNumberOfPlayers(Team.ALL) < getAllPlayers().index(eventPlayer.focused_player) + 2:
        eventPlayer.focused_player = getAllPlayers()[0]
    else:
        eventPlayer.focused_player = getAllPlayers()[getAllPlayers().index(eventPlayer.focused_player) + 1]
    ThirdPersonSpectatorCamera()


rule "— Switch to previous player":
    @Event eachPlayer
    @Condition eventPlayer.isInModeratorMode
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)

    if eventPlayer.focused_player == getAllPlayers()[0]:
        eventPlayer.focused_player = getAllPlayers()[getNumberOfPlayers(Team.ALL) - 1]
    else:
        eventPlayer.focused_player = getAllPlayers()[getAllPlayers().index(eventPlayer.focused_player) - 1]
    ThirdPersonSpectatorCamera()


rule "— Paralyze / unparalyze player":
    @Event eachPlayer
    @Condition eventPlayer.isInModeratorMode
    @Condition eventPlayer.isHoldingButton(Button.JUMP)

    if (
        eventPlayer.focused_player
        in [p for p in getAllPlayers() if "{}".format(p) in moderator_list.concat(god_list)].concat(hostPlayer).exclude(eventPlayer)
        or eventPlayer.focused_player.isDead()
        or not eventPlayer.focused_player.hasSpawned()
    ):
        DebuffSoundPlayerFocus()
        if eventPlayer.focused_player.isParalyzed or eventPlayer.focused_player.isParalyzedByModerator:
            iconMessage(eventPlayer, iconString(Icon.WARNING), "you can't unparalyze {}".format(eventPlayer.focused_player))
        else:
            iconMessage(eventPlayer, iconString(Icon.WARNING), "you can't paralyze {}".format(eventPlayer.focused_player))
    else:
        if eventPlayer.focused_player.isParalyzedByModerator:
            eventPlayer.focused_player.isParalyzedByModerator = false
            if not eventPlayer.focused_player.isParalyzed:
                switch eventPlayer.focused_player.preferences[Preference.PARALYSIS_MODE]:
                    case Paralysis.KNOCKED_DOWN:
                        eventPlayer.focused_player.clearStatusEffect(Status.KNOCKED_DOWN)
                        break
                    case Paralysis.STUNNED:
                        eventPlayer.focused_player.clearStatusEffect(Status.STUNNED)
                        break
                    case Paralysis.ASLEEP:
                        eventPlayer.focused_player.clearStatusEffect(Status.ASLEEP)
                        break
                    case Paralysis.FROZEN:
                        eventPlayer.focused_player.clearStatusEffect(Status.FROZEN)
                        break
            if eventPlayer.focused_player != eventPlayer:
                iconMessage(eventPlayer.focused_player, iconString(Icon.CHECKMARK), "unparalyzed by moderator")
            iconMessage(eventPlayer, iconString(Icon.CHECKMARK), "{} unparalyzed".format(eventPlayer.focused_player))
            BuffSound()
        else:
            eventPlayer.focused_player.isParalyzedByModerator = true
            if eventPlayer.focused_player != eventPlayer:
                iconMessage(eventPlayer.focused_player, abilityIconString(Hero.ANA, Button.ABILITY_1), "paralyzed by moderator")
            iconMessage(eventPlayer, abilityIconString(Hero.ANA, Button.ABILITY_1), "{} paralyzed".format(eventPlayer.focused_player))
            DebuffSoundBothFocus()
    waitLoad()


rule "— Kill / resurrect player":
    @Event eachPlayer
    @Condition eventPlayer.isInModeratorMode
    @Condition eventPlayer.isHoldingButton(Button.RELOAD)

    if (
        eventPlayer.focused_player
        in [p for p in getAllPlayers() if "{}".format(p) in moderator_list.concat(god_list)].concat(hostPlayer).exclude(eventPlayer)
        or not eventPlayer.focused_player.hasSpawned()
    ):
        DebuffSoundPlayerFocus()
        iconMessage(eventPlayer, iconString(Icon.WARNING), "you can't kill or resurrect {}".format(eventPlayer.focused_player))
    else:
        if eventPlayer.focused_player.isDead():
            eventPlayer.focused_player.resurrect()
            BuffSoundBothFocus()
            if eventPlayer.focused_player != eventPlayer:
                iconMessage(eventPlayer.focused_player, iconString(Icon.SKULL), "resurrected by moderator")
            iconMessage(eventPlayer, iconString(Icon.SKULL), "{} resurrected".format(eventPlayer.focused_player))
        else:
            if eventPlayer.focused_player.preferences[Preference.PLAYER_MODE] == PlayerMode.CHILL or eventPlayer.focused_player.preferences[Preference.PLAYER_MODE] == PlayerMode.ZEN:
                eventPlayer.focused_player.setDamageReceived(100)
            if eventPlayer.focused_player.hasStatusEffect(Status.PHASED_OUT):
                eventPlayer.focused_player.clearStatusEffect(Status.PHASED_OUT)
            kill(eventPlayer.focused_player, null)
            if eventPlayer.focused_player.preferences[Preference.PLAYER_MODE] == PlayerMode.CHILL or eventPlayer.focused_player.preferences[Preference.PLAYER_MODE] == PlayerMode.ZEN:
                eventPlayer.focused_player.setDamageReceived(0)
            DebuffSoundBothFocus()
            if eventPlayer.focused_player != eventPlayer:
                iconMessage(eventPlayer.focused_player, iconString(Icon.SKULL), "killed by moderator")
            iconMessage(eventPlayer, iconString(Icon.SKULL), "{} killed".format(eventPlayer.focused_player))
    waitLoad()


rule "— Remove base":
    @Event eachPlayer
    @Condition eventPlayer.isInModeratorMode
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1)
    @Condition not eventPlayer.isHoldingButton(Button.INTERACT)
    @Condition not eventPlayer.isHoldingButton(Button.MELEE)
    @Condition not eventPlayer.isHoldingButton(Button.ULTIMATE)

    if eventPlayer.focused_player in [
        p for p in getAllPlayers() if "{}".format(p) in moderator_list.concat(god_list)
    ].concat(hostPlayer).exclude(eventPlayer):
        DebuffSoundPlayerFocus()
        iconMessage(eventPlayer, iconString(Icon.WARNING), "you can't remove {}'s base".format(eventPlayer.focused_player))
    elif not eventPlayer.focused_player.base_vector:
        DebuffSoundPlayerFocus()
        iconMessage(eventPlayer, iconString(Icon.WARNING), "{} doesn't have a base".format(eventPlayer.focused_player))
    else:
        eventPlayer.progress_hud[ProgressHUD.TEXT] = "remove {} {}'s base...".format(
            heroIcon(eventPlayer.focused_player.getCurrentHero()),
            eventPlayer.focused_player
        )
        eventPlayer.progress_hud[ProgressHUD.COLOR] = ExtendedColor.RED
        chaseProgress(
            1,
            not eventPlayer.focused_player.base_vector
            or not eventPlayer.isHoldingButton(Button.ABILITY_1)
        )
        if eventPlayer.progress == 100:
            eventPlayer.focused_player.base_vector = null
            DestroyBaseEffects()
            DebuffSoundBothFocus()
            if eventPlayer.focused_player != eventPlayer:
                iconMessage(eventPlayer.focused_player, iconString(Icon.TRASHCAN), "base removed by moderator")
            iconMessage(eventPlayer, iconString(Icon.TRASHCAN), "{}'s base removed".format(eventPlayer.focused_player))
        unchaseProgress(1)
    waitLoad()


rule "— Teleport player to you":
    @Event eachPlayer
    @Condition eventPlayer.isInModeratorMode
    @Condition eventPlayer.isHoldingButton(Button.INTERACT)
    @Condition not eventPlayer.isHoldingButton(Button.ABILITY_1)
    @Condition not eventPlayer.isHoldingButton(Button.MELEE)
    @Condition not eventPlayer.isHoldingButton(Button.ULTIMATE)

    if eventPlayer.focused_player == eventPlayer or eventPlayer.focused_player in [
        p for p in getAllPlayers() if "{}".format(p) in moderator_list.concat(god_list)
    ].concat(hostPlayer):
        DebuffSoundPlayerFocus()
        iconMessage(eventPlayer, iconString(Icon.WARNING), "you can't teleport {} to you".format(eventPlayer.focused_player))
    else:
        eventPlayer.progress_hud[ProgressHUD.TEXT] = "teleporting {} {} to you...".format(
            heroIcon(eventPlayer.focused_player.getCurrentHero()),
            eventPlayer.focused_player
        )
        eventPlayer.progress_hud[ProgressHUD.COLOR] = eventPlayer.focused_player.preferences[Preference.OUTLINE_COLOR]
        chaseProgress(
            0.6,
            not eventPlayer.focused_player.hasSpawned()
            or not eventPlayer.isHoldingButton(Button.INTERACT)
        )
        if eventPlayer.progress == 100:
            eventPlayer.focused_player.teleport(eventPlayer.getPosition())
            BuffSoundBothFocus()
            iconMessage(eventPlayer.focused_player, abilityIconString(Hero.SOMBRA, Button.ABILITY_2), "teleported by moderator")
            iconMessage(eventPlayer, abilityIconString(Hero.SOMBRA, Button.ABILITY_2), "{} teleported".format(eventPlayer.focused_player))
        unchaseProgress(0.6)
    waitLoad()


rule "— Teleport to player":
    @Event eachPlayer
    @Condition eventPlayer.isInModeratorMode
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE)
    @Condition not eventPlayer.isHoldingButton(Button.ABILITY_1)
    @Condition not eventPlayer.isHoldingButton(Button.INTERACT)
    @Condition not eventPlayer.isHoldingButton(Button.MELEE)

    if eventPlayer.focused_player == eventPlayer or not eventPlayer.focused_player.hasSpawned():
        DebuffSoundPlayerFocus()
        iconMessage(eventPlayer, iconString(Icon.WARNING), "you can't teleport to {}".format(eventPlayer.focused_player))
    else:
        eventPlayer.progress_hud[ProgressHUD.TEXT] = "teleporting to {} {}...".format(
            heroIcon(eventPlayer.focused_player.getCurrentHero()),
            eventPlayer.focused_player
        )
        eventPlayer.progress_hud[ProgressHUD.COLOR] = eventPlayer.focused_player.preferences[Preference.OUTLINE_COLOR]
        chaseProgress(
            0.6,
            not eventPlayer.focused_player.hasSpawned()
            or not eventPlayer.isHoldingButton(Button.ULTIMATE)
        )
        if eventPlayer.progress == 100:
            eventPlayer.teleport(eventPlayer.focused_player.getPosition())
            BuffSound()
            iconMessage(eventPlayer, abilityIconString(Hero.SOMBRA, Button.ABILITY_2), "teleported to {}".format(eventPlayer.focused_player))
        unchaseProgress(0.6)
    waitLoad()


rule "— Ban player comms":
    @Event eachPlayer
    @Condition eventPlayer.isInModeratorMode
    @Condition eventPlayer.isHoldingButton(Button.MELEE)
    @Condition not eventPlayer.isHoldingButton(Button.CROUCH)

    if eventPlayer.focused_player in [p for p in getAllPlayers() if "{}".format(p) in moderator_list.concat(god_list)].concat(hostPlayer):
        DebuffSoundPlayerFocus()
        iconMessage(eventPlayer, iconString(Icon.WARNING), "you can't ban {}'s comms".format(eventPlayer.focused_player))
    else:
        if "{}".format(eventPlayer.focused_player) in comms_ban_list:
            comms_ban_list.remove("{}".format(eventPlayer.focused_player))
            eventPlayer.focused_player.enableTextChat()
            eventPlayer.focused_player.enableVoiceChat()
            BuffSoundBothFocus()
            iconMessage(eventPlayer.focused_player, iconString(Icon.SKULL), "comms unbanned by moderator")
            iconMessage(eventPlayer, iconString(Icon.CHECKMARK), "{}'s' comms unbanned".format(eventPlayer.focused_player))
        else:
            comms_ban_list.append("{}".format(eventPlayer.focused_player))
            DebuffSoundBothFocus()
            iconMessage(eventPlayer.focused_player, iconString(Icon.SKULL), "comms banned by moderator")
            iconMessage(eventPlayer, iconString(Icon.CROSS), "{}'s' comms banned".format(eventPlayer.focused_player))
    waitLoad()


rule "— Ban player":
    @Event eachPlayer
    @Condition eventPlayer.isInModeratorMode
    @Condition eventPlayer.isHoldingButton(Button.CROUCH)
    @Condition eventPlayer.isHoldingButton(Button.MELEE)
    @Condition not eventPlayer.isHoldingButton(Button.ABILITY_1)
    @Condition not eventPlayer.isHoldingButton(Button.INTERACT)
    @Condition not eventPlayer.isHoldingButton(Button.ULTIMATE)

    if eventPlayer.focused_player in [p for p in getAllPlayers() if "{}".format(p) in moderator_list.concat(god_list)].concat(hostPlayer):
        DebuffSoundPlayerFocus()
        iconMessage(eventPlayer, iconString(Icon.WARNING), "you can't ban {}".format(eventPlayer.focused_player))
    else:
        eventPlayer.name_to_ban = "{}".format(eventPlayer.focused_player)
        eventPlayer.progress_hud[ProgressHUD.TEXT] = "banning {}...".format(eventPlayer.name_to_ban)
        eventPlayer.progress_hud[ProgressHUD.COLOR] = ExtendedColor.RED
        chaseProgress(
            1.5,
            not eventPlayer.isHoldingButton(Button.CROUCH)
            or not eventPlayer.isHoldingButton(Button.MELEE)
        )
        if eventPlayer.progress == 100:
            ban_list.append(eventPlayer.name_to_ban)
            DebuffSoundPlayerFocus()
            iconMessage(eventPlayer, iconString(Icon.CROSS), "{} banned".format(eventPlayer.name_to_ban))
        unchaseProgress(1.5)
        eventPlayer.name_to_ban = null
    waitLoad()


rule "— Promote player / demote moderator":
    @Event eachPlayer
    @Condition eventPlayer.isInModeratorMode
    @Condition eventPlayer == hostPlayer
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2)

    if eventPlayer.focused_player in [p for p in getAllPlayers() if "{}".format(p) in god_list]:
        DebuffSoundPlayerFocus()
        iconMessage(eventPlayer, iconString(Icon.WARNING), "you can't promote gods... you don't need to")
    elif eventPlayer.focused_player == hostPlayer:
        DebuffSoundPlayerFocus()
        iconMessage(eventPlayer, iconString(Icon.WARNING), "you can't demote yourself")
    elif eventPlayer.focused_player in [p for p in getAllPlayers() if "{}".format(p) in moderator_list]:
        moderator_list.remove("{}".format(eventPlayer.focused_player))
        DebuffSoundBothFocus()
        iconMessage(eventPlayer, iconString(Icon.ARROW_DOWN), "{} demoted to player".format(eventPlayer.focused_player))
        bigMessage(eventPlayer.focused_player, "you were demoted.")
    else:
        moderator_list.append("{}".format(eventPlayer.focused_player))
        BuffSoundBothFocus()
        iconMessage(eventPlayer, iconString(Icon.BOLT), "{} promoted to moderator".format(eventPlayer.focused_player))
        bigMessage(eventPlayer.focused_player, "you were promoted to moderator!")
    async(UpdateModeratorListHUD, AsyncBehavior.RESTART)
    waitLoad()