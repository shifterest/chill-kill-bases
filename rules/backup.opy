#!mainFile "../main.opy"

rule "Backup":
    @Disabled
    @Delimiter


def BackupPlayer():
    @Name "— Backup player preferences"

    if player_names_backups.index("{}".format(eventPlayer)) < 0:
        player_names_backups.append("{}".format(eventPlayer))
    base_vectors_backups[player_names_backups.index("{}".format(eventPlayer))] = eventPlayer.base_vector
    preferences_backups[player_names_backups.index("{}".format(eventPlayer))] = eventPlayer.preferences
