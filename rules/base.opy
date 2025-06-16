#!mainFile "../main.opy"

rule "Base":
    @Disabled
    @Delimiter


rule "— Prepare base":
    @Event eachPlayer
    @Condition eventPlayer.progress == 0
    @Condition not eventPlayer.base_vector
    @Condition not eventPlayer.isHoldingButton(Button.CROUCH)
    @Condition eventPlayer.isHoldingButton(Button.INTERACT)

    if eventPlayer.isInBaseCreationMode:
        eventPlayer.isInBaseCreationMode = false
        DestroyBase()
        async(UpdateCamera, AsyncBehavior.RESTART)
    else:
        eventPlayer.progress_hud[ProgressHUD.TEXT] = _("Preparing base...")
        eventPlayer.progress_hud[ProgressHUD.COLOR] = eventPlayer.preferences[Preference.BASE_COLOR]
        chaseProgress(
            1,
            eventPlayer.isInModeratorMode
            or eventPlayer.isDead()
            or eventPlayer.isHoldingButton(Button.CROUCH)
            or not eventPlayer.isHoldingButton(Button.INTERACT)
        )
        if eventPlayer.progress == 100:
            eventPlayer.isInBaseCreationMode = true
            eventPlayer.progress = 0
            CreateBase()
            async(UpdateCamera, AsyncBehavior.RESTART)
            async(UpdateAbilities, AsyncBehavior.RESTART)
        else:
            unchaseProgress(1)
    wait(0.5)


rule "— Create base":
    @Event eachPlayer
    @Condition eventPlayer.isInBaseCreationMode
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) or eventPlayer.isDead()

    if eventPlayer.isDead():
        eventPlayer.isInBaseCreationMode = false
        DestroyBase()
        return
        
    if isOverlappingBase(
        eventPlayer.getPosition(),
        eventPlayer.preferences[Preference.BASE_SIZE],
        eventPlayer.preferences[Preference.BASE_GAP_SIZE]
    ):
        smallMessage(eventPlayer, "Can't place a base here")
        # iconMessage(eventPlayer, iconString(Icon.WARNING), t"can't place a base here")
        DebuffImpactSound()
        wait(0.5)
    else:
        smallMessage(eventPlayer, "Base created successfully")
        # iconMessage(eventPlayer, iconString(Icon.CHECKMARK), t"base created successfully")
        async(Tutorial, AsyncBehavior.RESTART)
        eventPlayer.base_vector = eventPlayer.getPosition()
        eventPlayer.activate_base_immediately = true
        eventPlayer.isInBaseCreationMode = false
        stopMomentum()
        DestroyBase()
        CreateBase()
        BackupPlayer()


def Tutorial():
    @Name "— Tutorial"

    if not eventPlayer.has_created_base_once:
        eventPlayer.has_created_base_once = true
        # Camera
        eventPlayer.startCamera(
            eventPlayer.getEyePosition(), 
            raycast(
                eventPlayer.getEyePosition(),
                eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 100,
                null,
                eventPlayer,
                false
            ).getHitPosition(),
            1
        )
        wait()
        eventPlayer.startCamera(
            raycast(
                eventPlayer.base_vector,
                eventPlayer.base_vector + (Vector.UP * eventPlayer.preferences[Preference.BASE_SIZE] * 2) + (Vector.BACKWARD / 2),
                null,
                eventPlayer,
                false
            ).getHitPosition(),
            eventPlayer.base_vector,
            30
        )
        # Force position and facing
        eventPlayer.startForcingPosition(
            raycast(
                eventPlayer.base_vector,
                eventPlayer.base_vector + Vector.BACKWARD * min(1, eventPlayer.preferences[Preference.BASE_SIZE]),
                null,
                eventPlayer,
                false
            ).getHitPosition(),
            false
        )
        eventPlayer.startFacing(
            directionTowards(eventPlayer.base_vector, eventPlayer.getEyePosition()),
            360,
            Relativity.TO_WORLD,
            FacingReeval.DIRECTION_AND_TURN_RATE
        )
        eventPlayer.disableHeroHUD()
        eventPlayer.setInvisibility(Invis.ALL)
        bigMessage(eventPlayer, _("Awesome! Now, check out the orb at the center of your base."))
        wait(4)
        # Look at orb
        eventPlayer.startFacing(
            directionTowards(eventPlayer.getEyePosition(), eventPlayer.base_vector),
            360,
            Relativity.TO_WORLD,
            FacingReeval.DIRECTION_AND_TURN_RATE
        )
        wait()
        eventPlayer.startCamera(eventPlayer.getEyePosition(), eventPlayer.base_vector, 30)
        bigMessage(eventPlayer, _("You'll be able to adjust your settings here."))
        wait(4)
        bigMessage(eventPlayer, _("Try switching things up!"))
        wait(4)
        switch mode:
            case Mode.SLEEP:
                bigMessage(eventPlayer, _("Sweet dreams, {}!").format(eventPlayer))
                break
            case Mode.MUSIC:
                bigMessage(eventPlayer, _("Enjoy the music, {}!").format(eventPlayer))
                break
            default:
                bigMessage(eventPlayer, _("Happy chilling, {}!").format(eventPlayer))
                break
        eventPlayer.stopForcingPosition()
        eventPlayer.stopFacing()
        eventPlayer.enableHeroHud()
    UpdateCamera()
    UpdateInvisibility()


