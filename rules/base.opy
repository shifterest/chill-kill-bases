rule "Base":
    @Disabled
    @Delimiter


rule "— Prepare base":
    @Event eachPlayer
    @Condition not eventPlayer.base_vector
    @Condition eventPlayer.isHoldingButton(Button.INTERACT)
    @Condition not eventPlayer.isHoldingButton(Button.CROUCH)
    @Condition eventPlayer.progress == 0

    if eventPlayer.isInBaseCreationMode:
        eventPlayer.isInBaseCreationMode = false
        DestroyBaseEffects()
    else:
        eventPlayer.progress_hud[ProgressHUD.TEXT] = "preparing base..."
        eventPlayer.progress_hud[ProgressHUD.COLOR] = eventPlayer.base_preferences[Base.COLOR]
        chase(eventPlayer.progress, 100, duration = 1, ChaseReeval.NONE)
    
        waitUntil(
            eventPlayer.progress == 100
            or not eventPlayer.isHoldingButton(Button.INTERACT)
            or eventPlayer.isInModeratorMode
            or eventPlayer.isDead(),
            1
        )
    
        if eventPlayer.progress == 100:
            eventPlayer.isInBaseCreationMode = true
            stopChasingVariable(eventPlayer.progress)
            eventPlayer.progress = 0
            CreateBaseEffects()
            UpdateCamera()
            async(UpdateAbilities, AsyncBehavior.RESTART)
        else:
            # stopChasingVariable(eventPlayer.progress)
            chase(eventPlayer.progress, 0, duration = 0.25, ChaseReeval.NONE)
    wait(0.5)


rule "— Create base":
    @Event eachPlayer
    @Condition eventPlayer.isInBaseCreationMode
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)

    if isOverlappingBase(
        eventPlayer.getPosition(),
        eventPlayer.base_preferences[Base.SIZE],
        eventPlayer.base_preferences[Base.GAP_SIZE]
    ):
        DebuffPlayer()
        iconMessage(eventPlayer, iconString(Icon.WARNING), "can't place a base here")
        wait(0.5)
    else:
        stopMomentum()
        eventPlayer.base_vector = eventPlayer.getPosition()
        if not eventPlayer.has_created_base_once:
            async(BaseCreationHint, AsyncBehavior.NOOP)
        eventPlayer.has_created_base_once = true
        eventPlayer.settle_immediately = true
        eventPlayer.isInBaseCreationMode = false
        DestroyBaseEffects()
        CreateBaseEffects()
        UpdateCamera()
        BackupPlayer()
        iconMessage(eventPlayer, iconString(Icon.CHECKMARK), "base created successfully")


def BaseCreationHint():
    @Name "— Base creation hint"

    bigMessage(eventPlayer, "Awesome! Now, look at the orb at the center of your base.")
    wait(4)
    bigMessage(eventPlayer, "You'll be able to customize your gameplay experience from there.")
    wait(4)
    bigMessage(eventPlayer, "Happy chilling, {}!".format(eventPlayer))


rule "— Detect base / confine":
    @Event eachPlayer
    @Condition isInDiffBase()

    if isConfined():
        async(Confine, AsyncBehavior.RESTART)
        return

    async(UpdateBaseWithinOwner, AsyncBehavior.RESTART)


def UpdateBaseWithinOwner():
    @Name "— Update base within owner"

    eventPlayer.base_within_owner = ([
        p for p in getAllPlayers() if p.base_vector
        and eventPlayer in getPlayersInRadius(
            p.base_vector,
            p.base_preferences[Base.SIZE],
            Team.ALL,
            LosCheck.OFF
    )])[0]

    if not eventPlayer.base_within_owner:
        eventPlayer.settle_immediately = false

    async(Transition, AsyncBehavior.RESTART)


rule "— Settle in base / update base mode":
    @Event eachPlayer
    @Condition (
        eventPlayer.previous_base_within_radius != eventPlayer.base_within_owner
        or eventPlayer.previous_base_mode
        != eventPlayer.base_within_owner.main_preferences[Main.BASE_MODE]
    )

    eventPlayer.previous_base_within_radius = eventPlayer.base_within_owner
    eventPlayer.previous_base_mode = eventPlayer.base_within_owner.main_preferences[Main.BASE_MODE]

    if eventPlayer.base_within_owner == eventPlayer:
        if eventPlayer.base_settled_owner == eventPlayer:
            async(Transition, AsyncBehavior.RESTART)
            return
        async(SettleInOwnBase, AsyncBehavior.RESTART)
    else:
        switch eventPlayer.base_within_owner.main_preferences[Main.BASE_MODE]:
            case BaseMode.FRIENDLY:
                async(SettleInFriendlyBase, AsyncBehavior.RESTART)
                break
            case BaseMode.EXCLUSIVE:
                if eventPlayer.mount:
                    Unmount()
                async(Repel, AsyncBehavior.RESTART)
                break

    eventPlayer.base_settled_owner = null


