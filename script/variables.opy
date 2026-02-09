#!mainFile "../main.opy"

# GLOBAL VARIABLES
globalvar workshop_settings = []
# player lists
globalvar god_usernames = []
globalvar mod_usernames = []
globalvar ban_usernames = []
globalvar comms_ban_usernames = []
globalvar god_mod_list = []
# backup lists
globalvar player_names_backups = []
globalvar base_vectors_backups = []
globalvar settings_backups = []
# data
globalvar extended_color_data = []
globalvar base_mode_icon_data = []
# settings data
globalvar settings_data = []
globalvar settings_cat_data = []
globalvar quick_settings_data = []
# default settings
globalvar default_settings = []
# HUD
globalvar mod_list_hud = ""
globalvar mod_list_hud_ctr
# chased
globalvar rainbow_hue = 0
# miscellaneous
globalvar orb_radius = 0.4
globalvar isInitialized
globalvar isOverloaded

# PLAYER VARIABLES
# HUD
playervar progress_hud
playervar in_world_hud
playervar settings_hud
playervar onscreen_hud
# moderator
playervar name_to_ban
# base
playervar base_vector
playervar has_created_base_once
playervar activate_base_now
playervar base_settings_changed
playervar last_known_base_owner
playervar last_known_base_mode
# base owners
playervar current_base_owner
playervar active_base_owner
playervar base_to_fast_travel_owner
# settings
playervar cat_i
playervar settings_i
playervar settings = []
playervar setting_adjustment
playervar pending_settings = []
playervar isInCatMode = true
playervar isInQuickSettings = true
playervar uiState
# status
playervar isInModStasis
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
playervar menu_scale
playervar last_pos
playervar last_transform
playervar keyboard_input_char
playervar last_facing_dir
playervar last_hero