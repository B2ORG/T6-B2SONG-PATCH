#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_stats;
#include common_scripts\utility;
#include maps\mp\zm_transit;
#include maps\mp\zm_nuked_amb;
#include maps\mp\zm_highrise_amb;
#include maps\mp\zm_alcatraz_amb;
#include maps\mp\zm_alcatraz_sq_nixie;
#include maps\mp\zm_buried_amb;
#include maps\mp\zm_tomb_amb;
#include maps\mp\zm_tomb_ee_side;

init()
{
    level.SONG_TIMING = array();
    level.SONG_TIMING["version"] = 7;
    level.SONG_TIMING["debug"] = true;
    set_dvars();

    level thread song_main();
    level thread song_player();
}

song_main()
{
	level waittill("initial_players_connected");
    iPrintLn("Song Auto-Timer ^3V" + song_config("version"));

    flag_wait("initial_blackscreen_passed");
    flag_set("game_started");

    level thread timer_main();
    level thread generate_song_split(level.ACCESS_LEVEL);
    level thread song_watcher();
    level thread attempts_main();
    level thread gspeed_tracker();
    level thread point_drops();

    level thread first_box_protector();
    level thread condition_tracker();
    level thread display_blocker();
}

song_player()
{
    while (true)
    {
	    level waittill("connected", player );
        player thread player_thread();
    }
}

player_thread()
{
    self waittill("spawned_player");

    if (is_debug())
        self.score = 666666;

    player thread award_perma_perks();
    player thread speed_tracker();
    player thread zone_hud();
}

print(arg)
{}

debug_print(text)
{
    if (is_debug())
        print("DEBUG: " + text);
}

is_debug()
{
    if (song_config("debug"))
        return true;
    return false;
}

song_config(key)
{
    if (isDefined(level.SONG_TIMING[key]))
        return level.SONG_TIMING[key];
    return false;
}

set_dvars()
{
    flag_init("game_started");

    setdvar("player_strafespeedscale", 1);
    setdvar("player_backspeedscale", 0.9);
    setdvar("g_speed", 190);
}

GetAccessColor()
{
    // if (isdefined(level.ACCESS_LEVEL))
    // {
    //     if (level.ACCESS_LEVEL == 0)
    //         return "^2";   // Green
    //     else if (level.ACCESS_LEVEL == 1)
    //         return "^3";   // Yellow
    //     else if (level.ACCESS_LEVEL == 2)
    //         return "^1";   // Red
    // }
    // else
    //     return "";         // White
    return "^2";
}

set_split_color()
{
    // if (isdefined(level.ACCESS_LEVEL))
    // {
    //     if (level.ACCESS_LEVEL == 0)
    //         return (0.6, 0.8, 1);   // Blue
    //     else if (level.ACCESS_LEVEL == 1)
    //         return (0.6, 0.2, 1);   // Purple
    //     else if (level.ACCESS_LEVEL == 2)
    //         return (1, 0.6, 0.6);   // Red
    // }
    // else
    //     return (1, 1, 1);           // White
    return (0.6, 0.8, 1);   // Blue
}

timer_main()
{
    self endon("disconnect");
    level endon("end_game");

    level.songsr_start = int(gettime());

    timer_hud = createserverfontstring("hudsmall" , 1.6);
	timer_hud setPoint("TOPRIGHT", "TOPRIGHT", 0, 0);
	timer_hud.alpha = 1;
	timer_hud.color = (1, 0.8, 1);
	timer_hud.hidewheninmenu = 1;

	timer_hud setTimerUp(0);
}

generate_song_split(access_level)
{
    level.playing_songs = 0;
    songs = get_map_songs();

    foreach(song in songs)
    {
        level thread song_split(song.title, song.trigger);

        // if (access_level >= 1)
            level thread song_track(song.item, song.id);
    }
}

