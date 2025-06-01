#!mainFile "../main.opy"

rule "Backup":
    @Disabled
    @Delimiter


def BackupPlayer():
    @Name "— Backup player preferences"

    if player_names_backups.index("{}".format(eventPlayer)) < 0:
        player_names_backups.append("{}".format(eventPlayer))
    base_vectors_backups[player_names_backups.index("{}".format(eventPlayer))] = eventPlayer.base_vector
    main_preferences_backups[player_names_backups.index("{}".format(eventPlayer))] = eventPlayer.main_preferences
    game_preferences_backups[player_names_backups.index("{}".format(eventPlayer))] = eventPlayer.game_preferences
    effects_preferences_backups[player_names_backups.index("{}".format(eventPlayer))] = eventPlayer.effects_preferences
    hero_preferences_backups[player_names_backups.index("{}".format(eventPlayer))] = eventPlayer.hero_preferences
    unbound_preferences_backups[player_names_backups.index("{}".format(eventPlayer))] = eventPlayer.unbound_preferences
    special_preferences_backups[player_names_backups.index("{}".format(eventPlayer))] = eventPlayer.special_preferences
    base_preferences_backups[player_names_backups.index("{}".format(eventPlayer))] = eventPlayer.base_preferences
    dream_preferences_backups[player_names_backups.index("{}".format(eventPlayer))] = eventPlayer.dream_preferences