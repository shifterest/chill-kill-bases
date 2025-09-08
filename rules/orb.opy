#!mainFile "../main.opy"

rule "Preferences":
    @Disabled
    @Delimiter

rule "— View / hide preferences":
    @Event eachPlayer
    @Condition eventPlayer.active_base_owner == eventPlayer
    @Condition not eventPlayer.isInModeratorMode
    @Condition not eventPlayer.isUsingKeyboard
    @Condition not eventPlayer.isInDreamMode
    @Condition distance(
        eventPlayer.getEyePosition()
        + distance(eventPlayer.getEyePosition(), eventPlayer.base_vector)
        * eventPlayer.getFacingDirection(),
        eventPlayer.base_vector
    ) <= orb_radius

    eventPlayer.isViewingPreferences = true
    async(UpdateAbilities, AsyncBehavior.RESTART)
    UpdatePreferencesHUD()

    waitUntil(
        eventPlayer.active_base_owner != eventPlayer
        or eventPlayer.isUsingKeyboard
        or eventPlayer.isInDreamMode
        # or eventPlayer.isCommunicatingEmote()
        or distance(
            eventPlayer.getEyePosition()
            + distance(eventPlayer.getEyePosition(), eventPlayer.base_vector)
            * eventPlayer.getFacingDirection(),
            eventPlayer.base_vector
        )
        > orb_radius,
        Math.INFINITY
    )

    eventPlayer.isViewingPreferences = false
    async(UpdateAbilities, AsyncBehavior.RESTART)


rule "— Switch between quick and advanced preferences":
    @Event eachPlayer
    @Condition eventPlayer.isViewingPreferences
    @Condition not eventPlayer.isPlayingUno
    @Condition eventPlayer.isHoldingButton(Button.MELEE)

    if eventPlayer.isViewingAdvancedPreferences:
        if (
            eventPlayer.preferences_index >= preferences_category_data[0][PreferenceCategoryProperty.STARTING_INDEX]
            and eventPlayer.preferences_index <= preferences_category_data[0][PreferenceCategoryProperty.ENDING_INDEX]
        ):
            eventPlayer.preferences_index = 0
            eventPlayer.isViewingAdvancedPreferences = false
        else:
            eventPlayer.preferences_index = [
                cat[PreferenceCategoryProperty.CATEGORY_INDEX] for cat in preferences_category_data
                if eventPlayer.preferences_index >= cat[PreferenceCategoryProperty.STARTING_INDEX]
                and eventPlayer.preferences_index <= cat[PreferenceCategoryProperty.ENDING_INDEX]
            ][0]
    else:
        eventPlayer.preferences_index = dynamic_preferences_index(eventPlayer)
        eventPlayer.isViewingAdvancedPreferences = true

    UpdatePreferencesHUD()
    BaseRingExplosion()
    RingExplosionSound()