song_split(title, trigger)
{
    self endon("disconnect");
    level endon("end_game");

    // y_offset = 125 + (25 * songs);

    split_hud = createserverfontstring("hudsmall" , 1.3);
	split_hud setPoint("TOPRIGHT", "TOPRIGHT", 0, 150);					
	split_hud.alpha = 0;
	split_hud.color = set_split_color();
	split_hud.hidewheninmenu = 1;

    level waittill (trigger);
    sr_timestamp = get_time_detailed(level.songsr_start);
    level.playing_songs += 1;
    y_offset = 125 + (25 * level.playing_songs);
	split_hud setPoint("TOPRIGHT", "TOPRIGHT", 0, y_offset);					
    split_hud setText("" + title + ": " + sr_timestamp);
	split_hud.alpha = 1;
}

get_map_songs(map)
{
    if (!isdefined(map))
        map = level.script;

    song = array();

    spec_title = get_specific(map, "title");
    spec_trigger = get_specific(map, "trigger");
    spec_items = get_specific(map, "item");

    if (spec_title.size != spec_trigger.size)
        return;

    for (i = 0; i < spec_title.size; i++)
    {
        songs = spawnStruct();
        songs.title = spec_title[i];
        songs.trigger = spec_trigger[i];
        songs.item = spec_items[i];
        songs.id = i;
        song[song.size] = songs;
    }

    return song;
}

get_specific(map, type)
{
    if (map == "zm_transit")
    {
        if (type == "title")
            return array("Carrion");
        else if (type == "trigger")
            return array("meteor_activated");
        else if (type == "item")
            return array("Teddy Bears");
    }
    else if (map == "zm_nuked")
    {
        if (type == "title")
            return array("Samantha's Lullaby", "Coming Home", "Re-Damned");
        else if (type == "trigger")
            return array("meteor_activated", "cominghome_activated", "re_damned_activated");
        else if (type == "item")
            return array("Teddy Bears", "Mannequinns", "Population");
    }
    else if (map == "zm_highrise")
    {
        if (type == "title")
            return array("We All Fall Down");
        else if (type == "trigger")
            return array("meteor_activated");
        else if (type == "item")
            return array("Teddy Bears"); 
    }
    else if (map == "zm_prison")
    {
        if (type == "title")
            return array("Rusty Cage", "Where Are We Going");
        else if (type == "trigger")
            return array("meteor_activated", "wherearewegoing_activated");
        else if (type == "item")
            return array("Bottles", "Numbers");
    }
    else if (map == "zm_buried")
    {
        if (type == "title")
            return array("Always Running");
        else if (type == "trigger")
            return array("meteor_activated");
        else if (type == "item")
            return array("Teddy Bears"); 
    }
    else if (map == "zm_tomb")
    {
        if (type == "title")
            return array("Archangel", "Aether", "Shepherd of Fire");
        else if (type == "trigger")
            return array("archengel_activated", "aether_activated", "shepards_activated");
        else if (type == "item")
            return array("meteors", "Plates", "Radios");
    }
    return array();
}

get_time_detailed(start_time)
{
    current_time = int(gettime());
    
    miliseconds = (current_time - start_time) + 50; // +50 for rounding
    minutes = 0;
    seconds = 0;

	if( miliseconds > 995 )
	{
		seconds = int( miliseconds / 1000 );

		miliseconds = int( miliseconds * 1000 ) % ( 1000 * 1000 );
		miliseconds = miliseconds * 0.001; 

        // iPrintLn("miliseconds: " + miliseconds);
        // iPrintLn("seconds: " + seconds);

		if( seconds > 59 )
		{
			minutes = int( seconds / 60 );
			seconds = int( seconds * 1000 ) % ( 60 * 1000 );
			seconds = seconds * 0.001; 	

            // iPrintLn("minutes: " + minutes);
		}
	}

    minutes = Int(minutes);
    if (minutes == 0)
        minutes = "00";
	else if(minutes < 10)
		minutes = "0" + minutes; 

	seconds = Int(seconds); 
    if (seconds == 0)
        seconds = "00";
	else if(seconds < 10)
		seconds = "0" + seconds; 

	miliseconds = Int(miliseconds); 
	if( miliseconds == 0 )
		miliseconds = "000";
	else if( miliseconds < 100 )
		miliseconds = "0" + miliseconds;

	return "" + minutes + ":" + seconds + "." + getsubstr(miliseconds, 0, 1); 
}

