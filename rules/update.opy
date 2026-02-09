#!mainFile "../main.opy"

rule "Update":
    @Disabled
    @Delimiter


def InitializePlayer():
    @Name "— Initialize player"

    UpdateHero()
    UpdateAura()
    async(UpdateCamera, AsyncBehavior.RESTART)
    updatePitch()
    UpdateAFKTimer()
    waitUntil(eventPlayer.hasSpawned(), Math.INFINITY)
    updateHeroOutline()
    UpdateMessage()

    
def UpdateHero():
    @Name "— Update hero"

    switch s(Setting.PLAYER_MODE):
        case PlayerMode.KILL:
            eventPlayer.setDamageDealt(100)
            eventPlayer.setDamageReceived(100)
            eventPlayer.setHealingDealt(100)
            eventPlayer.setMaxHealth(100)
            eventPlayer.setUltCharge(0)
            break
        case PlayerMode.CHILL:
            eventPlayer.setDamageDealt(max(s(Setting.DAMAGE), 0.1))
            eventPlayer.setDamageReceived(100)
            eventPlayer.setHealingDealt(max(s(Setting.HEALING), 0.1))
            eventPlayer.setMaxHealth(s(Setting.HEALTH))
            eventPlayer.setHealth(999999999)
            break
        case PlayerMode.ZEN:
            eventPlayer.setDamageDealt(0)
            eventPlayer.setDamageReceived(0)
            eventPlayer.setHealingDealt(0)
            eventPlayer.setMaxHealth(100)
            eventPlayer.setHealth(eventPlayer.getMaxHealth())
            break

    UpdateAbilities()
    UpdatePhase()
    UpdateHoT()
    UpdateFlight()
    UpdateKnockback()
    UpdateSizeNoclip()
    UpdatePhysics()
    UpdateInvisibility()
    UpdateProjectiles()
    UpdateRider()
    UpdateHUD()
    UpdateAmmo()


def UpdateBaseEffects():
    @Name "— Update base effects"

    UpdateAbilities()
    UpdatePhase()
    UpdateHoT()
    UpdateSizeNoclip()
    UpdatePhysics()
    UpdateHUD()
    UpdateInvisibility()
    if s(Setting.THIRD_PERSON) != ThirdPersonCamera.OFF:
        UpdateCamera()


def UpdateAbilities():
    @Name "— Update abilities"

    eventPlayer.allowButton(Button.CROUCH)

    if eventPlayer.uiState != UIState.NORMAL:
        DisableAbilities()
        eventPlayer.disallowButton(Button.CROUCH)
    elif eventPlayer.active_base_owner == eventPlayer:
        DisableAbilities()
    elif (
        eventPlayer.active_base_owner.settings[Setting.BASE_MODE] == BaseMode.FRIENDLY
        or s(Setting.PLAYER_MODE) == PlayerMode.ZEN
    ):
        DisableAbilities()
    else:
        EnableAbilities()

    if (
        (s(Setting.PLAYER_MODE) == PlayerMode.ZEN or eventPlayer.active_base_owner)
        and not (
            eventPlayer.isDuplicatingAHero()
            or eventPlayer.uiState != UIState.NORMAL
        )
    ):
        switch eventPlayer.getCurrentHero():
            case Hero.ASHE:
            case Hero.ANA:
            case Hero.ANRAN:
                eventPlayer.setSecondaryFireEnabled(true)
                eventPlayer.allowButton(Button.SECONDARY_FIRE)
                break
            case Hero.ORISA:
            case Hero.ECHO:
            case Hero.MEI:
            case Hero.PHARAH:
            case Hero.KIRIKO:
            case Hero.LUCIO:
            case Hero.ZARYA:
            case Hero.BASTION:
            case Hero.SOJOURN:
            case Hero.MOIRA:
            case Hero.CASSIDY:
            case Hero.RAMATTRA:
            case Hero.JUNO:
            case Hero.WUYANG:
                eventPlayer.setAbility1Enabled(true)
                break
            case Hero.WINSTON:
                eventPlayer.allowButton(Button.ULTIMATE)
                break
            case Hero.REAPER:
            case Hero.TRACER:
            case Hero.HANZO:
                eventPlayer.setAbility1Enabled(true)
                eventPlayer.setAbility2Enabled(true)
                eventPlayer.allowButton(Button.INTERACT)
                break
            case Hero.SOMBRA:
                eventPlayer.setAbility2Enabled(true)
                break
            case Hero.SOLDIER:
            case Hero.MERCY:
                eventPlayer.setAbility1Enabled(true)
                eventPlayer.allowButton(Button.ULTIMATE)
                break
            case Hero.TORBJORN:
            case Hero.ROADHOG:
                eventPlayer.setAbility2Enabled(true)
                eventPlayer.allowButton(Button.ULTIMATE)
                eventPlayer.allowButton(Button.INTERACT)
                break
            case Hero.WIDOWMAKER:
                eventPlayer.setSecondaryFireEnabled(true)
                eventPlayer.setAbility1Enabled(true)
                eventPlayer.allowButton(Button.SECONDARY_FIRE)
                eventPlayer.allowButton(Button.ULTIMATE)
                break
            case Hero.HAMMOND:
                eventPlayer.setAbility1Enabled(true)
                eventPlayer.setAbility2Enabled(true)
                eventPlayer.disallowButton(Button.CROUCH)
                break
            case Hero.FREJA:
                eventPlayer.setAbility1Enabled(true)
                eventPlayer.setAbility2Enabled(true)
                eventPlayer.setSecondaryFireEnabled(true)
                eventPlayer.allowButton(Button.SECONDARY_FIRE)
                break


