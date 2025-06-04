#!suppressWarnings w_ow2_rule_condition_chase

settings {
    "main": {
        "description": "Chill / Kill Bases Testing (by shifterest)\r\n\r\nCode: TSX53\r\n» Use the code to play the production version!",
        "modeName": "★ CKB Testing ★"
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
            "enabledMaps": ["workshopExpanseNight"],
            "scoreToWin": 5000
        },
        "skirmish": {
            "enablePerks": true,
            "enabledMaps": ["workshopExpanseNight"]
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
#!include "script/macros.opy"
#!include "script/enums.opy"

#!include "rules/init.opy"
#!include "rules/loops.opy"
#!include "rules/backup.opy"
#!include "rules/huds.opy"
#!include "rules/moderator.opy"
#!include "rules/player.opy"
#!include "rules/update.opy"
#!include "rules/base.opy"
#!include "rules/orb.opy"
#!include "rules/keyboard.opy"
#!include "rules/abilities.opy"
#!include "rules/unbound.opy"
#!include "rules/dream.opy"
#!include "rules/cameras.opy"
#!include "rules/paralysis.opy"
#!include "rules/mount.opy"
#!include "rules/special.opy"

rule "— Debug HUD":
    @Condition isInitialized

    hudSubtext(
        localPlayer,
        "Variables: \n{}".format(
            localPlayer.getAmmo(1)
        ),
        HudPosition.LEFT,
        1,
        Color.WHITE,
        HudReeval.VISIBILITY_AND_STRING,
        SpecVisibility.DEFAULT
    )