rule "— Update base preferences":
    @Event eachPlayer
    @Condition eventPlayer.base_within_owner.base_preferences_changed

    async(UpdateSizeNoclip, AsyncBehavior.RESTART)
    async(UpdatePhysics, AsyncBehavior.RESTART)
    eventPlayer.base_within_owner.base_preferences_changed = false


def Repel():
    @Name "— Repel"

    do:
        eventPlayer.applyImpulse(
            directionTowards(eventPlayer.base_within_owner.base_vector, eventPlayer.getPosition()),
            10 if eventPlayer.isOnGround() else 0.00001,
            Relativity.TO_WORLD,
            Impulse.CANCEL_CONTRARY_MOTION_XYZ
        )
        wait(0.1)
    while [
        p for p in getAllPlayers()
        if p.base_vector and eventPlayer in getPlayersInRadius(p.base_vector, p.base_preferences[Base.SIZE], Team.ALL, LosCheck.OFF)
    ][0].main_preferences[Main.BASE_MODE] == BaseMode.EXCLUSIVE


def SettleInOwnBase():
    @Name "— Enter own base"

    chase(eventPlayer.base_progress, 100, duration = 0.6, ChaseReeval.NONE)

    waitUntil(
        eventPlayer.base_progress == 100
        or eventPlayer.base_within_owner != eventPlayer
        or eventPlayer.settle_immediately,
        0.6
    )

    if eventPlayer.base_progress == 100 or eventPlayer.settle_immediately:
        eventPlayer.base_settled_owner = eventPlayer.base_within_owner
        eventPlayer.settle_immediately = false
        Transition()
        BuffPlayer()

    stopChasingVariable(eventPlayer.base_progress)
    eventPlayer.base_progress = 0


def SettleInFriendlyBase():
    @Name "— Enter friendly base"

    chase(eventPlayer.base_progress, 100, duration = 0.6, ChaseReeval.NONE)

    waitUntil(
        eventPlayer.base_progress == 100
        or eventPlayer.base_within_owner.main_preferences[Main.BASE_MODE]
        != BaseMode.FRIENDLY
        or eventPlayer.settle_immediately
        or eventPlayer.previous_base_within_radius
        != eventPlayer.base_within_owner,
        0.6
    )

    if eventPlayer.base_progress == 100 or eventPlayer.settle_immediately:
        eventPlayer.base_settled_owner = eventPlayer.base_within_owner
        eventPlayer.settle_immediately = false
        Transition()
        BuffPlayer()

    stopChasingVariable(eventPlayer.base_progress)
    eventPlayer.base_progress = 0


rule "— Switch hero":
    @Event eachPlayer
    @Condition eventPlayer.base_settled_owner == eventPlayer
    @Condition not eventPlayer.isViewingPreferences
    @Condition eventPlayer.isHoldingButton(Button.RELOAD)
    @Condition not eventPlayer.isInModeratorMode
    @Condition not eventPlayer.isUsingKeyboard
    @Condition not eventPlayer.dream_preferences[Dream.DREAM_MODE]
    @Condition not eventPlayer.isParalyzed
    @Condition not eventPlayer.isParalyzedByModerator
    @Condition eventPlayer.progress == 0

    eventPlayer.progress_hud[ProgressHUD.TEXT] = "entering hero picker..."
    eventPlayer.progress_hud[ProgressHUD.COLOR] = eventPlayer.base_preferences[Base.COLOR]
    chase(eventPlayer.progress, 100, duration = 0.6, ChaseReeval.NONE)

    waitUntil(
        eventPlayer.progress == 100
        or not eventPlayer.isHoldingButton(Button.RELOAD)
        or eventPlayer.base_settled_owner != eventPlayer
        or eventPlayer.isViewingPreferences
        or eventPlayer.isInModeratorMode,
        0.6
    )

    if eventPlayer.progress == 100:
        if eventPlayer.rider:
            UnmountPlayer()
        eventPlayer.previous_position_direction = [eventPlayer.getPosition(), eventPlayer.getFacingDirection()]
        eventPlayer.setAllowedHeroes(getAllHeroes().exclude(eventPlayer.getCurrentHero()))
        if "{}".format(eventPlayer) in ["DJBASTION", "Bastion"]:
            eventPlayer.setAllowedHeroes(Hero.BASTION)
        else:
            eventPlayer.resetHeroAvailability()
        stopChasingVariable(eventPlayer.progress)
        eventPlayer.progress = 0
    else:
        # stopChasingVariable(eventPlayer.progress)
        chase(eventPlayer.progress, 0, duration = 0.15, ChaseReeval.NONE)
    wait(0.5)