song_watcher()
{
    switch (level.script)
    {
        case "zm_transit":
        case "zm_highrise":
        case "zm_buried":
            level thread meteor();
            break;
        case "zm_nuked":
            level thread nuketown_watcher();
            break;
        case "zm_prison":
            level thread meteor();
            level thread rusty_cage();
            break;
        case "zm_tomb":
            level thread origins_watcher();
            break;
    }
}

meteor()
{
    while (true)
    {
        if (level.meteor_counter == 3)
        {
            // iPrintLn("meteor_activated");
            level notify ("meteor_activated");
            break;
        }
        wait 0.05;
    }
}

nuketown_watcher()
{
    level thread re_damned();
    level thread meteor();

    while (true)
    {
        if (level.mannequin_count <= 0)
        {
            // iPrintLn("cominghome_activated");
            level notify ("cominghome_activated");
            break;
        }
        wait 0.05;
    }
}

re_damned()
{
    level waittill("magic_door_power_up_grabbed");
    if (level.population_count == 15)
    {
        // iPrintLn("re_damned_activated");
        level notify ("re_damned_activated");
    }
}

rusty_cage()
{
    level waittill ("nixie_" + 935);
    // iPrintLn("johnycash_activated");
    level notify ("wherearewegoing_activated");
}

origins_watcher()
{
    archengel_checked = false;
    aether_checked = false;
    shepards_checked = false;
    while (true)
    {
        if (level.meteor_counter == 3 && !archengel_checked)
        {
            // iPrintLn("archengel_activated");
            level notify ("archengel_activated");
            archengel_checked = true;
        }
        else if (level.snd115count == 3 && !aether_checked)
        {
            // iPrintLn("aether_activated");
            level notify ("aether_activated");
            aether_checked = true;
        }
        else if (level.found_ee_radio_count == 3 && !shepards_checked)
        {
            // iPrintLn("shepards_activated");
            level notify ("shepards_activated");
            shepards_checked = true;
        }

        wait 0.05;
    }
}

zone_hud()
{
    self endon("disconnect");
    level endon("end_game");

    player_thread_black_screen_waiter();

    zone_hud = newClientHudElem(self);
	zone_hud.alignx = "left";
	zone_hud.aligny = "bottom";
	zone_hud.horzalign = "user_left";
	zone_hud.vertalign = "user_bottom";
	zone_hud.x = 8;
	zone_hud.y = -111;
    zone_hud.fontscale = 1.1;
	zone_hud.alpha = 0.4;
	zone_hud.color = (1, 1, 1);
	zone_hud.hidewheninmenu = 1;

    prev_zone = "";
    while (true)
    {
        zone = self get_current_zone();

        if(prev_zone != zone)
        {
            prev_zone = zone;

            zone_hud fadeovertime(0.2);
            zone_hud.alpha = 0;
            wait 0.2;

            zone_hud settext(zone);

            zone_hud fadeovertime(0.2);
            zone_hud.alpha = 0.4;
            wait 1;

            zone_hud fadeovertime(0.2);
            zone_hud.alpha = 0;
            wait 0.2;
        }
        wait 0.05;
    }
}

display_blocker()
{
    self endon("disconnect");
    level endon("end_game");

    hud_blocker = createserverfontstring("hudsmall" , 1.4);
	hud_blocker setPoint("TOPRIGHT", "TOPRIGHT", 0, 40);
	hud_blocker.alpha = 1;
	hud_blocker.color = (1, 0.6, 0.2);
	hud_blocker.hidewheninmenu = 1;
    hud_blocker.label = &"Music override: ";

    while (true)
    {
        hud_blocker setValue(level.music_override);
        wait 0.05;
    }
}

