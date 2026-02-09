#!mainFile "../main.opy"

rule "Backup":
    @Disabled
    @Delimiter


def BackupPlayer():
    @Name "— Backup player settings"

    if player_names_backups.index(f"{eventPlayer}") < 0:
        player_names_backups.append(f"{eventPlayer}")
    base_vectors_backups[player_names_backups.index(f"{eventPlayer}")] = eventPlayer.base_vector
    settings_backups[player_names_backups.index(f"{eventPlayer}")] = eventPlayer.settings