rule "— Interact / toggle preference":
    @Event eachPlayer
    @Condition eventPlayer.isViewingPreferences
    @Condition not eventPlayer.isPlayingUno
    @Condition eventPlayer.isHoldingButton(Button.INTERACT)

    switch preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.TYPE]:
        case PreferenceType.BOOLEAN:
            if eventPlayer.preferences[dynamic_preferences_index(eventPlayer)]:
                eventPlayer.preferences[dynamic_preferences_index(eventPlayer)] = false
            else:
                eventPlayer.preferences[dynamic_preferences_index(eventPlayer)] = true
            async(InteractWithPreferences, AsyncBehavior.RESTART)
            UpdatePreferencesHUD()
            BuffImpactSoundQuiet()
            break
        case PreferenceType.CATEGORY:
            eventPlayer.preferences_index = [
                cat[PreferenceCategoryProperty.STARTING_INDEX] for cat in preferences_category_data
                if (cat[PreferenceCategoryProperty.CATEGORY_INDEX] == eventPlayer.preferences_index)
            ][0]
            UpdatePreferencesHUD()
            BaseRingExplosion()
            RingExplosionSound()
            break
        case PreferenceType.NUMERIC_REVERSIBLE:
            eventPlayer.preferences[dynamic_preferences_index(eventPlayer)] *= -1
            async(InteractWithPreferences, AsyncBehavior.RESTART)
            BuffImpactSoundQuiet()
        case PreferenceType.INTERACT:
        case PreferenceType.INTERACT_BOOLEAN:
        case PreferenceType.INTERACT_MULTIPLE_CHOICE:
        case PreferenceType.INTERACT_MULTIPLE_CHOICE_RANDOM:
        case PreferenceType.KEYBOARD:
            if preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.TYPE] == PreferenceType.KEYBOARD:
                chaseInteractionProgress(
                    0.5,
                    not eventPlayer.isViewingPreferences or not eventPlayer.isHoldingButton(Button.INTERACT)
                )
            elif (
                preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.TYPE] == PreferenceType.INTERACT_MULTIPLE_CHOICE
                or preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.TYPE] == PreferenceType.INTERACT_MULTIPLE_CHOICE_RANDOM
            ):
                chaseInteractionProgress(
                    preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.PARAMETERS][0],
                    not eventPlayer.isViewingPreferences or not eventPlayer.isHoldingButton(Button.INTERACT)
                )
            else:
                chaseInteractionProgress(
                    preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.PARAMETERS],
                    not eventPlayer.isViewingPreferences or not eventPlayer.isHoldingButton(Button.INTERACT)
                )
            if eventPlayer.interaction_progress == 100:
                if preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.TYPE] == PreferenceType.INTERACT_BOOLEAN:
                    if eventPlayer.preferences[dynamic_preferences_index(eventPlayer)]:
                        eventPlayer.preferences[dynamic_preferences_index(eventPlayer)] = false
                    else:
                        eventPlayer.preferences[dynamic_preferences_index(eventPlayer)] = true
                async(InteractWithPreferences, AsyncBehavior.RESTART)
                UpdatePreferencesHUD()
                if preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.TYPE] != PreferenceType.KEYBOARD:
                    BuffImpactSoundQuiet()
            stopChasingVariable(eventPlayer.interaction_progress)
            eventPlayer.interaction_progress = 0
            break
        case PreferenceType.MULTIPLE_CHOICE_RANDOM:
            eventPlayer.preferences[dynamic_preferences_index(eventPlayer)] = random.randint(
                0,
                len(preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.PARAMETERS]) - 1
            )
            async(InteractWithPreferences, AsyncBehavior.RESTART)
            BuffImpactSoundQuiet()
            break
        case PreferenceType.COLOR_PICKER:
            eventPlayer.preferences[dynamic_preferences_index(eventPlayer)] = random.randint(
                0,
                len(extended_color_data) - 1
            )
            async(InteractWithPreferences, AsyncBehavior.RESTART)
            BuffImpactSoundQuiet()
            break


rule "— Navigate preferences":
    @Event eachPlayer
    @Condition eventPlayer.isViewingPreferences
    @Condition not eventPlayer.isPlayingUno
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) or eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)

    eventPlayer.preference_adjustment = -1 if eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) else 1

    if eventPlayer.isViewingAdvancedPreferences:
        eventPlayer.preferences_index = (
            eventPlayer.preferences_index
            + eventPlayer.preference_adjustment
            + len(preferences_data) + 1
        ) % (
            len(preferences_data) + 1
        )
    else:
        eventPlayer.preferences_index = (
            eventPlayer.preferences_index
            + eventPlayer.preference_adjustment
            + len(quick_preferences_data) + 1
        ) % (
            len(quick_preferences_data) + 1
        )

    UpdatePreferencesHUD()
    BuffExplosionSoundQuiet()


rule "— Adjust preference, go to next/previous option":
    @Event eachPlayer
    @Condition eventPlayer.isViewingPreferences
    @Condition not eventPlayer.isPlayingUno
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) or eventPlayer.isHoldingButton(Button.ABILITY_2)

    do:
        eventPlayer.preference_adjustment = -1 if eventPlayer.isHoldingButton(Button.ABILITY_1) else 1

        switch preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.TYPE]:
            case PreferenceType.NUMERIC:
            case PreferenceType.NUMERIC_REVERSIBLE:
                eventPlayer.preference_adjustment *= (
                    preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.PARAMETERS][Numeric.STEP]
                    * (10 if eventPlayer.isHoldingButton(Button.CROUCH) else 1)
                )
                eventPlayer.preferences[dynamic_preferences_index(eventPlayer)] = (
                    max(
                        preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.PARAMETERS][Numeric.MIN],
                        min(
                            preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.PARAMETERS][Numeric.MAX],
                            eventPlayer.preferences[dynamic_preferences_index(eventPlayer)] + eventPlayer.preference_adjustment
                        )
                    )
                )
                async(InteractWithPreferences, AsyncBehavior.RESTART)
                BuffImpactSoundQuiet()
                break
            case PreferenceType.COLOR_PICKER:
                eventPlayer.preferences[dynamic_preferences_index(eventPlayer)] = (
                    (
                        eventPlayer.preferences[dynamic_preferences_index(eventPlayer)]
                        + eventPlayer.preference_adjustment
                        + len(extended_color_data)
                    ) % (
                        len(extended_color_data)
                    )
                )
                async(InteractWithPreferences, AsyncBehavior.RESTART)
                BuffImpactSoundQuiet()
                break
            case PreferenceType.MULTIPLE_CHOICE:
            case PreferenceType.MULTIPLE_CHOICE_RANDOM:
                eventPlayer.preferences[dynamic_preferences_index(eventPlayer)] = (
                    (
                        eventPlayer.preferences[dynamic_preferences_index(eventPlayer)]
                        + eventPlayer.preference_adjustment
                        + len(preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.PARAMETERS])
                    ) % (
                        len(preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.PARAMETERS])
                    )
                )
                async(InteractWithPreferences, AsyncBehavior.RESTART)
                BuffImpactSoundQuiet()
                break
            case PreferenceType.INTERACT_MULTIPLE_CHOICE:
            case PreferenceType.INTERACT_MULTIPLE_CHOICE_RANDOM:
                eventPlayer.preferences[dynamic_preferences_index(eventPlayer)] = (
                    (
                        eventPlayer.preferences[dynamic_preferences_index(eventPlayer)]
                        + eventPlayer.preference_adjustment
                        + len(preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.PARAMETERS][1])
                    ) % (
                        len(preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.PARAMETERS][1])
                    )
                )
                async(UpdatePreferencesHUD, AsyncBehavior.RESTART)
                BuffImpactSoundQuiet()
                break

        wait(0.15, Wait.ABORT_WHEN_FALSE)
    while RULE_CONDITION