def DisableAbilities():
    @Name "— Disable abilities"

    eventPlayer.setSecondaryFireEnabled(false)
    eventPlayer.setMeleeEnabled(false)
    eventPlayer.setAbility1Enabled(false)
    eventPlayer.setAbility2Enabled(false)
    eventPlayer.disallowButton(Button.PRIMARY_FIRE)
    eventPlayer.disallowButton(Button.SECONDARY_FIRE)
    eventPlayer.disallowButton(Button.ULTIMATE)
    eventPlayer.disallowButton(Button.INTERACT)


def EnableAbilities():
    @Name "— Enable abilities"

    eventPlayer.setSecondaryFireEnabled(true)
    eventPlayer.setMeleeEnabled(true)
    eventPlayer.setAbility1Enabled(true)
    eventPlayer.setAbility2Enabled(true)
    eventPlayer.allowButton(Button.PRIMARY_FIRE)
    eventPlayer.allowButton(Button.SECONDARY_FIRE)
    eventPlayer.allowButton(Button.ULTIMATE)
    eventPlayer.allowButton(Button.INTERACT)


def UpdateFlight():
    @Name "— Update flight"

    if s(Setting.PLAYER_MODE) and s(Setting.FLIGHT):
        eventPlayer.startAcceleration(
            Vector.UP,
            evalOnce(s(Setting.FLIGHT_ACCELERATION))
            if eventPlayer.uiState == UIState.NORMAL
            and eventPlayer.isHoldingButton(Button.JUMP)
            else 0,
            evalOnce(s(Setting.FLIGHT_ACCELERATION) * 2),
            Relativity.TO_PLAYER,
            AccelReeval.DIRECTION_RATE_AND_MAX_SPEED
        )
    else:
        eventPlayer.stopAcceleration()


def UpdateKnockback():
    @Name "— Update knockback dealt"

    if s(Setting.PLAYER_MODE):
        eventPlayer.setKnockbackDealt(s(Setting.KNOCKBACK))
    else:
        eventPlayer.setKnockbackDealt(100)


def UpdateSizeNoclip():
    @Name "— Update hero size and environmental collision"

    if s(Setting.PLAYER_MODE) and s(Setting.SIZE) != 100:
        eventPlayer.startScalingSize(s(Setting.SIZE) / 100, false)
    else:
        eventPlayer.stopScalingSize()

    if eventPlayer.current_base_owner and eventPlayer.current_base_owner.settings[Setting.BASE_MODE] != BaseMode.HIDDEN:
        if eventPlayer.current_base_owner.settings[Setting.BASE_NOCLIP]:
            eventPlayer.disableEnvironmentCollision(false)
        else:
            eventPlayer.enableEnvironmentCollision()
    elif s(Setting.PLAYER_MODE) >= PlayerMode.CHILL:
        if s(Setting.NOCLIP):
            eventPlayer.disableEnvironmentCollision(false)
        elif s(Setting.SIZE) > 100:
            eventPlayer.disableEnvironmentCollision(false)
        else:
            eventPlayer.enableEnvironmentCollision()
    else:
        eventPlayer.enableEnvironmentCollision()