rule "— Pack base":
    @Event eachPlayer
    @Condition eventPlayer.base_settled_owner == eventPlayer
    @Condition not eventPlayer.isViewingPreferences
    @Condition eventPlayer.isHoldingButton(Button.INTERACT)
    @Condition not eventPlayer.isInModeratorMode
    @Condition not eventPlayer.isUsingKeyboard
    @Condition not eventPlayer.dream_preferences[Dream.DREAM_MODE]
    @Condition eventPlayer.progress == 0

    eventPlayer.progress_hud[ProgressHUD.TEXT] = "preparing to pack base..."
    eventPlayer.progress_hud[ProgressHUD.COLOR] = eventPlayer.base_preferences[Base.COLOR]
    chase(eventPlayer.progress, 100, duration = 1, ChaseReeval.NONE)

    waitUntil(
        eventPlayer.progress == 100
        or not eventPlayer.isHoldingButton(Button.INTERACT)
        or eventPlayer.base_settled_owner != eventPlayer
        or eventPlayer.isViewingPreferences
        or eventPlayer.isInModeratorMode,
        1
    )

    if eventPlayer.progress == 100:
        eventPlayer.base_within_owner = null
        eventPlayer.base_settled_owner = null
        eventPlayer.base_vector = null
        stopChasingVariable(eventPlayer.progress)
        eventPlayer.progress = 0
        PackBase()
    else:
        # stopChasingVariable(eventPlayer.progress)
        chase(eventPlayer.progress, 0, duration = 0.15, ChaseReeval.NONE)
    wait(0.5)


rule "— Pack base remotely":
    @Event eachPlayer
    @Condition eventPlayer.base_vector
    @Condition eventPlayer.game_preferences[Game.REMOTE_PACK_BASE]
    @Condition eventPlayer.isHoldingButton(Button.CROUCH)
    @Condition eventPlayer.isHoldingButton(Button.INTERACT)
    @Condition eventPlayer.base_settled_owner != eventPlayer
    @Condition not eventPlayer.isInModeratorMode
    @Condition eventPlayer.progress == 0

    eventPlayer.progress_hud[ProgressHUD.TEXT] = "preparing to pack base..."
    eventPlayer.progress_hud[ProgressHUD.COLOR] = eventPlayer.base_preferences[Base.COLOR]
    chase(eventPlayer.progress, 100, duration = 1.5, ChaseReeval.NONE)

    waitUntil(
        eventPlayer.progress == 100
        or not eventPlayer.isHoldingButton(Button.CROUCH)
        or not eventPlayer.isHoldingButton(Button.INTERACT)
        or eventPlayer.base_settled_owner == eventPlayer
        or eventPlayer.isInModeratorMode,
        1.5
    )

    if eventPlayer.progress == 100:
        stopChasingVariable(eventPlayer.progress)
        eventPlayer.progress = 0
        PackBase()
    else:
        # stopChasingVariable(eventPlayer.progress)
        chase(eventPlayer.progress, 0, duration = 0.25, ChaseReeval.NONE)

    wait(0.5)


def PackBase():
    @Name "— Pack base (subroutine)"

    eventPlayer.base_vector = null
    DestroyBaseEffects()
    Transition()
    BackupPlayer()   