rule "— Reset preference":
    @Event eachPlayer
    @Condition eventPlayer.isViewingPreferences
    @Condition not eventPlayer.isPlayingUno
    @Condition eventPlayer.isHoldingButton(Button.RELOAD)

    switch preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.TYPE]:
        case PreferenceType.MULTIPLE_CHOICE:
        case PreferenceType.MULTIPLE_CHOICE_RANDOM:
        case PreferenceType.COLOR_PICKER:
        case PreferenceType.NUMERIC:
        case PreferenceType.NUMERIC_REVERSIBLE:
            eventPlayer.preferences[dynamic_preferences_index(eventPlayer)] = preferences_default[dynamic_preferences_index(eventPlayer)]
            async(InteractWithPreferences, AsyncBehavior.RESTART)
            BaseRingExplosion()
            BuffImpactSound()
            break
        case PreferenceType.INTERACT_MULTIPLE_CHOICE_RANDOM:
            eventPlayer.preferences[dynamic_preferences_index(eventPlayer)] = random.randint(
                0,
                len(preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.PARAMETERS][1]) - 1
            )
            BuffImpactSoundQuiet()
            UpdatePreferencesHUD()
            break


def InteractWithPreferences():
    @Name "— Preferences interactions"

    switch dynamic_preferences_index(eventPlayer):
        case Preference.PLAY_UNO:
            if eventPlayer in uno_leavers:
                iconMessage(eventPlayer, Icon.WARNING, "You left this game. You may join the next one.")
            else:
                waitUntil(not unoIsBusy, 1)
                uno_player_queue.append(eventPlayer)
                eventPlayer.isPlayingUno = true
                iconMessage(eventPlayer, Icon.CHECKMARK, "Joined UNO")
            break
        case Preference.SWITCH_HERO:
            eventPlayer.startForcingHero(getAllHeroes()[eventPlayer.preferences[Preference.SWITCH_HERO]])
            wait()
            eventPlayer.stopForcingCurrentHero()
            break
        case Preference.FAST_TRAVEL_TO_OBJECTIVE:
            if (
                eventPlayer.preferences[Preference.PLAYER_MODE]
                and getObjectivePosition(eventPlayer.preferences[Preference.FAST_TRAVEL_TO_OBJECTIVE]) != vect(0, 0, 0)
            ):
                eventPlayer.teleport(nearestWalkablePosition(getObjectivePosition(eventPlayer.preferences[Preference.FAST_TRAVEL_TO_OBJECTIVE])))
                BuffImpactSound()
            elif not eventPlayer.preferences[Preference.PLAYER_MODE]:
                DebuffImpactSound()
                iconMessage(eventPlayer, iconString(Icon.WARNING), "can't fast travel in kill mode")
            else:
                DebuffImpactSound()
                iconMessage(eventPlayer, iconString(Icon.WARNING), "objective doesn't exist")
            break
        case Preference.THIRD_PERSON:
        case Preference.THIRD_PERSON_DISTANCE:
        case Preference.THIRD_PERSON_OFFSET:
        case Preference.THIRD_PERSON_SMOOTHING:
            async(UpdateCamera, AsyncBehavior.RESTART)
            break
        case Preference.SWITCH_TEAM:
            if getCurrentGamemode() == Gamemode.SKIRMISH:
                DebuffImpactSound()
                iconMessage(eventPlayer, iconString(Icon.WARNING), "switching teams disabled due to reports of server crashes")
                # moveToTeam(eventPlayer, getOppositeTeam(eventPlayer.getTeam()), -1)
            else:
                DebuffImpactSound()
                iconMessage(eventPlayer, iconString(Icon.WARNING), "gamemode is FFA")
            break
        case Preference.RESET:
            RemoveBase()
            LoadDefaultPreferences()
            InitializePlayer()
            BuffImpactSound()
            iconMessage(eventPlayer, iconString(Icon.CHECKMARK), "preferences reset")
            break
        case Preference.CUSTOM_MESSAGE:
            eventPlayer.isUsingKeyboard = true
            eventPlayer.previous_position_direction = [
                eventPlayer.getPosition(), vect(
                    eventPlayer.getFacingDirection().x,
                    0,
                    eventPlayer.getFacingDirection().z
                )
            ]
            eventPlayer.disableHeroHUD()
            eventPlayer.setStatusEffect(eventPlayer, Status.ROOTED, Math.INFINITY)
            eventPlayer.setFacing(eventPlayer.previous_position_direction[1], Relativity.TO_WORLD)
            eventPlayer.setInvisibility(Invis.ALL)
            eventPlayer.isInvisible = true
            UpdateAbilities()
            eventPlayer.startCamera(
                eventPlayer.getEyePosition(),
                eventPlayer.getEyePosition() + eventPlayer.previous_position_direction[1],
                0
            )
            break
        case Preference.AURA:
        case Preference.AURA_EFFECT:
        case Preference.HIDE_AURA_IN_FIRST_PERSON:
            async(UpdateAura, AsyncBehavior.RESTART)
            break
        case Preference.DAMAGE:
        case Preference.HEALING:
        case Preference.HEALTH:
            UpdateHero()
            break
        case Preference.OUTLINE_COLOR:
            updateHeroOutline()
            break
        case Preference.SIZE:
            UpdateSizeNoclip()
            break
        case Preference.FLIGHT:
            UpdateFlight()
            break
        case Preference.KNOCKBACK:
            UpdateKnockback()
            break
        case Preference.PROJECTILE_SPEED:
        case Preference.PROJECTILE_GRAVITY:
            UpdateProjectiles()
            break
        case Preference.VOICE_PITCH:
            updatePitch()
            break
        case Preference.AMMO_OVERLOAD:
            UpdateAmmo()
            break
        case Preference.NOCLIP:
            UpdateSizeNoclip()
            break
        case Preference.INVISIBILITY:
            UpdateInvisibility()
            break
        case Preference.ALLOW_MOUNTING:
            if (
                not eventPlayer.preferences[Preference.ALLOW_MOUNTING]
                and eventPlayer.rider
            ):
                EjectRider()
            break
        case Preference.MOUNTING_MODE:
            UpdateRider()
            break
        case Preference.BASE_MODE:
            recreateBase()
            eventPlayer.activate_base_immediately = true
            break
        case Preference.BASE_SIZE:
            while isOverlappingBase(
                eventPlayer.base_vector,
                eventPlayer.preferences[Preference.BASE_SIZE],
                eventPlayer.preferences[Preference.BASE_GAP_SIZE]
            ):
                eventPlayer.preferences[Preference.BASE_SIZE] -= preferences_data[Preference.BASE_SIZE][PreferenceProperty.PARAMETERS][Numeric.STEP]
            #     eventPlayer.previous_base_size = eventPlayer.preferences[Preference.BASE_SIZE]
            # eventPlayer.previous_base_size = eventPlayer.preferences[Preference.BASE_SIZE]
            break
        case Preference.BASE_GAP_SIZE:
            while isOverlappingBase(
                eventPlayer.base_vector,
                eventPlayer.preferences[Preference.BASE_SIZE],
                eventPlayer.preferences[Preference.BASE_GAP_SIZE]
            ):
                eventPlayer.preferences[Preference.BASE_GAP_SIZE] -= preferences_data[Preference.BASE_GAP_SIZE][PreferenceProperty.PARAMETERS][Numeric.STEP]
            #     eventPlayer.previous_base_gap_size = eventPlayer.preferences[Preference.BASE_GAP_SIZE]
            # eventPlayer.previous_base_gap_size = eventPlayer.preferences[Preference.BASE_GAP_SIZE]
            break
        case Preference.BASE_NOCLIP:
        case Preference.BASE_GRAVITY:
        case Preference.BASE_SPEED:
        case Preference.BASE_JUMP_SPEED:
            eventPlayer.base_preferences_changed = true
            break
        case Preference.BASE_LOCK:
            UpdateCurrentBaseOwner()
            break
        case Preference.DREAM_MODE:
            DreamMode()
            break
        case Preference.AFK_TIMER:
            UpdateAFKTimer()
            break
        case Preference.PLAYER_MODE:
            UpdateHero()
            break
        case Preference.GRAVITY:
        case Preference.SPEED:
        case Preference.JUMP_SPEED:
            UpdatePhysics()
            break
    UpdatePreferencesHUD()
    BackupPlayer()