#!suppressWarnings w_ow2_rule_condition_chase
#!suppressWarnings w_wait_until
#!setupTags

settings {
    "main": {
        "description": "Chill / Kill Bases (by shifterest)\r\n\u00bb [v5a] Last updated: February 7, 2026\r\n\r\nCode: TSX53\r\n\r\nA chill or kill gamemode designed with AFKing in mind.\r\n\r\nBased on:\r\n\u00bb Chill Zone Base Creator by AlaskaWolf \u2022 ARYD2\r\n\u00bb Chill/Kill by QueenWolf \u2022 Y239C\r\n\u00bb Base Wars by Zezombye \u2022 14WON",
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


# Script files
#!include "script/variables.opy"
#!include "script/enums.opy"
#!include "script/subroutines.opy"
#!include "script/macros.opy"


# Rule files
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
#!include "rules/stasis.opy" 
#!include "rules/player.opy"
#!include "rules/special.opy"
#!include "rules/unbound.opy"
#!include "rules/update.opy"
#!include "rules/orb.opy"


rule "— Workshop settings":
    workshop_settings[WorkshopSettings.SERVER_MODE] = createWorkshopSetting(
        enum["Default", "Music", "Sleep", "shifterest"], "Game settings", "Lobby mode", 0, 0)
    workshop_settings[WorkshopSettings.REDUCE_SERVER_LOAD] = createWorkshopSetting(
        bool, "Game settings", "Reduce server load", false, 2)
    workshop_settings[WorkshopSettings.ENABLE_MATCH_TIMER] = createWorkshopSetting(
        bool, "Match settings", "Enable match timer", false, 1)
    workshop_settings[WorkshopSettings.ENABLE_INSPECTOR] = createWorkshopSetting(
        bool, "Game settings", "Enable inspector (increases server load)", false, 3)
    workshop_settings[WorkshopSettings.RANDOMIZE_OUTLINE_COLOR] = createWorkshopSetting(
        bool, "Game settings", "Randomize hero outline color", true, 4)
    workshop_settings[WorkshopSettings.RANDOMIZE_BASE_COLOR] = createWorkshopSetting(
        bool, "Game settings", "Randomize base color", true, 5)
    workshop_settings[WorkshopSettings.RANDOMIZE_CHILL_COLOR] = createWorkshopSetting(
        bool, "Game settings", "Randomize chill mode effect color", true, 6)
    
    workshop_settings[WorkshopSettings.MATCH_TIME] = createWorkshopSetting(
        int[30:270], "Match settings", "Match time", 270, 0) * 60
    workshop_settings[WorkshopSettings.ENABLE_SCOREBOARD] = createWorkshopSetting(
        bool, "Match settings", "Enable scoreboard", true, 2)
    workshop_settings[WorkshopSettings.ENABLE_POTG] = createWorkshopSetting(
        bool, "Match settings", "Enable play of the game", false, 3)


rule "— Debug HUD":
    @Disabled
    @Event eachPlayer