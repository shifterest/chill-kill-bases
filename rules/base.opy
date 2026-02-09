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

    if eventPlayer.uiState == UIState.BASE_CREATION:
        eventPlayer.uiState = UIState.NORMAL
        DestroyBase()
        async(UpdateCamera, AsyncBehavior.RESTART)
    else:
        eventPlayer.progress_hud[ProgHUD.TEXT] = "Preparing base..."
        eventPlayer.progress_hud[ProgHUD.COLOR] = s(Setting.BASE_COLOR)
        chaseProgress(
            1,
            eventPlayer.uiState != UIState.NORMAL
            or eventPlayer.isDead()
            or eventPlayer.isHoldingButton(Button.CROUCH)
            or not eventPlayer.isHoldingButton(Button.INTERACT)
        )
        if eventPlayer.progress == 100:
            eventPlayer.uiState = UIState.BASE_CREATION
            eventPlayer.progress = 0
            CreateBase()
            async(UpdateCamera, AsyncBehavior.RESTART)
            async(UpdateAbilities, AsyncBehavior.RESTART)
        else:
            unchaseProgress(1)
    wait(0.5)


rule "— Create base":
    @Event eachPlayer
    @Condition eventPlayer.uiState == UIState.BASE_CREATION
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) or eventPlayer.isDead()

    if eventPlayer.isDead():
        eventPlayer.uiState = UIState.NORMAL
        DestroyBase()
        return
        
    if isOverlappingBase(
        pos(),
        s(Setting.BASE_SIZE),
        s(Setting.BASE_GAP_SIZE)
    ):
        smallMessage(eventPlayer, "Can't place a base here")
        # iconMessage(eventPlayer, iconString(Icon.WARNING), t"can't place a base here")
        DebuffImpactSound()
        wait(0.5)
    else:
        smallMessage(eventPlayer, "Base created successfully")
        # iconMessage(eventPlayer, iconString(Icon.CHECKMARK), t"base created successfully")
        async(Tutorial, AsyncBehavior.RESTART)
        eventPlayer.base_vector = pos()
        eventPlayer.activate_base_now = true
        eventPlayer.uiState = UIState.NORMAL
        stopMomentum()
        recreateBase()
        BackupPlayer()


rule "— Detect / confine to base":
    @Event eachPlayer
    @Condition isInDifferentBase()

    if isConfined():
        async(Confine, AsyncBehavior.RESTART)
        return
    async(UpdateBaseOwner, AsyncBehavior.RESTART)


rule "— Activate base / update base mode":
    @Event eachPlayer
    @Condition (
        eventPlayer.last_known_base_owner != eventPlayer.current_base_owner
        or eventPlayer.last_known_base_mode
        != eventPlayer.current_base_owner.settings[Setting.BASE_MODE]
    )

    eventPlayer.last_known_base_owner = eventPlayer.current_base_owner
    eventPlayer.last_known_base_mode = eventPlayer.current_base_owner.settings[Setting.BASE_MODE]
    if eventPlayer.current_base_owner != eventPlayer:
        switch eventPlayer.current_base_owner.settings[Setting.BASE_MODE]:
            case BaseMode.FRIENDLY:
                async(ActivateFriendlyBase, AsyncBehavior.RESTART)
                break
            case BaseMode.REPULSIVE:
            case BaseMode.HOSTILE:
                if eventPlayer.mount:
                    EjectFromMount()
                async(Repel, AsyncBehavior.RESTART)
                break
        eventPlayer.active_base_owner = null
    else:
        async(ActivateFriendlyBase, AsyncBehavior.RESTART)


rule "— Update base settings":
    @Event eachPlayer
    @Condition eventPlayer.current_base_owner.base_settings_changed

    async(UpdateSizeNoclip, AsyncBehavior.RESTART)
    async(UpdatePhysics, AsyncBehavior.RESTART)
    eventPlayer.current_base_owner.base_settings_changed = false


rule "— Switch hero":
    @Event eachPlayer
    @Condition eventPlayer.progress == 0
    @Condition eventPlayer.uiState == UIState.NORMAL
    @Condition not eventPlayer.isInModStasis
    @Condition not eventPlayer.isInStasis
    @Condition eventPlayer.active_base_owner == eventPlayer
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE)

    eventPlayer.progress_hud[ProgHUD.TEXT] = "Entering hero picker..."
    eventPlayer.progress_hud[ProgHUD.COLOR] = s(Setting.BASE_COLOR)
    chaseProgress(
        0.6,
        eventPlayer.uiState != UIState.NORMAL
        or eventPlayer.active_base_owner != eventPlayer
        or not eventPlayer.isHoldingButton(Button.ULTIMATE)
    )
    if eventPlayer.progress == 100:
        Tutorial()
        if eventPlayer.rider:
            EjectRider()
        eventPlayer.last_transform = [pos(), face()]
        eventPlayer.setAllowedHeroes(getAllHeroes().exclude(eventPlayer.getCurrentHero()))
        if f"{eventPlayer}" in ["DJBASTION", "Bastion"]:
            eventPlayer.setAllowedHeroes(Hero.BASTION)
        else:
            eventPlayer.resetHeroAvailability()
    unchaseProgress(0.6)
    wait(0.5)


