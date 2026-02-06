#!suppressWarnings w_ow2_rule_condition_chase
#!suppressWarnings w_wait_until

settings {
    "main": {
        "description": "Chill / Kill Bases (by shifterest)\r\n\u00bb [v4.7] Last updated: September 25, 2025\r\n\r\nCode: TSX53\r\n\r\nA chill or kill gamemode designed with AFKing in mind.\r\n\r\nBased on:\r\n\u00bb Chill Zone Base Creator by AlaskaWolf \u2022 ARYD2\r\n\u00bb Chill/Kill by QueenWolf \u2022 Y239C\r\n\u00bb Base Wars by Zezombye \u2022 14WON",
        "modeName": "★ Chill Bases · Updated! ★"
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

rule "— Debug HUD":
    # @Disabled
    @Event eachPlayer