def UpdatePhysics():
    @Name "— Update gravity and speeds"

    if eventPlayer.current_base_owner and eventPlayer.current_base_owner.settings[Setting.BASE_MODE] != BaseMode.HIDDEN:
        eventPlayer.setGravity(eventPlayer.current_base_owner.settings[Setting.BASE_GRAVITY])
        eventPlayer.setMoveSpeed(eventPlayer.current_base_owner.settings[Setting.BASE_SPEED])
        eventPlayer.setJumpVerticalSpeed(eventPlayer.current_base_owner.settings[Setting.BASE_JUMP_SPEED])
    elif s(Setting.PLAYER_MODE):
        eventPlayer.setGravity(s(Setting.GRAVITY))
        eventPlayer.setMoveSpeed(s(Setting.SPEED))
        eventPlayer.setJumpVerticalSpeed(s(Setting.JUMP_SPEED))
    else:
        eventPlayer.setGravity(100)
        eventPlayer.setMoveSpeed(100)
        eventPlayer.setJumpVerticalSpeed(100)


def UpdateProjectiles():
    @Name "— Update projectile speed and gravity"

    if s(Setting.PLAYER_MODE):
        eventPlayer.setProjectileSpeed(s(Setting.PROJECTILE_SPEED))
        eventPlayer.setProjectileGravity(s(Setting.PROJECTILE_GRAVITY))
    else:
        eventPlayer.setProjectileSpeed(100)
        eventPlayer.setProjectileGravity(100)


def UpdateInvisibility():
    @Name "— Update invisibility"

    if eventPlayer.uiState == UIState.IN_MENU:
        eventPlayer.setInvisibility(Invis.ALL)
        eventPlayer.isInvisible = true
    elif (
        s(Setting.PLAYER_MODE)
        and s(Setting.INVISIBILITY)
    ) or (
        eventPlayer.active_base_owner == eventPlayer
        and s(Setting.BASE_MODE) == BaseMode.HIDDEN
    ):
        eventPlayer.setInvisibility(Invis.ENEMIES)
        eventPlayer.isInvisible = true
    else:
        eventPlayer.setInvisibility(Invis.NONE)
        eventPlayer.isInvisible = false


def UpdatePhase():
    @Name "— Update phased status effect"

    if eventPlayer.active_base_owner == eventPlayer:
        eventPlayer.setStatusEffect(null, Status.PHASED_OUT, Math.INFINITY)
    elif (
        s(Setting.PLAYER_MODE) == PlayerMode.ZEN
        or eventPlayer.uiState == UIState.DREAM_MODE
        or (
            eventPlayer.active_base_owner
            and eventPlayer.active_base_owner.settings[Setting.BASE_MODE] == BaseMode.FRIENDLY
        )
    ):
        eventPlayer.setStatusEffect(null, Status.PHASED_OUT, Math.INFINITY)
    elif eventPlayer.hasStatusEffect(Status.PHASED_OUT):
        eventPlayer.clearStatusEffect(Status.PHASED_OUT)


def UpdateHoT():
    @Name "— Update healing over time"

    if eventPlayer.hasStatusEffect(Status.PHASED_OUT):
        eventPlayer.startHoT(eventPlayer, Math.INFINITY, 500)
    else:
        eventPlayer.stopAllHoT()

def UpdateAmmo():
    @Name "— Update ammo"

    if s(Setting.PLAYER_MODE) and s(Setting.AMMO_OVERLOAD):
        eventPlayer.setMaxAmmo(0, 1000)
        eventPlayer.setAmmo(0, 1000)
        eventPlayer.setMaxAmmo(1, 1000)
        eventPlayer.setAmmo(1, 1000)
    else:
        eventPlayer.last_hero = eventPlayer.getCurrentHero()
        eventPlayer.last_transform = [eventPlayer.getPosition(), eventPlayer.getFacingDirection()]
        eventPlayer.setAllowedHeroes(getAllHeroes().exclude(eventPlayer.last_hero))
        wait()
        eventPlayer.startForcingHero(eventPlayer.last_hero)
        wait()
        eventPlayer.stopForcingCurrentHero()
        ReturnImmediately()
        iconMessage(eventPlayer, iconString(Icon.CHECKMARK), "Ammo reset")
        # eventPlayer.setAmmo(0, eventPlayer.getMaxAmmo(0))
        # eventPlayer.setAmmo(1, eventPlayer.getMaxAmmo(1))