rule "— Detect / confine to base":
    @Event eachPlayer
    @Condition isInDifferentBase()

    if isConfined():
        async(Confine, AsyncBehavior.RESTART)
        return
    async(UpdateCurrentBaseOwner, AsyncBehavior.RESTART)


def UpdateCurrentBaseOwner():
    @Name "— Update current base owner"

    eventPlayer.current_base_owner = ([
        p for p in getAllPlayers() if p.base_vector
        and eventPlayer in getPlayersInRadius(
            p.base_vector,
            p.preferences[Preference.BASE_SIZE],
            Team.ALL,
            LosCheck.OFF
    )])[0]
    if not eventPlayer.current_base_owner:
        eventPlayer.activate_base_immediately = false
    async(UpdateBaseEffects, AsyncBehavior.RESTART)


rule "— Activate base / update base mode":
    @Event eachPlayer
    @Condition (
        eventPlayer.last_known_base_owner != eventPlayer.current_base_owner
        or eventPlayer.last_known_base_mode
        != eventPlayer.current_base_owner.preferences[Preference.BASE_MODE]
    )

    eventPlayer.last_known_base_owner = eventPlayer.current_base_owner
    eventPlayer.last_known_base_mode = eventPlayer.current_base_owner.preferences[Preference.BASE_MODE]
    if eventPlayer.current_base_owner != eventPlayer:
        switch eventPlayer.current_base_owner.preferences[Preference.BASE_MODE]:
            case BaseMode.FRIENDLY:
                async(ActivateFriendlyBase, AsyncBehavior.RESTART)
                break
            case BaseMode.REPULSIVE:
                if eventPlayer.mount:
                    EjectFromMount()
                async(Repel, AsyncBehavior.RESTART)
                break
        eventPlayer.active_base_owner = null
    else:
        async(ActivateFriendlyBase, AsyncBehavior.RESTART)


rule "— Update base preferences":
    @Event eachPlayer
    @Condition eventPlayer.current_base_owner.base_preferences_changed

    async(UpdateSizeNoclip, AsyncBehavior.RESTART)
    async(UpdatePhysics, AsyncBehavior.RESTART)
    eventPlayer.current_base_owner.base_preferences_changed = false


def Repel():
    @Name "— Repel from base"

    do:
        eventPlayer.applyImpulse(
            directionTowards(eventPlayer.current_base_owner.base_vector, eventPlayer.getPosition()),
            10 if eventPlayer.isOnGround() else 0.00001,
            Relativity.TO_WORLD,
            Impulse.CANCEL_CONTRARY_MOTION_XYZ
        )
        wait(0.1)
    while [
        p for p in getAllPlayers()
        if p.base_vector and eventPlayer in getPlayersInRadius(p.base_vector, p.preferences[Preference.BASE_SIZE], Team.ALL, LosCheck.OFF)
    ][0].preferences[Preference.BASE_MODE] == BaseMode.REPULSIVE


def ActivateFriendlyBase():
    @Name "— Activate friendly base"

    if eventPlayer.active_base_owner != eventPlayer:
        if eventPlayer.current_base_owner == eventPlayer:
            chaseBaseProgress(
                0.6,
                eventPlayer.activate_base_immediately
                or eventPlayer.current_base_owner != eventPlayer
            )
        elif eventPlayer.current_base_owner.preferences[Preference.BASE_MODE] == BaseMode.FRIENDLY:
            chaseBaseProgress(
                0.6,
                eventPlayer.activate_base_immediately
                or eventPlayer.current_base_owner.preferences[Preference.BASE_MODE] != BaseMode.FRIENDLY
                or eventPlayer.last_known_base_owner != eventPlayer.current_base_owner
            )

        if eventPlayer.base_progress == 100 or eventPlayer.activate_base_immediately:
            eventPlayer.active_base_owner = eventPlayer.current_base_owner
            eventPlayer.activate_base_immediately = false
            BuffExplosionSound()
            if eventPlayer.active_base_owner == eventPlayer:
                ResetFlux()
        eventPlayer.base_progress = 0
    UpdateBaseEffects()


