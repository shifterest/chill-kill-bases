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

    switch eventPlayer.preferences[Preference.PLAYER_MODE]:
        case PlayerMode.KILL:
            eventPlayer.setDamageDealt(100)
            eventPlayer.setDamageReceived(100)
            eventPlayer.setHealingDealt(100)
            eventPlayer.setMaxHealth(100)
            eventPlayer.setUltCharge(0)
            break
        case PlayerMode.CHILL:
            eventPlayer.setDamageDealt(max(eventPlayer.preferences[Preference.DAMAGE], 0.1))
            eventPlayer.setDamageReceived(100)
            eventPlayer.setHealingDealt(max(eventPlayer.preferences[Preference.HEALING], 0.1))
            eventPlayer.setMaxHealth(eventPlayer.preferences[Preference.HEALTH])
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
    if eventPlayer.preferences[Preference.THIRD_PERSON] != ThirdPersonCamera.OFF:
        UpdateCamera()


def UpdateAbilities():
    @Name "— Update abilities"

    eventPlayer.allowButton(Button.CROUCH)

    if eventPlayer.isInModeratorMode or eventPlayer.isUsingKeyboard or eventPlayer.isViewingPreferences:
        DisableAbilities()
        eventPlayer.disallowButton(Button.CROUCH)
    elif eventPlayer.active_base_owner == eventPlayer:
        DisableAbilities()
    elif (
        eventPlayer.active_base_owner.preferences[Preference.BASE_MODE] == BaseMode.FRIENDLY
        or eventPlayer.preferences[Preference.PLAYER_MODE] == PlayerMode.ZEN
    ):
        DisableAbilities()
    else:
        EnableAbilities()

    if (
        (eventPlayer.preferences[Preference.PLAYER_MODE] == PlayerMode.ZEN or eventPlayer.active_base_owner)
        and not (
            eventPlayer.isDuplicatingAHero()
            or eventPlayer.isInModeratorMode
            or eventPlayer.isUsingKeyboard
            or eventPlayer.isViewingPreferences
        )
    ):
        switch eventPlayer.getCurrentHero():
            case Hero.ASHE:
            case Hero.ANA:
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

    if eventPlayer.preferences[Preference.PLAYER_MODE] and eventPlayer.preferences[Preference.FLIGHT]:
        eventPlayer.startAcceleration(
            Vector.UP,
            evalOnce(eventPlayer.preferences[Preference.FLIGHT_ACCELERATION])
            if eventPlayer.isHoldingButton(Button.JUMP)
            else 0,
            evalOnce(eventPlayer.preferences[Preference.FLIGHT_ACCELERATION] * 2),
            Relativity.TO_PLAYER,
            AccelReeval.DIRECTION_RATE_AND_MAX_SPEED
        )
    else:
        eventPlayer.stopAcceleration()


def UpdateKnockback():
    @Name "— Update knockback dealt"

    if eventPlayer.preferences[Preference.PLAYER_MODE]:
        eventPlayer.setKnockbackDealt(eventPlayer.preferences[Preference.KNOCKBACK])
    else:
        eventPlayer.setKnockbackDealt(100)


def UpdateSizeNoclip():
    @Name "— Update hero size and environmental collision"

    if eventPlayer.preferences[Preference.PLAYER_MODE] and eventPlayer.preferences[Preference.SIZE] != 100:
        eventPlayer.startScalingSize(eventPlayer.preferences[Preference.SIZE] / 100, false)
    else:
        eventPlayer.stopScalingSize()

    if eventPlayer.current_base_owner:
        if eventPlayer.current_base_owner.preferences[Preference.BASE_NOCLIP]:
            eventPlayer.disableEnvironmentCollision(false)
        else:
            eventPlayer.enableEnvironmentCollision()
    elif eventPlayer.preferences[Preference.PLAYER_MODE]:
        if eventPlayer.preferences[Preference.NOCLIP]:
            eventPlayer.disableEnvironmentCollision(false)
        elif eventPlayer.preferences[Preference.SIZE] > 100:
            eventPlayer.disableEnvironmentCollision(false)
        else:
            eventPlayer.enableEnvironmentCollision()
    else:
        eventPlayer.enableEnvironmentCollision()


def UpdatePhysics():
    @Name "— Update gravity and speeds"

    if eventPlayer.current_base_owner:
        eventPlayer.setGravity(eventPlayer.current_base_owner.preferences[Preference.BASE_GRAVITY])
        eventPlayer.setMoveSpeed(eventPlayer.current_base_owner.preferences[Preference.BASE_SPEED])
        eventPlayer.setJumpVerticalSpeed(eventPlayer.current_base_owner.preferences[Preference.BASE_JUMP_SPEED])
    elif eventPlayer.preferences[Preference.PLAYER_MODE]:
        eventPlayer.setGravity(eventPlayer.preferences[Preference.GRAVITY])
        eventPlayer.setMoveSpeed(eventPlayer.preferences[Preference.SPEED])
        eventPlayer.setJumpVerticalSpeed(eventPlayer.preferences[Preference.JUMP_SPEED])
    else:
        eventPlayer.setGravity(100)
        eventPlayer.setMoveSpeed(100)
        eventPlayer.setJumpVerticalSpeed(100)


def UpdateProjectiles():
    @Name "— Update projectile speed and gravity"

    if eventPlayer.preferences[Preference.PLAYER_MODE]:
        eventPlayer.setProjectileSpeed(eventPlayer.preferences[Preference.PROJECTILE_SPEED])
        eventPlayer.setProjectileGravity(eventPlayer.preferences[Preference.PROJECTILE_GRAVITY])
    else:
        eventPlayer.setProjectileSpeed(100)
        eventPlayer.setProjectileGravity(100)


def UpdateInvisibility():
    @Name "— Update invisibility"

    if eventPlayer.preferences[Preference.PLAYER_MODE] and eventPlayer.preferences[Preference.INVISIBILITY]:
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
        eventPlayer.active_base_owner.preferences[Preference.BASE_MODE]
        == BaseMode.FRIENDLY
        or (eventPlayer.preferences[Preference.PLAYER_MODE] == PlayerMode.ZEN)
        or eventPlayer.preferences[Preference.DREAM_MODE]
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

    if eventPlayer.preferences[Preference.PLAYER_MODE] and eventPlayer.preferences[Preference.AMMO_OVERLOAD]:
        eventPlayer.setMaxAmmo(0, 1000)
        eventPlayer.setAmmo(0, 1000)
        eventPlayer.setMaxAmmo(1, 1000)
        eventPlayer.setAmmo(1, 1000)
    else:
        eventPlayer.last_hero = eventPlayer.getCurrentHero()
        eventPlayer.previous_position_direction = [eventPlayer.getPosition(), eventPlayer.getFacingDirection()]
        eventPlayer.setAllowedHeroes(getAllHeroes().exclude(eventPlayer.last_hero))
        wait()
        eventPlayer.startForcingHero(eventPlayer.last_hero)
        wait()
        eventPlayer.stopForcingCurrentHero()
        ReturnImmediately()
        iconMessage(eventPlayer, iconString(Icon.HAPPY), "Ammo reset")
        # eventPlayer.setAmmo(0, eventPlayer.getMaxAmmo(0))
        # eventPlayer.setAmmo(1, eventPlayer.getMaxAmmo(1))