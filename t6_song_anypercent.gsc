#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;

init()
{
    level.song_anypercent = spawn_anypercent_category();
}

spawn_anypercent_category()
{
    cat = spawnStruct();
    cat.enabled = true;
    cat.disable_oob_safety = ::kill_player_out_of_playable_area_monitor;
    cat.powerup_rig = ::rig_powerups_on_start;
    return cat;
}

kill_player_out_of_playable_area_monitor()
{
	level endon("end_game");
	self endon("disconnect");

	flag_wait("initial_blackscreen_passed");
    wait 0.1;
	self notify("stop_player_out_of_playable_area_monitor");
}

rig_powerups_on_start()
{
    level endon("end_game");

    preserved_powerup_array = level.zombie_powerup_array;
    shit_powerups = get_shit_powerups(preserved_powerup_array);

    /* Guaranteed double points from 1st zombie */
	level.zombie_vars["zombie_drop_item"] = 1;
    rig_powerup("double_points");
    level waittill("powerup_dropped");
    wait 0.05;
    /* Guaranteed nuke from next 2% / point drop */
    rig_powerup("nuke");
    level waittill("powerup_dropped");
    wait 0.05;
    /* Getting through remaining powerups */
    level.zombie_powerup_array = shit_powerups;
    for (i = 0; i < shit_powerups.size; i++)
        level waittill("powerup_dropped");
    /* Restoring usual powerup array */
    level.zombie_powerup_array = preserved_powerup_array;
}

rig_powerup(powerup)
{
    level.zombie_powerup_array = array(powerup);
}

get_shit_powerups(powerup_array)
{
    new = array();
    foreach (drop in powerup_array)
    {
        if (!am_i_cool_powerup(drop))
            new[new.size] = drop;
    }
    return new;
}

am_i_cool_powerup(powerup)
{
    switch (powerup)
    {
        case "double_points":
        case "nuke":
            return true;
        default:
            return false;
    }
}