rule "— Switch hero":
    @Event eachPlayer
    @Condition eventPlayer.progress == 0
    @Condition not eventPlayer.isUsingKeyboard
    @Condition not eventPlayer.isInModeratorMode
    @Condition not eventPlayer.preferences[Preference.DREAM_MODE]
    @Condition not eventPlayer.isInModeratorStasis
    @Condition not eventPlayer.isInStasis
    @Condition not eventPlayer.isViewingPreferences
    @Condition eventPlayer.active_base_owner == eventPlayer
    @Condition eventPlayer.isHoldingButton(Button.RELOAD)

    eventPlayer.progress_hud[ProgressHUD.TEXT] = _("Entering hero picker...")
    eventPlayer.progress_hud[ProgressHUD.COLOR] = eventPlayer.preferences[Preference.BASE_COLOR]
    chaseProgress(
        0.6,
        eventPlayer.isInModeratorMode
        or eventPlayer.isViewingPreferences
        or eventPlayer.active_base_owner != eventPlayer
        or not eventPlayer.isHoldingButton(Button.RELOAD)
    )
    if eventPlayer.progress == 100:
        if eventPlayer.rider:
            EjectRider()
        eventPlayer.previous_position_direction = [eventPlayer.getPosition(), eventPlayer.getFacingDirection()]
        eventPlayer.setAllowedHeroes(getAllHeroes().exclude(eventPlayer.getCurrentHero()))
        if "{}".format(eventPlayer) in ["DJBASTION", "Bastion"]:
            eventPlayer.setAllowedHeroes(Hero.BASTION)
        else:
            eventPlayer.resetHeroAvailability()
    unchaseProgress(0.6)
    wait(0.5)


rule "— Pack base":
    @Event eachPlayer
    @Condition eventPlayer.progress == 0
    @Condition eventPlayer.base_vector
    @Condition not eventPlayer.isUsingKeyboard
    @Condition not eventPlayer.isInModeratorMode
    @Condition not eventPlayer.preferences[Preference.DREAM_MODE]
    @Condition not eventPlayer.isViewingPreferences
    @Condition eventPlayer.isHoldingButton(Button.INTERACT)

    eventPlayer.progress_hud[ProgressHUD.TEXT] = _("Removing base...")
    eventPlayer.progress_hud[ProgressHUD.COLOR] = eventPlayer.preferences[Preference.BASE_COLOR]
    if eventPlayer.active_base_owner == eventPlayer: 
        chaseProgress(
            1,
            eventPlayer.isInModeratorMode
            or eventPlayer.preferences[Preference.DREAM_MODE]
            or eventPlayer.isViewingPreferences
            or eventPlayer.active_base_owner != eventPlayer
            or not eventPlayer.isHoldingButton(Button.INTERACT)
        )
    elif eventPlayer.isHoldingButton(Button.CROUCH):
        chaseProgress(
            1,
            eventPlayer.isInModeratorMode
            or eventPlayer.preferences[Preference.DREAM_MODE]
            or eventPlayer.active_base_owner == eventPlayer
            or not eventPlayer.isHoldingButton(Button.CROUCH)
            or not eventPlayer.isHoldingButton(Button.INTERACT)
        )
    if eventPlayer.progress == 100:
        eventPlayer.base_vector = null
        DestroyBase()
        UpdateBaseEffects()
        BackupPlayer()
    unchaseProgress(1)
    wait(0.5)


