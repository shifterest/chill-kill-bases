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
    waitUntil(eventPlayer.hasSpawned(), 99999)
    updateHeroOutline()
    UpdateMessage()


def UpdateHero():
    @Name "— Update hero"

    switch eventPlayer.main_preferences[Main.PLAYER_MODE]:
        case PlayerMode.KILL:
            eventPlayer.setDamageDealt(100)
            eventPlayer.setDamageReceived(100)
            eventPlayer.setHealingDealt(100)
            eventPlayer.setMaxHealth(100)
            eventPlayer.setUltCharge(0)
            break
        case PlayerMode.CHILL:
        case PlayerMode.ZEN:
            eventPlayer.setDamageDealt(0)
            eventPlayer.setDamageReceived(0)
            eventPlayer.setHealingDealt(0)
            eventPlayer.setMaxHealth(100)
            eventPlayer.setHealth(eventPlayer.getMaxHealth())
            break
        case PlayerMode.UNBOUND:
            eventPlayer.setDamageDealt(max(eventPlayer.unbound_preferences[Unbound.DAMAGE], 0.1))
            eventPlayer.setDamageReceived(100)
            eventPlayer.setHealingDealt(max(eventPlayer.unbound_preferences[Unbound.HEALING], 0.1))
            eventPlayer.setMaxHealth(eventPlayer.unbound_preferences[Unbound.HEALTH])
            eventPlayer.setHealth(999999999)
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


def Transition():
    @Name "— Transition between in-base and outside"

    UpdateAbilities()
    UpdatePhase()
    UpdateHoT()
    UpdateSizeNoclip()
    UpdatePhysics()
    UpdateHUD()


