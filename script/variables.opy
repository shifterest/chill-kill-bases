#!mainFile "../main.opy"

# GLOBAL VARIABLES
# player lists
globalvar god_usernames
globalvar mod_usernames
globalvar ban_usernames
globalvar comms_ban_usernames
globalvar god_mod_list
# backup lists
globalvar player_names_backups
globalvar base_vectors_backups
globalvar preferences_backups
# data
globalvar extended_color_data
globalvar keys_data
globalvar base_mode_icon_data
# preferences data
globalvar preferences_data
globalvar preferences_category_data
globalvar quick_preferences_data
# default preferences
globalvar preferences_default
# HUD
globalvar moderator_list_hud
globalvar moderator_list_hud_counter
# chased
globalvar rainbow_red
globalvar rainbow_green
globalvar rainbow_blue
# miscellaneous
globalvar orb_radius
globalvar mode
globalvar optimize
globalvar isInitialized
globalvar isOverloaded

# PLAYER VARIABLES
# HUD
playervar progress_hud
playervar in_world_hud
playervar preferences_hud
playervar onscreen_hud
# moderator
playervar name_to_ban
# base
playervar base_vector
playervar has_created_base_once
playervar activate_base_immediately
playervar base_preferences_changed
playervar last_known_base_owner
playervar last_known_base_mode
playervar previous_base_size
playervar previous_base_gap_size
# base owners
playervar current_base_owner
playervar active_base_owner
playervar base_to_fast_travel_owner
# preferences
playervar preferences_index
playervar preferences
playervar preference_adjustment
playervar isViewingAdvancedPreferences
playervar isViewingPreferences
# mode
playervar isInModeratorMode
playervar isInBaseCreationMode
playervar isUsingKeyboard
# status
playervar isInModeratorStasis
playervar isInStasis
playervar isInvisible
# chased
playervar death_throttle
playervar progress
playervar base_progress
playervar interaction_progress
playervar afk_timer
# riding
playervar mount
playervar rider
# IDs
playervar chill_effect_id
playervar base_effect_id
playervar icon_effect_id
playervar description_effect_id
playervar message_effect_id
# miscellaneous
playervar focused_player
playervar previous_position
playervar previous_position_direction
playervar keyboard_input_character
playervar previous_facing_direction
playervar last_hero