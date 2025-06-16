#!mainFile "../main.opy"

rule "Fluctuator":
    @Delimiter
    @Disabled


rule "— Fluctuate":
    @Event eachPlayer
    @Condition not optimize
    @Condition eventPlayer.preferences[Preference.FLUCTUATOR_MODE] != Fluctuator.OFF
    @Condition eventPlayer.active_base_owner != eventPlayer

    do:
        for eventPlayer.flux_i in range(len(preferences_flux_data)):
            if not eventPlayer.preferences[preferences_flux_data[eventPlayer.flux_i][FluxDataProperty.FLUX_PREFERENCE]]:
                continue
            switch preferences_data[preferences_flux_data[eventPlayer.flux_i][FluxDataProperty.MAIN_PREFERENCE]][PreferenceProperty.TYPE]:
                case PreferenceType.NUMERIC:
                    if eventPlayer.preferences[Preference.FLUCTUATOR_MODE] == Fluctuator.INCREMENTAL:
                        eventPlayer.preferences_flux[preferences_flux_data[eventPlayer.flux_i][FluxDataProperty.MAIN_PREFERENCE]] = random.randint(
                            max(
                                preferences_data[preferences_flux_data[eventPlayer.flux_i][FluxDataProperty.MAIN_PREFERENCE]][PreferenceProperty.PARAMETERS][Numeric.MIN],
                                eventPlayer.preferences_flux[preferences_flux_data[eventPlayer.flux_i][FluxDataProperty.MAIN_PREFERENCE]]
                                - preferences_data[preferences_flux_data[eventPlayer.flux_i][FluxDataProperty.MAIN_PREFERENCE]][PreferenceProperty.PARAMETERS][Numeric.STEP]
                            ),
                            min(
                                preferences_data[preferences_flux_data[eventPlayer.flux_i][FluxDataProperty.MAIN_PREFERENCE]][PreferenceProperty.PARAMETERS][Numeric.MAX],
                                eventPlayer.preferences_flux[preferences_flux_data[eventPlayer.flux_i][FluxDataProperty.MAIN_PREFERENCE]]
                                + preferences_data[preferences_flux_data[eventPlayer.flux_i][FluxDataProperty.MAIN_PREFERENCE]][PreferenceProperty.PARAMETERS][Numeric.STEP]
                            )
                        )
                    elif eventPlayer.preferences[Preference.FLUCTUATOR_MODE] == Fluctuator.RANDOM:
                        eventPlayer.preferences_flux[preferences_flux_data[eventPlayer.flux_i][FluxDataProperty.MAIN_PREFERENCE]] = random.randint(
                            preferences_data[preferences_flux_data[eventPlayer.flux_i][FluxDataProperty.MAIN_PREFERENCE]][PreferenceProperty.PARAMETERS][Numeric.MIN],
                            preferences_data[preferences_flux_data[eventPlayer.flux_i][FluxDataProperty.MAIN_PREFERENCE]][PreferenceProperty.PARAMETERS][Numeric.MAX]
                        )
                    break
                case PreferenceType.BOOLEAN:
                    eventPlayer.preferences_flux[preferences_flux_data[eventPlayer.flux_i][FluxDataProperty.MAIN_PREFERENCE]] = random.randint(0, 1)
                    break
        async(UpdateFluxSettings, AsyncBehavior.RESTART)
        waitLoadMore()
    while RULE_CONDITION


def UpdateFluxSettings():
    @Name "Update flux settings"

    for eventPlayer.flux_i in range(len(preferences_flux_data)):
        if eventPlayer.preferences[preferences_flux_data[eventPlayer.flux_i][FluxDataProperty.FLUX_PREFERENCE]]:
            switch preferences_flux_data[eventPlayer.flux_i][FluxDataProperty.MAIN_PREFERENCE]:
                case Preference.SIZE:
                    UpdateSizeNoclip()
                    break
                case Preference.SPEED:
                case Preference.JUMP_SPEED:
                    UpdatePhysics()
                    break
                case Preference.VOICE_PITCH:
                    updatePitch()
                    break
                case Preference.DAMAGE:
                case Preference.HEALING:
                case Preference.HEALTH:
                    UpdateHero()
                    break
                case Preference.KNOCKBACK:
                    UpdateKnockback()
                    break
                case Preference.PROJECTILE_SPEED:
                case Preference.PROJECTILE_GRAVITY:
                    UpdateProjectiles()
                    break
                case Preference.INVISIBILITY:
                    UpdateInvisibility()
                    break