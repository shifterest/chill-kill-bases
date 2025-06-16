#!suppressWarnings w_ow2_rule_condition_chase
#!translations en es ja ko zh ru fr

settings {
    "main": {
        "description": "Chill / Kill Bases (by shifterest)\r\n» [v4.4] Last updated: 6/2/2025\r\n\r\nCode: TSX53\r\n\r\nA chill or kill gamemode designed with AFKing in mind.\r\n\r\nBased on:\r\n» Chill Zone Base Creator by AlaskaWolf • ARYD2\r\n» Chill/Kill by QueenWolf • Y239C\r\n» Base Wars by Zezombye • 14WON",
        "modeName": "★ Chill n' Friendly Bases ★"
    },
    "lobby": {
        "allowPlayersInQueue": true,
        "enableMatchVoiceChat": true,
        "team1Slots": 6,
        "team2Slots": 6,
        "spectatorSlots": 12,
        "returnToLobby": "never"
    },
    "gamemodes": {
        "ffa": {
            "enablePerks": true,
            "disabledMaps": [
                "workshopChamber",
                "workshopGreenScreen",
                "workshopIsland",
                "workshopIslandNight"
            ],
            "scoreToWin": 5000
        },
        "skirmish": {
            "enablePerks": true,
            "disabledMaps": [
                "workshopChamber",
                "workshopGreenScreen",
                "workshopIsland",
                "workshopIslandNight"
            ]
        },
        "general": {
            "gamemodeStartTrigger": "immediately",
            "heroLimit": "off",
            "respawnTime%": 50,
            "spawnHealthPacks": "enabled"
        }
    }
}

#!include "script/variables.opy"
#!include "script/subroutines.opy"
#!include "script/enums.opy"
#!include "script/macros.opy"

#!include "rules/abilities.opy"
#!include "rules/backup.opy"
#!include "rules/base.opy"
#!include "rules/cameras.opy"
#!include "rules/dream.opy"
#!include "rules/huds.opy"
#!include "rules/init.opy"
#!include "rules/keyboard.opy"
#!include "rules/loops.opy"
#!include "rules/moderator.opy"
#!include "rules/mount.opy"
#!include "rules/orb.opy"
#!include "rules/stasis.opy"
#!include "rules/player.opy"
#!include "rules/special.opy"
#!include "rules/unbound.opy"
#!include "rules/update.opy"
#!include "rules/fluctuator.opy"

rule "— Debug HUD":
    # @Disabled
    @Event eachPlayer

    debug(eventPlayer.preferences_flux[Preference.VOICE_PITCH])