rule "— Fast travel":
    @Event eachPlayer
    @Condition eventPlayer.progress == 0
    @Condition not eventPlayer.isUsingKeyboard
    @Condition not eventPlayer.isInModeratorMode
    @Condition not eventPlayer.preferences[Preference.DREAM_MODE]
    @Condition not eventPlayer.isViewingPreferences
    @Condition not eventPlayer.mount
    @Condition eventPlayer.preferences[Preference.FAST_TRAVEL]
    @Condition eventPlayer.preferences[Preference.PLAYER_MODE] or (
        eventPlayer.active_base_owner == eventPlayer and not eventPlayer.preferences[Preference.BASE_LOCK]
    )
    @Condition eventPlayer.isHoldingButton(Button.MELEE)

    eventPlayer.base_to_fast_travel_owner = friendly_base_in_crosshair(eventPlayer)

    if eventPlayer.base_to_fast_travel_owner:
        eventPlayer.progress_hud[ProgressHUD.TEXT] = _("Fast traveling to {} {}'s base...").format(
            heroIcon(eventPlayer.base_to_fast_travel_owner.getCurrentHero()),
            eventPlayer.base_to_fast_travel_owner
        )
        eventPlayer.progress_hud[ProgressHUD.COLOR] = eventPlayer.base_to_fast_travel_owner.preferences[Preference.BASE_COLOR]
    elif eventPlayer.base_vector and eventPlayer.current_base_owner != eventPlayer:
        eventPlayer.base_to_fast_travel_owner = eventPlayer
        eventPlayer.progress_hud[ProgressHUD.TEXT] = _("Fast traveling to your base...")
        eventPlayer.progress_hud[ProgressHUD.COLOR] = eventPlayer.preferences[Preference.BASE_COLOR]
    elif eventPlayer.preferences[Preference.PLAYER_MODE] and eventPlayer.active_base_owner and eventPlayer.previous_position:
        eventPlayer.progress_hud[ProgressHUD.TEXT] = _("Fast traveling to previous position...")
        eventPlayer.progress_hud[ProgressHUD.COLOR] = eventPlayer.preferences[Preference.BASE_COLOR]
        chaseProgress(
            0.6,
            eventPlayer.isViewingPreferences
            or eventPlayer.isDead()
            or not eventPlayer.active_base_owner
            or not eventPlayer.isHoldingButton(Button.MELEE)
        )
        if eventPlayer.progress == 100:
            eventPlayer.teleport(eventPlayer.previous_position)
            eventPlayer.previous_position = null
            eventPlayer.progress = 0
            stopMomentum()
            BuffExplosionSound()
        unchaseProgress(0.6)
        wait(0.5)
        return
    else:
        return
    chaseProgress(
        0.6,
        eventPlayer.isDead()
        or (
            eventPlayer.base_to_fast_travel_owner != eventPlayer
            and eventPlayer.base_to_fast_travel_owner.preferences[Preference.BASE_MODE] != BaseMode.FRIENDLY
        )
        or not (eventPlayer.preferences[Preference.PLAYER_MODE] or eventPlayer.active_base_owner)
        or not eventPlayer.base_to_fast_travel_owner.base_vector
        or eventPlayer in getPlayersInRadius(
            eventPlayer.base_to_fast_travel_owner.base_vector,
            eventPlayer.base_to_fast_travel_owner.preferences[Preference.BASE_SIZE],
            Team.ALL,
            LosCheck.OFF
        )
        or not eventPlayer.isHoldingButton(Button.MELEE)
    )
    if eventPlayer.progress == 100:
        eventPlayer.previous_position = eventPlayer.getPosition()
        eventPlayer.activate_base_immediately = true
        eventPlayer.progress = 0
        eventPlayer.teleport(eventPlayer.base_to_fast_travel_owner.base_vector)
        stopMomentum()
    unchaseProgress(0.6)
    wait(0.5)

def Confine():
    @Name "— Confine to base"

    eventPlayer.applyImpulse(
        directionTowards(
            eventPlayer.getPosition(),
            eventPlayer.active_base_owner.base_vector
        ),
        10 if eventPlayer.isOnGround() else 0.00001,
        Relativity.TO_WORLD,
        Impulse.CANCEL_CONTRARY_MOTION_XYZ
    )
    if not eventPlayer in getPlayersInRadius(
        eventPlayer.active_base_owner.base_vector,
        eventPlayer.active_base_owner.preferences[Preference.BASE_SIZE] + 3,
        Team.ALL,
        LosCheck.OFF
    ):
        eventPlayer.cancelPrimaryAction()
        eventPlayer.teleport(
            directionTowards(
                eventPlayer.active_base_owner.base_vector,
                eventPlayer.getPosition()
            )
            * (eventPlayer.active_base_owner.preferences[Preference.BASE_SIZE])
            + eventPlayer.active_base_owner.base_vector
        )
    wait(0.1)
    if isInDifferentBase():
        if isConfined():
            goto RULE_START