def UpdateAbilities():
    @Name "— Update abilities"

    eventPlayer.allowButton(Button.CROUCH)

    if eventPlayer.isInModeratorMode or eventPlayer.isUsingKeyboard or eventPlayer.isViewingPreferences:
        DisableAbilities()
        eventPlayer.disallowButton(Button.CROUCH)
    elif eventPlayer.base_settled_owner == eventPlayer:
        DisableAbilities()
    elif (
        eventPlayer.base_settled_owner.main_preferences[Main.BASE_MODE] == BaseMode.FRIENDLY
        or eventPlayer.main_preferences[Main.PLAYER_MODE] == PlayerMode.ZEN
    ):
        DisableAbilities()
    else:
        EnableAbilities()

    if (
        (eventPlayer.main_preferences[Main.PLAYER_MODE] == PlayerMode.ZEN or eventPlayer.base_settled_owner)
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

    if eventPlayer.main_preferences[Main.PLAYER_MODE] and eventPlayer.hero_preferences[Hero.FLIGHT]:
        eventPlayer.startAcceleration(
            Vector.UP,
            evalOnce(eventPlayer.hero_preferences[Hero.FLIGHT_ACCELERATION])
            if eventPlayer.isHoldingButton(Button.JUMP)
            else 0,
            evalOnce(eventPlayer.hero_preferences[Hero.FLIGHT_ACCELERATION] * 2),
            Relativity.TO_PLAYER,
            AccelReeval.DIRECTION_RATE_AND_MAX_SPEED
        )
    else:
        eventPlayer.stopAcceleration()


def UpdateKnockback():
    @Name "— Update knockback dealt and received"

    if eventPlayer.main_preferences[Main.PLAYER_MODE]:
        eventPlayer.setKnockbackDealt(eventPlayer.hero_preferences[Hero.KNOCKBACK])
        if eventPlayer.main_preferences[Main.PLAYER_MODE] == PlayerMode.UNBOUND or eventPlayer.hero_preferences[Hero.KNOCKBACK] > 100:
            eventPlayer.setKnockbackReceived(100)
        else:
            eventPlayer.setKnockbackReceived(5)
    else:
        eventPlayer.setKnockbackDealt(100)
        eventPlayer.setKnockbackReceived(100)


def UpdateSizeNoclip():
    @Name "— Update hero size and environmental collision"

    if eventPlayer.main_preferences[Main.PLAYER_MODE] and eventPlayer.hero_preferences[Hero.SIZE] != 100:
        eventPlayer.startScalingSize(eventPlayer.hero_preferences[Hero.SIZE] / 100, false)
    else:
        eventPlayer.stopScalingSize()

    if eventPlayer.base_within_owner:
        if eventPlayer.base_within_owner.base_preferences[Base.NOCLIP]:
            eventPlayer.disableEnvironmentCollision(false)
        else:
            eventPlayer.enableEnvironmentCollision()
    elif eventPlayer.main_preferences[Main.PLAYER_MODE]:
        if eventPlayer.special_preferences[Special.NOCLIP]:
            eventPlayer.disableEnvironmentCollision(false)
        elif eventPlayer.hero_preferences[Hero.SIZE] > 100:
            eventPlayer.disableEnvironmentCollision(false)
        else:
            eventPlayer.enableEnvironmentCollision()
    else:
        eventPlayer.enableEnvironmentCollision()


def UpdatePhysics():
    @Name "— Update gravity and speeds"

    if eventPlayer.base_within_owner:
        eventPlayer.setGravity(eventPlayer.base_within_owner.base_preferences[Base.GRAVITY])
        eventPlayer.setMoveSpeed(eventPlayer.base_within_owner.base_preferences[Base.SPEED])
        eventPlayer.setJumpVerticalSpeed(eventPlayer.base_within_owner.base_preferences[Base.JUMP_SPEED])
    elif eventPlayer.main_preferences[Main.PLAYER_MODE]:
        eventPlayer.setGravity(eventPlayer.hero_preferences[Hero.GRAVITY])
        eventPlayer.setMoveSpeed(eventPlayer.hero_preferences[Hero.SPEED])
        eventPlayer.setJumpVerticalSpeed(eventPlayer.hero_preferences[Hero.JUMP_SPEED])
    else:
        eventPlayer.setGravity(100)
        eventPlayer.setMoveSpeed(100)
        eventPlayer.setJumpVerticalSpeed(100)


def UpdateProjectiles():
    @Name "— Update projectile speed and gravity"

    if eventPlayer.main_preferences[Main.PLAYER_MODE]:
        eventPlayer.setProjectileSpeed(eventPlayer.hero_preferences[Hero.PROJECTILE_SPEED])
        eventPlayer.setProjectileGravity(eventPlayer.hero_preferences[Hero.PROJECTILE_GRAVITY])
    else:
        eventPlayer.setProjectileSpeed(100)
        eventPlayer.setProjectileGravity(100)


def UpdateInvisibility():
    @Name "— Update invisibility"

    if eventPlayer.main_preferences[Main.PLAYER_MODE] and eventPlayer.special_preferences[Special.INVISIBILITY]:
        eventPlayer.setInvisibility(Invis.ENEMIES)
        eventPlayer.isInvisible = true
    else:
        eventPlayer.setInvisibility(Invis.NONE)
        eventPlayer.isInvisible = false


def UpdatePhase():
    @Name "— Update phased status effect"

    if eventPlayer.base_settled_owner == eventPlayer:
        eventPlayer.setStatusEffect(null, Status.PHASED_OUT, 99999)
    elif (
        eventPlayer.base_settled_owner.main_preferences[Main.BASE_MODE]
        == BaseMode.FRIENDLY
        or (eventPlayer.main_preferences[Main.PLAYER_MODE] == PlayerMode.ZEN)
        or eventPlayer.dream_preferences[Dream.DREAM_MODE]
    ):
        eventPlayer.setStatusEffect(null, Status.PHASED_OUT, 99999)
    elif eventPlayer.hasStatusEffect(Status.PHASED_OUT):
        eventPlayer.clearStatusEffect(Status.PHASED_OUT)


def UpdateHoT():
    @Name "— Update healing over time"

    if eventPlayer.hasStatusEffect(Status.PHASED_OUT):
        eventPlayer.startHoT(eventPlayer, 99999, 500)
    else:
        eventPlayer.stopAllHoT()

def UpdateAmmo():
    @Name "— Update ammo"

    if eventPlayer.main_preferences[Main.PLAYER_MODE] and eventPlayer.special_preferences[Special.AMMO_OVERLOAD]:
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
        iconMessage(eventPlayer, iconString(Icon.HAPPY), "Ammo reset")
        # eventPlayer.setAmmo(0, eventPlayer.getMaxAmmo(0))
        # eventPlayer.setAmmo(1, eventPlayer.getMaxAmmo(1))