point_drops()
{
    self endon("disconnect");
    level endon("end_game");

    hud_points = createserverfontstring("hudsmall" , 1.4);
    hud_points setPoint("TOPRIGHT", "TOPRIGHT", 0, 60);
    hud_points.alpha = 1;
    hud_points.color = (1, 0.6, 0.2);
    hud_points.hidewheninmenu = 1;
    hud_points.label = &"Pointdrop coming: ";

    while (true)
    {
        hud_points setValue(level.zombie_vars["zombie_drop_item"]);
        wait 0.05;
    }
}

attempts_main()
{
    attempt_hud = createserverfontstring("hudsmall" , 1.5);
    attempt_hud setPoint("TOPRIGHT", "TOPRIGHT", 0, 20);
    attempt_hud.alpha = 1;
    attempt_hud.color = (1, 0.8, 1);
    attempt_hud.hidewheninmenu = 1;
    attempt_hud.label = &"Attempts: ";

    if (level.script != getDvar("song_attempt_map"))
    {
        setDvar("song_attempts", 0);
        setDvar("song_attempt_map", level.script);
    }

    attempt_hud setValue(getDvarInt("song_attempts"));
    setDvar("song_attempts", getDvarInt("song_attempts") + 1);
}

condition_tracker()
{
    self endon("disconnect");
    level endon("end_game");

    while (true)
    {
        level.current_count = array();

        while (level.script == "zm_transit" || level.script == "zm_highrise" || level.script == "zm_buried")
        {
            level.current_count[0] = level.meteor_counter;
            level.current_count[1] = 0;
            level.current_count[2] = 0;
            wait 0.05;
        }

        while (level.script == "zm_prison")
        {
            level.current_count[0] = level.meteor_counter;
            level.current_count[1] = get_current_nixie();
            level.current_count[2] = 0;
            wait 0.05;
        }

        while (level.script == "zm_nuked")
        {
            level.current_count[0] = level.meteor_counter;
            level.current_count[1] = level.mannequin_count;
            level.current_count[2] = level.population_count;
            wait 0.05;
        }

        while (level.script == "zm_tomb")
        {
            level.current_count[0] = level.meteor_counter;
            level.current_count[1] = level.snd115count;
            level.current_count[2] = level.found_ee_radio_count;
            wait 0.05;
        }

        wait 0.05;
    }
}

song_track(label, id)
{
    self endon("disconnect");
    level endon("end_game");
    
    tracking_hud = createserverfontstring("hudsmall" , 1.3);
	tracking_hud setPoint("TOPLEFT", "TOPLEFT", 0, id * 20);					
	tracking_hud.color = (1, 0.8, 1);
	tracking_hud.hidewheninmenu = 1;
	tracking_hud.alpha = 0;

    while (true)
    {
        if (isDefined(level.current_count[id]))
            val = level.current_count[id];
        else
            val = 0;

        tracking_hud setText(label + ": " + val);

        if (tracking_hud.alpha == 0)
            tracking_hud.alpha = 1;

        while (isDefined(level.current_count[id]) && val == level.current_count[id])
            wait 0.05;

        wait 0.05;
    }
}

get_current_nixie()
{
    if (!isdefined(level.a_nixie_tube_code) || !isdefined(level.a_nixie_tube_code[3]))
        return "000";
    
    return "" + level.a_nixie_tube_code[1] + level.a_nixie_tube_code[2] + level.a_nixie_tube_code[3];
}

award_perma_perks()
{
    if (level.script != "zm_transit" && level.script != "zm_highrise" && level.script != "zm_buried")
        return;

    if (level.round_number > 1)
        return;

    // Full bank
    self.account_value = level.bank_account_max;
    self set_map_stat("depositBox", self.account_value, level.banking_map);

    // Perma perks stats
    for (i = 0; i < level.pers_upgrades_keys.size; i++)
    {
        name = level.pers_upgrades_keys[i];

        for (j = 0; j < level.pers_upgrades[name].stat_names.size; j++)
        {
            stat_name = level.pers_upgrades[name].stat_names[j];
            self set_global_stat(stat_name, level.pers_upgrades[name].stat_desired_values[j]);
            self.stats_this_frame[stat_name] = 1;
        }
    }
    return;
}

