#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/zombies/_zm_stats;
#include common_scripts/utility;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_magicbox;

init()
{
    level thread FirstBoxOnConnect();
    level.SONG_1STBOX_ACTIVE = true;
}

FirstBoxOnConnect()
{
	level waittill("initial_players_connected");

    map = level.script;

    if ((isdefined(level.SONG_AUTO_TIMER_ACTIVE) && level.SONG_AUTO_TIMER_ACTIVE) && (map == "zm_nuked" || map == "zm_buried"))
    {
        level thread FirstBox(map);
        level thread YellowHouseBox(map);
    }
}

FirstBox(map)
{
    level endon("end_game");
    self endon("disconnect");

    flag_wait("initial_blackscreen_passed");

    desired_weapon = "";
    if (map == "zm_nuked")
    {
        level.special_weapon_magicbox_check = undefined;
        desired_weapon = "raygun_mark2_zm";
    }
    else if (map == "zm_buried")
        desired_weapon = "slowgun_zm";

    swapped_weapons = array();
    foreach(weapon in getarraykeys(level.zombie_weapons))
    {
        if ((weapon != desired_weapon) && (level.zombie_weapons[weapon].is_in_box == 1))
        {
            level.zombie_weapons[weapon].is_in_box = 0;
            // print("" + weapon + ".is_in_box = " + level.zombie_weapons[weapon].is_in_box);
            swapped_weapons[swapped_weapons.size] = weapon;
        }
        else if (weapon == desired_weapon)
        {
            level.zombie_weapons[weapon].is_in_box = 1;
            // print("" + weapon + ".is_in_box = " + level.zombie_weapons[weapon].is_in_box);
        }
    }

    flag_wait("chest_has_been_used");
    wait 7;

    // Buried check hasn't been reset earlier
    if (!isDefined(level.special_weapon_magicbox_check))
        level.special_weapon_magicbox_check = ::CopiedMagicboxCheck;

    foreach(restore in swapped_weapons)
    {
        // print("enabling: " + restore);
        level.zombie_weapons[restore].is_in_box = 1;
    }

    return;
}

YellowHouseBox(map)
{
    level endon("end_game");
    self endon("disconnect");

    if (map != "zm_nuked")
        return;

    flag_wait("start_zombie_round_logic");
    wait 4;

    yellowhouse_id = undefined;
    greenhouse_id = undefined;

    for(i = 0; i < level.chests.size; i++)
    {
        if (level.chests[i].script_noteworthy == "start_chest2")
        {
            level.chests[i] show_chest();
            level.chest_index = i;
        }
        else if (level.chests[i].hidden == 0)
            level.chests[yellowhouse_id] hide_chest();
    }

    return;
}

CopiedMagicboxCheck(weapon)
{
    if ( isdefined( level.raygun2_included ) && level.raygun2_included )
    {
        if ( weapon == "ray_gun_zm" )
        {
            if ( self has_weapon_or_upgrade( "raygun_mark2_zm" ) )
                return false;
        }

        if ( weapon == "raygun_mark2_zm" )
        {
            if ( self has_weapon_or_upgrade( "ray_gun_zm" ) )
                return false;

            if ( randomint( 100 ) >= 33 )
                return false;
        }
    }

    return true;
}