rule "— Remove base":
    @Event eachPlayer
    @Condition eventPlayer.progress == 0
    @Condition eventPlayer.base_vector
    @Condition eventPlayer.uiState == UIState.NORMAL
    @Condition eventPlayer.isHoldingButton(Button.RELOAD)

    eventPlayer.progress_hud[ProgHUD.TEXT] = "Removing base..."
    eventPlayer.progress_hud[ProgHUD.COLOR] = s(Setting.BASE_COLOR)
    if eventPlayer.active_base_owner == eventPlayer: 
        chaseProgress(
            1,
            eventPlayer.uiState != UIState.NORMAL
            or eventPlayer.active_base_owner != eventPlayer
            or not eventPlayer.isHoldingButton(Button.RELOAD)
        )
    elif eventPlayer.isHoldingButton(Button.CROUCH):
        chaseProgress(
            1,
            eventPlayer.uiState == UIState.MODERATING
            or eventPlayer.uiState == UIState.DREAM_MODE
            or eventPlayer.active_base_owner == eventPlayer
            or not eventPlayer.isHoldingButton(Button.CROUCH)
            or not eventPlayer.isHoldingButton(Button.RELOAD)
        )
    if eventPlayer.progress == 100:
        RemoveBase()
    unchaseProgress(1)
    wait(0.5)


rule "— Fast travel":
    @Event eachPlayer
    @Condition eventPlayer.progress == 0
    @Condition eventPlayer.uiState == UIState.NORMAL
    @Condition not eventPlayer.mount
    @Condition s(Setting.FAST_TRAVEL)
    @Condition s(Setting.PLAYER_MODE) or (
        eventPlayer.active_base_owner == eventPlayer and not s(Setting.BASE_LOCK)
    )
    @Condition eventPlayer.isHoldingButton(Button.MELEE)

    eventPlayer.base_to_fast_travel_owner = friendly_base_in_crosshair(eventPlayer)

    if eventPlayer.base_to_fast_travel_owner:
        eventPlayer.progress_hud[ProgHUD.TEXT] = "Fast traveling to {} {}'s base...".format(
            heroIcon(eventPlayer.base_to_fast_travel_owner.getCurrentHero()),
            eventPlayer.base_to_fast_travel_owner
        )
        eventPlayer.progress_hud[ProgHUD.COLOR] = eventPlayer.base_to_fast_travel_owner.settings[Setting.BASE_COLOR]
    elif eventPlayer.base_vector and eventPlayer.current_base_owner != eventPlayer:
        eventPlayer.base_to_fast_travel_owner = eventPlayer
        eventPlayer.progress_hud[ProgHUD.TEXT] = "Fast traveling to your base..."
        eventPlayer.progress_hud[ProgHUD.COLOR] = s(Setting.BASE_COLOR)
    elif s(Setting.PLAYER_MODE) and eventPlayer.active_base_owner and eventPlayer.last_pos:
        eventPlayer.progress_hud[ProgHUD.TEXT] = "Fast traveling to previous position..."
        eventPlayer.progress_hud[ProgHUD.COLOR] = s(Setting.BASE_COLOR)
        chaseProgress(
            0.6,
            eventPlayer.uiState == UIState.IN_ORB
            or eventPlayer.isDead()
            or not eventPlayer.active_base_owner
            or not eventPlayer.isHoldingButton(Button.MELEE)
        )
        if eventPlayer.progress == 100:
            eventPlayer.teleport(eventPlayer.last_pos)
            eventPlayer.last_pos = null
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
            and eventPlayer.base_to_fast_travel_owner.settings[Setting.BASE_MODE] != BaseMode.FRIENDLY
        )
        or not (s(Setting.PLAYER_MODE) or eventPlayer.active_base_owner)
        or not eventPlayer.base_to_fast_travel_owner.base_vector
        or eventPlayer in getPlayersInRadius(
            eventPlayer.base_to_fast_travel_owner.base_vector,
            eventPlayer.base_to_fast_travel_owner.settings[Setting.BASE_SIZE],
            Team.ALL,
            LosCheck.OFF
        )
        or not eventPlayer.isHoldingButton(Button.MELEE)
    )
    if eventPlayer.progress == 100:
        eventPlayer.last_pos = pos()
        eventPlayer.activate_base_now = true
        eventPlayer.progress = 0
        eventPlayer.teleport(eventPlayer.base_to_fast_travel_owner.base_vector)
        stopMomentum()
    unchaseProgress(0.6)
    wait(0.5)