speed_tracker()
{
    self endon("disconnect");
    level endon("end_game");

    player_thread_black_screen_waiter();

    self.hud_velocity = createfontstring("hudsmall" , 1.4);
	self.hud_velocity setPoint("TOPRIGHT", "TOPRIGHT", 0, 90);
	self.hud_velocity.alpha = 1;
	self.hud_velocity.color = (0.4, 1, 0.7);
	self.hud_velocity.hidewheninmenu = 1;
    self.hud_velocity.label = &"Velocity: ";


    while (true)
    {
        self.hud_velocity setValue(int(length(self getvelocity() * (1, 1, 0))));
        wait 0.05;
    }
}

gspeed_tracker()
{
    hud_gspeed = createserverfontstring("hudsmall" , 1.4);
	hud_gspeed setPoint("TOPRIGHT", "TOPRIGHT", 0, 110);
	hud_gspeed.alpha = 1;
	hud_gspeed.color = (0.4, 1, 0.7);
	hud_gspeed.hidewheninmenu = 1;
    hud_gspeed.label = &"Gspeed: ";

    while (true)
    {
        current_gspeed = getDvarInt("g_speed");
        if (current_gspeed != 190)
            hud_gspeed.color = (1, 0, 0);
        hud_gspeed setValue(current_gspeed);
        wait 0.05;
    }
}

player_thread_black_screen_waiter()
{
    while (!flag("game_started"))
        wait 0.05;
    return;
}

first_box_protector()
// Yes i know there is ways to bypass that lol
{
    self endon("disconnect");
    level endon("end_game");

    level.is_first_box = false;

    self thread first_box_info();

    if (isDefined(level.SONG_1STBOX_ACTIVE) && level.SONG_1STBOX_ACTIVE)
        level.is_first_box = true;
    else
    {
        self thread scan_in_box();
        self thread compare_keys();
    }

    level waittill("end_game");
}

first_box_info()
{
    self endon("disconnect");
    level endon("end_game");

    if (level.script == "zm_nuked" || level.script == "zm_buried")
    {
        while (true)
        {
            if (isDefined(level.is_first_box) && level.is_first_box)
            {
                iPrintLn("^1First Box Detected");
                break;
            }
            wait 0.25;
        }

        hud_1box = createserverfontstring("hudsmall" , 1.8);
        hud_1box setPoint("CENTER", "TOP", 0, 25);
        hud_1box.alpha = 0.12;
        hud_1box.color = (0.9, 0, 0);
        hud_1box.hidewheninmenu = 1;
        hud_1box setText("FIRST BOX");
    }

    level waittill("end_game");
}

scan_in_box()
{
    self endon("disconnect");
    level endon("end_game");

    if (level.script == "zm_nuked")
        should_be_in_box = 26;
    else if (level.script == "zm_buried")
        should_be_in_box = 22;

    while (isDefined(should_be_in_box))
    {
        in_box = 0;
        wpn_keys = getarraykeys(level.zombie_weapons);

        for (i=0; i<wpn_keys.size; i++)
        {
            if (maps\mp\zombies\_zm_weapons::get_is_in_box(wpn_keys[i]))
                in_box++;
        }

        // print("in_box: " + in_box + " should: " + should_be_in_box);

        if (in_box != should_be_in_box)
        {
            // iPrintLn("1stbox_box");
            level.is_first_box = true;
            break;
        }

        wait_network_frame();
    }
    return;
}

compare_keys()
{
    self endon("disconnect");
    level endon("end_game");

    an_array = array();
    dupes = 0;

    wait(randomIntRange(2, 22));

    for (i=0; i<10; i++)
    {
        rando = maps\mp\zombies\_zm_magicbox::treasure_chest_chooseweightedrandomweapon(level.players[0]);
        if (isinarray(an_array, rando))
            dupes += 1;
        else
            an_array[an_array.size] = rando;
        
        wait_network_frame();
    }

    if (dupes > 3)
    {
        // iPrintLn("1stbox_keys");
        level.is_first_box = true;
    }

    return;
}