rule "— Fast travel":
    @Event eachPlayer
    @Condition eventPlayer.game_preferences[Game.FAST_TRAVEL]
    @Condition eventPlayer.isHoldingButton(Button.MELEE)
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE] or (
        not eventPlayer.main_preferences[Main.PLAYER_MODE] and not (
            eventPlayer.base_settled_owner != eventPlayer
            or not eventPlayer.base_settled_owner
        )
    )
    @Condition not eventPlayer.dream_preferences[Dream.DREAM_MODE]
    @Condition not eventPlayer.isViewingPreferences
    @Condition not eventPlayer.isInModeratorMode
    @Condition not eventPlayer.isUsingKeyboard
    @Condition not (eventPlayer.base_settled_owner == eventPlayer and eventPlayer.base_preferences[Base.BASE_LOCK])
    @Condition not eventPlayer.mount
    @Condition eventPlayer.progress == 0

    eventPlayer.base_to_fast_travel_owner = friendly_base_in_crosshair(eventPlayer)

    if eventPlayer.base_to_fast_travel_owner:
        eventPlayer.progress_hud[ProgressHUD.TEXT] = "fast traveling to {} {}'s base...".format(
            heroIcon(eventPlayer.base_to_fast_travel_owner.getCurrentHero()),
            eventPlayer.base_to_fast_travel_owner
        )
        eventPlayer.progress_hud[ProgressHUD.COLOR] = eventPlayer.base_to_fast_travel_owner.base_preferences[Base.COLOR]
    elif eventPlayer.base_vector and eventPlayer.base_within_owner != eventPlayer:
        eventPlayer.base_to_fast_travel_owner = eventPlayer
        eventPlayer.progress_hud[ProgressHUD.TEXT] = "fast traveling to your base..."
        eventPlayer.progress_hud[ProgressHUD.COLOR] = eventPlayer.base_preferences[Base.COLOR]
    elif eventPlayer.main_preferences[Main.PLAYER_MODE] and eventPlayer.base_settled_owner and eventPlayer.previous_position:
        eventPlayer.progress_hud[ProgressHUD.TEXT] = "fast traveling to previous position..."
        eventPlayer.progress_hud[ProgressHUD.COLOR] = eventPlayer.base_preferences[Base.COLOR]
        chase(eventPlayer.progress, 100, duration = 0.6, ChaseReeval.NONE)

        waitUntil(
            eventPlayer.progress == 100
            or not eventPlayer.isHoldingButton(Button.MELEE)
            or not eventPlayer.base_settled_owner
            or eventPlayer.isViewingPreferences
            or eventPlayer.isDead(),
            0.6
        )

        if eventPlayer.progress == 100:
            stopMomentum()
            eventPlayer.teleport(eventPlayer.previous_position)
            eventPlayer.previous_position = null
            stopChasingVariable(eventPlayer.progress)
            eventPlayer.progress = 0
            BuffPlayer()
        else:
            # stopChasingVariable(eventPlayer.progress)
            chase(eventPlayer.progress, 0, duration = 0.15, ChaseReeval.NONE)
        return
    else:
        return

    chase(eventPlayer.progress, 100, duration = 0.6, ChaseReeval.NONE)

    waitUntil(
        eventPlayer.progress == 100
        or not eventPlayer.isHoldingButton(Button.MELEE)
        or (eventPlayer.base_to_fast_travel_owner != eventPlayer and eventPlayer.base_to_fast_travel_owner.main_preferences[Main.BASE_MODE] != 1)
        or (not eventPlayer.main_preferences[Main.PLAYER_MODE] and not eventPlayer.base_settled_owner)
        or not eventPlayer.base_to_fast_travel_owner.base_vector
        or eventPlayer in getPlayersInRadius(
            eventPlayer.base_to_fast_travel_owner.base_vector,
            eventPlayer.base_to_fast_travel_owner.base_preferences[Base.SIZE],
            Team.ALL,
            LosCheck.OFF
        )
        or eventPlayer.isDead(),
        0.6
    )

    if eventPlayer.progress == 100:
        eventPlayer.previous_position = eventPlayer.getPosition()
        eventPlayer.settle_immediately = true
        stopChasingVariable(eventPlayer.progress)
        eventPlayer.progress = 0
        stopMomentum()
        eventPlayer.teleport(eventPlayer.base_to_fast_travel_owner.base_vector)
    else:
        # stopChasingVariable(eventPlayer.progress)
        chase(eventPlayer.progress, 0, duration = 0.15, ChaseReeval.NONE)

def Confine():
    @Name "— Confine"

    eventPlayer.applyImpulse(
        directionTowards(
            eventPlayer.getPosition(),
            eventPlayer.base_settled_owner.base_vector
        ),
        10 if eventPlayer.isOnGround() else 0.00001,
        Relativity.TO_WORLD,
        Impulse.CANCEL_CONTRARY_MOTION_XYZ
    )

    if not eventPlayer in getPlayersInRadius(
        eventPlayer.base_settled_owner.base_vector,
        eventPlayer.base_settled_owner.base_preferences[Base.SIZE] + 3,
        Team.ALL,
        LosCheck.OFF
    ):
        eventPlayer.cancelPrimaryAction()
        eventPlayer.teleport(
            directionTowards(
                eventPlayer.base_settled_owner.base_vector,
                eventPlayer.getPosition()
            )
            * (eventPlayer.base_settled_owner.base_preferences[Base.SIZE])
            + eventPlayer.base_settled_owner.base_vector
        )

    wait(0.1)

    if isInDiffBase():
        if isConfined():
            goto RULE_START