def UpdateBaseOwner():
    @Name "— Update current base owner"

    eventPlayer.current_base_owner = ([
        p for p in getAllPlayers() if p.base_vector
        and eventPlayer in getPlayersInRadius(
            p.base_vector,
            p.settings[Setting.BASE_SIZE],
            Team.ALL,
            LosCheck.OFF
    )])[0]
    if not eventPlayer.current_base_owner:
        eventPlayer.activate_base_now = false
        eventPlayer.active_base_owner = null
    async(UpdateBaseEffects, AsyncBehavior.RESTART)


def ActivateFriendlyBase():
    @Name "— Activate friendly base"

    if eventPlayer.active_base_owner != eventPlayer:
        if eventPlayer.current_base_owner == eventPlayer:
            chaseBaseProgress(
                0.6,
                eventPlayer.activate_base_now
                or eventPlayer.current_base_owner != eventPlayer
            )
        elif eventPlayer.current_base_owner.settings[Setting.BASE_MODE] == BaseMode.FRIENDLY:
            chaseBaseProgress(
                0.6,
                eventPlayer.activate_base_now
                or eventPlayer.current_base_owner.settings[Setting.BASE_MODE] != BaseMode.FRIENDLY
                or eventPlayer.last_known_base_owner != eventPlayer.current_base_owner
            )

        if eventPlayer.base_progress == 100 or eventPlayer.activate_base_now:
            eventPlayer.active_base_owner = eventPlayer.current_base_owner
            eventPlayer.activate_base_now = false
            BuffExplosionSound()
        eventPlayer.base_progress = 0
    UpdateBaseEffects()


def RemoveBase():
    @Name "— Remove base"

    eventPlayer.base_vector = null
    DestroyBase()
    UpdateBaseEffects()
    BackupPlayer()  


def Confine():
    @Name "— Confine to base"

    do:
        eventPlayer.applyImpulse(
            directionTowards(
                pos(),
                eventPlayer.active_base_owner.base_vector
            ),
            10 if eventPlayer.isOnGround() else 0.00001,
            Relativity.TO_WORLD,
            Impulse.CANCEL_CONTRARY_MOTION_XYZ
        )
        if not eventPlayer in getPlayersInRadius(
            eventPlayer.active_base_owner.base_vector,
            eventPlayer.active_base_owner.settings[Setting.BASE_SIZE] + 3,
            Team.ALL,
            LosCheck.OFF
        ):
            eventPlayer.cancelPrimaryAction()
            eventPlayer.teleport(
                directionTowards(
                    eventPlayer.active_base_owner.base_vector,
                    pos()
                )
                * (eventPlayer.active_base_owner.settings[Setting.BASE_SIZE])
                + eventPlayer.active_base_owner.base_vector
            )
        wait(0.1)
    while isInDifferentBase() and isConfined()


def Repel():
    @Name "— Repel from base"

    do:
        eventPlayer.applyImpulse(
            directionTowards(eventPlayer.current_base_owner.base_vector, pos()),
            15,
            Relativity.TO_WORLD,
            Impulse.CANCEL_CONTRARY_MOTION_XYZ
        )
        if eventPlayer.current_base_owner.settings[Setting.BASE_MODE] == BaseMode.HOSTILE:
            damage(
                eventPlayer,
                eventPlayer.current_base_owner,
                eventPlayer.getHealth() * (
                    eventPlayer.current_base_owner.settings[Setting.BASE_SIZE]
                    - distance(
                        eventPlayer.current_base_owner.base_vector,
                        pos()
                    )
                )
                / eventPlayer.current_base_owner.settings[Setting.BASE_SIZE]
            )
        wait(0.25)
    while [
        p for p in getAllPlayers()
        if p.base_vector
        and eventPlayer in getPlayersInRadius(
            p.base_vector,
            p.settings[Setting.BASE_SIZE],
            Team.ALL,
            LosCheck.OFF
        )
    ][0].settings[Setting.BASE_MODE] >= BaseMode.REPULSIVE


