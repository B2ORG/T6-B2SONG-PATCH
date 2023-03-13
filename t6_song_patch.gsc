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
    level.SONG_TIMING["hud_right_pos"] = 30;
    set_dvars();

    level thread song_main();
    level thread song_player();
}

song_main()
{
	level waittill("initial_players_connected");
    iPrintLn("Song Auto-Timer ^3V" + song_config("version"));

    // Add custom player colors with this
    level.SONG_EXTRA_HUD_COLORS = undefined;

    flag_wait("initial_blackscreen_passed");
    flag_set("game_started");

    song_hud();
    level thread gspeed_watcher();

    /*
    level thread generate_song_split(level.ACCESS_LEVEL);
    level thread song_watcher();
    level thread attempts_main();
    level thread point_drops();

    level thread first_box_protector();
    level thread condition_tracker();
    level thread display_blocker();
    */
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

    // self thread award_perma_perks();
    self thread velocity_meter();
    self thread zone_hud();
}

song_hud()
{
    level thread game_timer();
    level thread round_timer();
    level thread attempts_hud();

    level thread generate_sign(-66, "POINT DROP", ::eval_point_drop);
    level thread generate_sign(66, "MUSIC LOCK", ::eval_music_override);
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

player_thread_black_screen_waiter()
{
    while (!flag("game_started"))
        wait 0.05;
    return;
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

allert(content, value)
{
    if (!isDefined(level.allerts))
        level.allerts = 0;

    switch (content)
    {
        case "gspeed":
            message = "MODIFIED GSPEED";
            break;
        default:
            message = "";
    }

    allert = createserverfontstring("default" , 1.4);
    allert setPoint("CENTER", "TOP", "CENTER", 40 + 12 * level.allerts);
    allert.alpha = 1;
    allert.color = (0.75, 0.35, 0);

    allert_text = message;
    if (isDefined(value))
        allert_text = "" + allert_text + ": " + value;

    allert setText(allert_text);
}

generate_sign(x_pos, text, toggle_on_func, toggle_off_func)
{
    sign = createserverfontstring("objective" , 1.6);
    sign setPoint("TOP", "TOP", x_pos, -30);
    sign.hidewheninmenu = 1;
    sign setText(text);
    sign sign_light_off();

    toggle = false;
    while (true)
    {
        if ([[toggle_on_func]]() && !toggle)
        {
            sign sign_light_on();
            toggle = true;
        }
        else if ((!isDefined(toggle_off_func) && ![[toggle_on_func]]() && toggle) || (isDefined(toggle_off_func) && [[toggle_off_func]]() && toggle))
        {
            sign sign_light_off();
            toggle = false;
        }

        wait 0.05;
    }
}

sign_light_on()
{
    self.color = (0.6, 0.2, 1);
    self.glowcolor = (0.9, 0.5, 1);
    self.alpha = 1;
}

sign_light_off()
{
    self.color = (0.8, 0.6, 1);
    self.glowcolor = (1, 0.8, 1);
    self.alpha = 0.1;
}

hud_color_watcher(hud)
{
    // Prevent having to select color every restart
    if (getDvar("hud_color_state") != "")
    {
        color = eval_color(getDvar("hud_color_state"));
        if (isDefined(color))
            hud.color = color;
    }

    while (true)
    {
        level waittill("say", message, player);

        // Player threaded hud changes for each player separately
        if (self is_player() && self != player)
            continue;

        if (isSubStr(message, "hud"))
        {
            color_str = strTok(message, " ")[1];
            color = eval_color(color_str);
        }

        if (!isDefined(color))
            continue;

        setDvar("hud_color_state", color_str);
        hud.color = color;
    }
}

eval_color(message)
{
    if (!isDefined(message))
        return;

    switch (message)
    {
        case "red":
            return (1, 0, 0);
        case "green":
            return (0, 1, 0);
        case "blue":
            return (0, 0, 1);
        case "orange":
            return (1, 0.5, 0);
        case "yellow":
            return (1, 1, 0);
        case "light green":
            return (0.5, 1, 0);
        case "mint":
            return (0, 1, 0.5);
        case "cyan":
            return (0, 1, 1);
        case "light blue":
            return (0, 0.5, 1);
        case "purple":
            return (0.5, 0, 1);
        case "light pink":
            return (1, 0, 1);
        case "pink":
            return (1, 0, 0.5);
        case "white":
            return (1, 1, 1);
        default:
            if (isDefined(level.SONG_EXTRA_HUD_COLORS))
                return [[level.SONG_EXTRA_HUD_COLORS]](message);
            return;
    }
}

game_timer()
{
    self endon("disconnect");
    level endon("end_game");

    level.songsr_start = int(gettime());

    timer_hud = createserverfontstring("big" , 1.6);
	timer_hud setPoint("TOPRIGHT", "TOPRIGHT", song_config("hud_right_pos"), 0);
	timer_hud.alpha = 1;
	timer_hud.color = (1, 1, 1);

	timer_hud setTimerUp(0);
    thread hud_color_watcher(timer_hud);
}

round_timer()
{
    level endon("end_game");

	round_hud = createserverfontstring("big" , 1.6);
	round_hud setPoint("TOPRIGHT", "TOPRIGHT", song_config("hud_right_pos"), 16);
	round_hud.color = (1, 1, 1);
	round_hud.alpha = 0;

    thread hud_color_watcher(round_hud);

	while (true)
	{
		level waittill("start_of_round");

		round_start = int(getTime() / 1000);
        // round_hud setTimerUp(0);
        // round_hud FadeOverTime(0.25);
        // round_hud.alpha = 1;

		level waittill("end_of_round");

		round_end = int(getTime() / 1000) - round_start;
		round_start = undefined;

		if (!round_hud.alpha)
		{
			round_hud FadeOverTime(0.25);
			round_hud.alpha = 1;
		}

		for (ticks = 0; ticks < 20; ticks++)
		{
			round_hud setTimer(round_end - 0.1);
			wait 0.25;
		}

		round_hud FadeOverTime(0.25);
		round_hud.alpha = 0;
	}
}

attempts_hud()
{
    attempt_hud = createserverfontstring("objective" , 1.3);
    attempt_hud setPoint("TOPRIGHT", "TOPRIGHT", song_config("hud_right_pos"), 40);
    attempt_hud.alpha = 1;
    attempt_hud.color = (1, 1, 1);
    attempt_hud.label = &"ATTEMPTS: ^6";

    if (level.script != getDvar("song_attempt_map"))
    {
        setDvar("song_attempts", 0);
        setDvar("song_attempt_map", level.script);
    }

    attempt_hud setValue(getDvarInt("song_attempts"));
    setDvar("song_attempts", getDvarInt("song_attempts") + 1);
}

zone_hud()
{
    self endon("disconnect");
    level endon("end_game");

    player_thread_black_screen_waiter();

    self.zone_hud = createfontstring("objective" , 1.2);
	self.zone_hud setPoint("CENTER", "BOTTOM", "CENTER", 25);
	self.zone_hud.alpha = 0.8;
	self.zone_hud.color = (1, 1, 1);
	self.zone_hud.hidewheninmenu = 1;
    self.zone_hud settext("");

    self thread hud_color_watcher(self.zone_hud);

    while (true)
    {
        self.zone_hud settext(translate_zone(self get_current_zone()));
        wait 0.05;
    }
}

velocity_meter()
{
    self endon("disconnect");
    level endon("end_game");

    player_thread_black_screen_waiter();

    self.hud_velocity = createfontstring("big" , 1.2);
	self.hud_velocity setPoint("CENTER", "CENTER", "CENTER", 200);
	self.hud_velocity.alpha = 0.75;
	self.hud_velocity.color = (1, 1, 1);
	self.hud_velocity.hidewheninmenu = 1;

    while (true)
    {
		velocity = int(length(self getvelocity() * (1, 1, 0)));
        velocity_meter_scale(velocity, self.hud_velocity);
        self.hud_velocity setValue(velocity);

        wait 0.05;
    }
}

velocity_meter_scale(vel, hud)
{
	hud.color = ( 0.6, 0, 0 );
	hud.glowcolor = ( 0.3, 0, 0 );

	if ( vel < 330 )
	{
		hud.color = ( 0.6, 1, 0.6 );
		hud.glowcolor = ( 0.4, 0.7, 0.4 );
	}

	else if ( vel <= 340 )
	{
		hud.color = ( 0.8, 1, 0.6 );
		hud.glowcolor = ( 0.6, 0.7, 0.4 );
	}

	else if ( vel <= 350 )
	{
		hud.color = ( 1, 1, 0.6 );
		hud.glowcolor = ( 0.7, 0.7, 0.4 );
	}

	else if ( vel <= 360 )
	{
		hud.color = ( 1, 0.8, 0.4 );
		hud.glowcolor = ( 0.7, 0.6, 0.2 );
	}

	else if ( vel <= 370 )
	{
		hud.color = ( 1, 0.6, 0.2 );
		hud.glowcolor = ( 0.7, 0.4, 0.1 );
	}

	else if ( vel <= 380 )
	{
		hud.color = ( 1, 0.2, 0 );
		hud.glowcolor = ( 0.7, 0.1, 0 );
	}
}

eval_point_drop()
{
    if (isDefined(level.zombie_vars["zombie_drop_item"]) && level.zombie_vars["zombie_drop_item"])
        return true;
    return false;
}

eval_music_override()
{
    if (isDefined(level.music_override) && level.music_override)
        return true;
    return false;
}

gspeed_watcher()
{
    while (true)
    {
        if (getDvarInt("g_speed") != 190)
        {
            allert("gspeed", getDvar("g_speed"));
            break;
        }
        wait 0.05;
    }
}

/*

generate_song_split(access_level)
{
    level.playing_songs = 0;
    songs = get_map_songs();

    foreach(song in songs)
    {
        level thread song_split(song.title, song.trigger);

        level thread song_track(song.item, song.id);
    }
}

song_split(title, trigger)
{
    self endon("disconnect");
    level endon("end_game");

    // y_offset = 125 + (25 * songs);

    split_hud = createserverfontstring("default" , 1.3);
	split_hud setPoint("TOPRIGHT", "TOPRIGHT", 0, 150);					
	split_hud.alpha = 0;
	split_hud.color = (0.6, 0.8, 1);
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

display_blocker()
{
    self endon("disconnect");
    level endon("end_game");

    hud_blocker = createserverfontstring("default" , 1.4);
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

    hud_points = createserverfontstring("default" , 1.4);
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
    
    tracking_hud = createserverfontstring("default" , 1.3);
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

gspeed_tracker()
{
    hud_gspeed = createserverfontstring("default" , 1.4);
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

        hud_1box = createserverfontstring("default" , 1.8);
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

*/

translate_zone(zone)
{
	if (!isDefined(zone))
	{
		return "";
	}

	name = zone;

	if (level.script == "zm_transit" || level.script == "zm_transit_dr")
	{
		if (zone == "zone_pri")
		{
			name = "Bus Depot";
		}
		else if (zone == "zone_pri2")
		{
			name = "Bus Depot Hallway";
		}
		else if (zone == "zone_station_ext")
		{
			name = "Outside Bus Depot";
		}
		else if (zone == "zone_trans_2b")
		{
			name = "Fog After Bus Depot";
		}
		else if (zone == "zone_trans_2")
		{
			name = "Tunnel Entrance";
		}
		else if (zone == "zone_amb_tunnel")
		{
			name = "Tunnel";
		}
		else if (zone == "zone_trans_3")
		{
			name = "Tunnel Exit";
		}
		else if (zone == "zone_roadside_west")
		{
			name = "Outside Diner";
		}
		else if (zone == "zone_gas")
		{
			name = "Gas Station";
		}
		else if (zone == "zone_roadside_east")
		{
			name = "Outside Garage";
		}
		else if (zone == "zone_trans_diner")
		{
			name = "Fog Outside Diner";
		}
		else if (zone == "zone_trans_diner2")
		{
			name = "Fog Outside Garage";
		}
		else if (zone == "zone_gar")
		{
			name = "Garage";
		}
		else if (zone == "zone_din")
		{
			name = "Diner";
		}
		else if (zone == "zone_diner_roof")
		{
			name = "Diner Roof";
		}
		else if (zone == "zone_trans_4")
		{
			name = "Fog After Diner";
		}
		else if (zone == "zone_amb_forest")
		{
			name = "Forest";
		}
		else if (zone == "zone_trans_10")
		{
			name = "Outside Church";
		}
		else if (zone == "zone_town_church")
		{
			name = "Outside Church To Town";
		}
		else if (zone == "zone_trans_5")
		{
			name = "Fog Before Farm";
		}
		else if (zone == "zone_far")
		{
			name = "Outside Farm";
		}
		else if (zone == "zone_far_ext")
		{
			name = "Farm";
		}
		else if (zone == "zone_brn")
		{
			name = "Barn";
		}
		else if (zone == "zone_farm_house")
		{
			name = "Farmhouse";
		}
		else if (zone == "zone_trans_6")
		{
			name = "Fog After Farm";
		}
		else if (zone == "zone_amb_cornfield")
		{
			name = "Cornfield";
		}
		else if (zone == "zone_cornfield_prototype")
		{
			name = "Prototype";
		}
		else if (zone == "zone_trans_7")
		{
			name = "Upper Fog Before Power Station";
		}
		else if (zone == "zone_trans_pow_ext1")
		{
			name = "Fog Before Power Station";
		}
		else if (zone == "zone_pow")
		{
			name = "Outside Power Station";
		}
		else if (zone == "zone_prr")
		{
			name = "Power Station";
		}
		else if (zone == "zone_pcr")
		{
			name = "Power Station Control Room";
		}
		else if (zone == "zone_pow_warehouse")
		{
			name = "Warehouse";
		}
		else if (zone == "zone_trans_8")
		{
			name = "Fog After Power Station";
		}
		else if (zone == "zone_amb_power2town")
		{
			name = "Cabin";
		}
		else if (zone == "zone_trans_9")
		{
			name = "Fog Before Town";
		}
		else if (zone == "zone_town_north")
		{
			name = "North Town";
		}
		else if (zone == "zone_tow")
		{
			name = "Center Town";
		}
		else if (zone == "zone_town_east")
		{
			name = "East Town";
		}
		else if (zone == "zone_town_west")
		{
			name = "West Town";
		}
		else if (zone == "zone_town_south")
		{
			name = "South Town";
		}
		else if (zone == "zone_bar")
		{
			name = "Bar";
		}
		else if (zone == "zone_town_barber")
		{
			name = "Bookstore";
		}
		else if (zone == "zone_ban")
		{
			name = "Bank";
		}
		else if (zone == "zone_ban_vault")
		{
			name = "Bank Vault";
		}
		else if (zone == "zone_tbu")
		{
			name = "Below Bank";
		}
		else if (zone == "zone_trans_11")
		{
			name = "Fog After Town";
		}
		else if (zone == "zone_amb_bridge")
		{
			name = "Bridge";
		}
		else if (zone == "zone_trans_1")
		{
			name = "Fog Before Bus Depot";
		}
	}
	else if (level.script == "zm_nuked")
	{
		if (zone == "culdesac_yellow_zone")
		{
			name = "Yellow House Cul-de-sac";
		}
		else if (zone == "culdesac_green_zone")
		{
			name = "Green House Cul-de-sac";
		}
		else if (zone == "truck_zone")
		{
			name = "Truck";
		}
		else if (zone == "openhouse1_f1_zone")
		{
			name = "Green House Downstairs";
		}
		else if (zone == "openhouse1_f2_zone")
		{
			name = "Green House Upstairs";
		}
		else if (zone == "openhouse1_backyard_zone")
		{
			name = "Green House Backyard";
		}
		else if (zone == "openhouse2_f1_zone")
		{
			name = "Yellow House Downstairs";
		}
		else if (zone == "openhouse2_f2_zone")
		{
			name = "Yellow House Upstairs";
		}
		else if (zone == "openhouse2_backyard_zone")
		{
			name = "Yellow House Backyard";
		}
		else if (zone == "ammo_door_zone")
		{
			name = "Yellow House Backyard Door";
		}
	}
	else if (level.script == "zm_highrise")
	{
		if (zone == "zone_green_start")
		{
			name = "Green Highrise Level 3b";
		}
		else if (zone == "zone_green_escape_pod")
		{
			name = "Escape Pod";
		}
		else if (zone == "zone_green_escape_pod_ground")
		{
			name = "Escape Pod Shaft";
		}
		else if (zone == "zone_green_level1")
		{
			name = "Green Highrise Level 3a";
		}
		else if (zone == "zone_green_level2a")
		{
			name = "Green Highrise Level 2a";
		}
		else if (zone == "zone_green_level2b")
		{
			name = "Green Highrise Level 2b";
		}
		else if (zone == "zone_green_level3a")
		{
			name = "Green Highrise Restaurant";
		}
		else if (zone == "zone_green_level3b")
		{
			name = "Green Highrise Level 1a";
		}
		else if (zone == "zone_green_level3c")
		{
			name = "Green Highrise Level 1b";
		}
		else if (zone == "zone_green_level3d")
		{
			name = "Green Highrise Behind Restaurant";
		}
		else if (zone == "zone_orange_level1")
		{
			name = "Upper Orange Highrise Level 2";
		}
		else if (zone == "zone_orange_level2")
		{
			name = "Upper Orange Highrise Level 1";
		}
		else if (zone == "zone_orange_elevator_shaft_top")
		{
			name = "Elevator Shaft Level 3";
		}
		else if (zone == "zone_orange_elevator_shaft_middle_1")
		{
			name = "Elevator Shaft Level 2";
		}
		else if (zone == "zone_orange_elevator_shaft_middle_2")
		{
			name = "Elevator Shaft Level 1";
		}
		else if (zone == "zone_orange_elevator_shaft_bottom")
		{
			name = "Elevator Shaft Bottom";
		}
		else if (zone == "zone_orange_level3a")
		{
			name = "Lower Orange Highrise Level 1a";
		}
		else if (zone == "zone_orange_level3b")
		{
			name = "Lower Orange Highrise Level 1b";
		}
		else if (zone == "zone_blue_level5")
		{
			name = "Lower Blue Highrise Level 1";
		}
		else if (zone == "zone_blue_level4a")
		{
			name = "Lower Blue Highrise Level 2a";
		}
		else if (zone == "zone_blue_level4b")
		{
			name = "Lower Blue Highrise Level 2b";
		}
		else if (zone == "zone_blue_level4c")
		{
			name = "Lower Blue Highrise Level 2c";
		}
		else if (zone == "zone_blue_level2a")
		{
			name = "Upper Blue Highrise Level 1a";
		}
		else if (zone == "zone_blue_level2b")
		{
			name = "Upper Blue Highrise Level 1b";
		}
		else if (zone == "zone_blue_level2c")
		{
			name = "Upper Blue Highrise Level 1c";
		}
		else if (zone == "zone_blue_level2d")
		{
			name = "Upper Blue Highrise Level 1d";
		}
		else if (zone == "zone_blue_level1a")
		{
			name = "Upper Blue Highrise Level 2a";
		}
		else if (zone == "zone_blue_level1b")
		{
			name = "Upper Blue Highrise Level 2b";
		}
		else if (zone == "zone_blue_level1c")
		{
			name = "Upper Blue Highrise Level 2c";
		}
	}
	else if (level.script == "zm_prison")
	{
		if (zone == "zone_start")
		{
			name = "D-Block";
		}
		else if (zone == "zone_library")
		{
			name = "Library";
		}
		else if (zone == "zone_cellblock_west")
		{
			name = "Cell Block 2nd Floor";
		}
		else if (zone == "zone_cellblock_west_gondola")
		{
			name = "Cell Block 3rd Floor";
		}
		else if (zone == "zone_cellblock_west_gondola_dock")
		{
			name = "Cell Block Gondola";
		}
		else if (zone == "zone_cellblock_west_barber")
		{
			name = "Michigan Avenue";
		}
		else if (zone == "zone_cellblock_east")
		{
			name = "Times Square";
		}
		else if (zone == "zone_cafeteria")
		{
			name = "Cafeteria";
		}
		else if (zone == "zone_cafeteria_end")
		{
			name = "Cafeteria End";
		}
		else if (zone == "zone_infirmary")
		{
			name = "Infirmary 1";
		}
		else if (zone == "zone_infirmary_roof")
		{
			name = "Infirmary 2";
		}
		else if (zone == "zone_roof_infirmary")
		{
			name = "Roof 1";
		}
		else if (zone == "zone_roof")
		{
			name = "Roof 2";
		}
		else if (zone == "zone_cellblock_west_warden")
		{
			name = "Sally Port";
		}
		else if (zone == "zone_warden_office")
		{
			name = "Warden's Office";
		}
		else if (zone == "cellblock_shower")
		{
			name = "Showers";
		}
		else if (zone == "zone_citadel_shower")
		{
			name = "Citadel To Showers";
		}
		else if (zone == "zone_citadel")
		{
			name = "Citadel";
		}
		else if (zone == "zone_citadel_warden")
		{
			name = "Citadel To Warden's Office";
		}
		else if (zone == "zone_citadel_stairs")
		{
			name = "Citadel Tunnels";
		}
		else if (zone == "zone_citadel_basement")
		{
			name = "Citadel Basement";
		}
		else if (zone == "zone_citadel_basement_building")
		{
			name = "China Alley";
		}
		else if (zone == "zone_studio")
		{
			name = "Building 64";
		}
		else if (zone == "zone_dock")
		{
			name = "Docks";
		}
		else if (zone == "zone_dock_puzzle")
		{
			name = "Docks Gates";
		}
		else if (zone == "zone_dock_gondola")
		{
			name = "Upper Docks";
		}
		else if (zone == "zone_golden_gate_bridge")
		{
			name = "Golden Gate Bridge";
		}
		else if (zone == "zone_gondola_ride")
		{
			name = "Gondola";
		}
	}
	else if (level.script == "zm_buried")
	{
		if (zone == "zone_start")
		{
			name = "Processing";
		}
		else if (zone == "zone_start_lower")
		{
			name = "Lower Processing";
		}
		else if (zone == "zone_tunnels_center")
		{
			name = "Center Tunnels";
		}
		else if (zone == "zone_tunnels_north")
		{
			name = "Courthouse Tunnels 2";
		}
		else if (zone == "zone_tunnels_north2")
		{
			name = "Courthouse Tunnels 1";
		}
		else if (zone == "zone_tunnels_south")
		{
			name = "Saloon Tunnels 3";
		}
		else if (zone == "zone_tunnels_south2")
		{
			name = "Saloon Tunnels 2";
		}
		else if (zone == "zone_tunnels_south3")
		{
			name = "Saloon Tunnels 1";
		}
		else if (zone == "zone_street_lightwest")
		{
			name = "Outside General Store & Bank";
		}
		else if (zone == "zone_street_lightwest_alley")
		{
			name = "Outside General Store & Bank Alley";
		}
		else if (zone == "zone_morgue_upstairs")
		{
			name = "Morgue";
		}
		else if (zone == "zone_underground_jail")
		{
			name = "Jail Downstairs";
		}
		else if (zone == "zone_underground_jail2")
		{
			name = "Jail Upstairs";
		}
		else if (zone == "zone_general_store")
		{
			name = "General Store";
		}
		else if (zone == "zone_stables")
		{
			name = "Stables";
		}
		else if (zone == "zone_street_darkwest")
		{
			name = "Outside Gunsmith";
		}
		else if (zone == "zone_street_darkwest_nook")
		{
			name = "Outside Gunsmith Nook";
		}
		else if (zone == "zone_gun_store")
		{
			name = "Gunsmith";
		}
		else if (zone == "zone_bank")
		{
			name = "Bank";
		}
		else if (zone == "zone_tunnel_gun2stables")
		{
			name = "Stables To Gunsmith Tunnel 2";
		}
		else if (zone == "zone_tunnel_gun2stables2")
		{
			name = "Stables To Gunsmith Tunnel";
		}
		else if (zone == "zone_street_darkeast")
		{
			name = "Outside Saloon & Toy Store";
		}
		else if (zone == "zone_street_darkeast_nook")
		{
			name = "Outside Saloon & Toy Store Nook";
		}
		else if (zone == "zone_underground_bar")
		{
			name = "Saloon";
		}
		else if (zone == "zone_tunnel_gun2saloon")
		{
			name = "Saloon To Gunsmith Tunnel";
		}
		else if (zone == "zone_toy_store")
		{
			name = "Toy Store Downstairs";
		}
		else if (zone == "zone_toy_store_floor2")
		{
			name = "Toy Store Upstairs";
		}
		else if (zone == "zone_toy_store_tunnel")
		{
			name = "Toy Store Tunnel";
		}
		else if (zone == "zone_candy_store")
		{
			name = "Candy Store Downstairs";
		}
		else if (zone == "zone_candy_store_floor2")
		{
			name = "Candy Store Upstairs";
		}
		else if (zone == "zone_street_lighteast")
		{
			name = "Outside Courthouse & Candy Store";
		}
		else if (zone == "zone_underground_courthouse")
		{
			name = "Courthouse Downstairs";
		}
		else if (zone == "zone_underground_courthouse2")
		{
			name = "Courthouse Upstairs";
		}
		else if (zone == "zone_street_fountain")
		{
			name = "Fountain";
		}
		else if (zone == "zone_church_graveyard")
		{
			name = "Graveyard";
		}
		else if (zone == "zone_church_main")
		{
			name = "Church Downstairs";
		}
		else if (zone == "zone_church_upstairs")
		{
			name = "Church Upstairs";
		}
		else if (zone == "zone_mansion_lawn")
		{
			name = "Mansion Lawn";
		}
		else if (zone == "zone_mansion")
		{
			name = "Mansion";
		}
		else if (zone == "zone_mansion_backyard")
		{
			name = "Mansion Backyard";
		}
		else if (zone == "zone_maze")
		{
			name = "Maze";
		}
		else if (zone == "zone_maze_staircase")
		{
			name = "Maze Staircase";
		}
	}
	else if (level.script == "zm_tomb")
	{
		if (isDefined(self.teleporting) && self.teleporting)
		{
			return "";
		}

		if (zone == "zone_start")
		{
			name = "Lower Laboratory";
		}
		else if (zone == "zone_start_a")
		{
			name = "Upper Laboratory";
		}
		else if (zone == "zone_start_b")
		{
			name = "Generator 1";
		}
		else if (zone == "zone_bunker_1a")
		{
			name = "Generator 3 Bunker 1";
		}
		else if (zone == "zone_fire_stairs")
		{
			name = "Fire Tunnel";
		}
		else if (zone == "zone_bunker_1")
		{
			name = "Generator 3 Bunker 2";
		}
		else if (zone == "zone_bunker_3a")
		{
			name = "Generator 3";
		}
		else if (zone == "zone_bunker_3b")
		{
			name = "Generator 3 Bunker 3";
		}
		else if (zone == "zone_bunker_2a")
		{
			name = "Generator 2 Bunker 1";
		}
		else if (zone == "zone_bunker_2")
		{
			name = "Generator 2 Bunker 2";
		}
		else if (zone == "zone_bunker_4a")
		{
			name = "Generator 2";
		}
		else if (zone == "zone_bunker_4b")
		{
			name = "Generator 2 Bunker 3";
		}
		else if (zone == "zone_bunker_4c")
		{
			name = "Tank Station";
		}
		else if (zone == "zone_bunker_4d")
		{
			name = "Above Tank Station";
		}
		else if (zone == "zone_bunker_tank_c")
		{
			name = "Generator 2 Tank Route 1";
		}
		else if (zone == "zone_bunker_tank_c1")
		{
			name = "Generator 2 Tank Route 2";
		}
		else if (zone == "zone_bunker_4e")
		{
			name = "Generator 2 Tank Route 3";
		}
		else if (zone == "zone_bunker_tank_d")
		{
			name = "Generator 2 Tank Route 4";
		}
		else if (zone == "zone_bunker_tank_d1")
		{
			name = "Generator 2 Tank Route 5";
		}
		else if (zone == "zone_bunker_4f")
		{
			name = "zone_bunker_4f";
		}
		else if (zone == "zone_bunker_5a")
		{
			name = "Workshop Downstairs";
		}
		else if (zone == "zone_bunker_5b")
		{
			name = "Workshop Upstairs";
		}
		else if (zone == "zone_nml_2a")
		{
			name = "No Man's Land Walkway";
		}
		else if (zone == "zone_nml_2")
		{
			name = "No Man's Land Entrance";
		}
		else if (zone == "zone_bunker_tank_e")
		{
			name = "Generator 5 Tank Route 1";
		}
		else if (zone == "zone_bunker_tank_e1")
		{
			name = "Generator 5 Tank Route 2";
		}
		else if (zone == "zone_bunker_tank_e2")
		{
			name = "zone_bunker_tank_e2";
		}
		else if (zone == "zone_bunker_tank_f")
		{
			name = "Generator 5 Tank Route 3";
		}
		else if (zone == "zone_nml_1")
		{
			name = "Generator 5 Tank Route 4";
		}
		else if (zone == "zone_nml_4")
		{
			name = "Generator 5 Tank Route 5";
		}
		else if (zone == "zone_nml_0")
		{
			name = "Generator 5 Left Footstep";
		}
		else if (zone == "zone_nml_5")
		{
			name = "Generator 5 Right Footstep Walkway";
		}
		else if (zone == "zone_nml_farm")
		{
			name = "Generator 5";
		}
		else if (zone == "zone_nml_celllar")
		{
			name = "Generator 5 Cellar";
		}
		else if (zone == "zone_bolt_stairs")
		{
			name = "Lightning Tunnel";
		}
		else if (zone == "zone_nml_3")
		{
			name = "No Man's Land 1st Right Footstep";
		}
		else if (zone == "zone_nml_2b")
		{
			name = "No Man's Land Stairs";
		}
		else if (zone == "zone_nml_6")
		{
			name = "No Man's Land Left Footstep";
		}
		else if (zone == "zone_nml_8")
		{
			name = "No Man's Land 2nd Right Footstep";
		}
		else if (zone == "zone_nml_10a")
		{
			name = "Generator 4 Tank Route 1";
		}
		else if (zone == "zone_nml_10")
		{
			name = "Generator 4 Tank Route 2";
		}
		else if (zone == "zone_nml_7")
		{
			name = "Generator 4 Tank Route 3";
		}
		else if (zone == "zone_bunker_tank_a")
		{
			name = "Generator 4 Tank Route 4";
		}
		else if (zone == "zone_bunker_tank_a1")
		{
			name = "Generator 4 Tank Route 5";
		}
		else if (zone == "zone_bunker_tank_a2")
		{
			name = "zone_bunker_tank_a2";
		}
		else if (zone == "zone_bunker_tank_b")
		{
			name = "Generator 4 Tank Route 6";
		}
		else if (zone == "zone_nml_9")
		{
			name = "Generator 4 Left Footstep";
		}
		else if (zone == "zone_air_stairs")
		{
			name = "Wind Tunnel";
		}
		else if (zone == "zone_nml_11")
		{
			name = "Generator 4";
		}
		else if (zone == "zone_nml_12")
		{
			name = "Generator 4 Right Footstep";
		}
		else if (zone == "zone_nml_16")
		{
			name = "Excavation Site Front Path";
		}
		else if (zone == "zone_nml_17")
		{
			name = "Excavation Site Back Path";
		}
		else if (zone == "zone_nml_18")
		{
			name = "Excavation Site Level 3";
		}
		else if (zone == "zone_nml_19")
		{
			name = "Excavation Site Level 2";
		}
		else if (zone == "ug_bottom_zone")
		{
			name = "Excavation Site Level 1";
		}
		else if (zone == "zone_nml_13")
		{
			name = "Generator 5 To Generator 6 Path";
		}
		else if (zone == "zone_nml_14")
		{
			name = "Generator 4 To Generator 6 Path";
		}
		else if (zone == "zone_nml_15")
		{
			name = "Generator 6 Entrance";
		}
		else if (zone == "zone_village_0")
		{
			name = "Generator 6 Left Footstep";
		}
		else if (zone == "zone_village_5")
		{
			name = "Generator 6 Tank Route 1";
		}
		else if (zone == "zone_village_5a")
		{
			name = "Generator 6 Tank Route 2";
		}
		else if (zone == "zone_village_5b")
		{
			name = "Generator 6 Tank Route 3";
		}
		else if (zone == "zone_village_1")
		{
			name = "Generator 6 Tank Route 4";
		}
		else if (zone == "zone_village_4b")
		{
			name = "Generator 6 Tank Route 5";
		}
		else if (zone == "zone_village_4a")
		{
			name = "Generator 6 Tank Route 6";
		}
		else if (zone == "zone_village_4")
		{
			name = "Generator 6 Tank Route 7";
		}
		else if (zone == "zone_village_2")
		{
			name = "Church";
		}
		else if (zone == "zone_village_3")
		{
			name = "Generator 6 Right Footstep";
		}
		else if (zone == "zone_village_3a")
		{
			name = "Generator 6";
		}
		else if (zone == "zone_ice_stairs")
		{
			name = "Ice Tunnel";
		}
		else if (zone == "zone_bunker_6")
		{
			name = "Above Generator 3 Bunker";
		}
		else if (zone == "zone_nml_20")
		{
			name = "Above No Man's Land";
		}
		else if (zone == "zone_village_6")
		{
			name = "Behind Church";
		}
		else if (zone == "zone_chamber_0")
		{
			name = "The Crazy Place Lightning Chamber";
		}
		else if (zone == "zone_chamber_1")
		{
			name = "The Crazy Place Lightning & Ice";
		}
		else if (zone == "zone_chamber_2")
		{
			name = "The Crazy Place Ice Chamber";
		}
		else if (zone == "zone_chamber_3")
		{
			name = "The Crazy Place Fire & Lightning";
		}
		else if (zone == "zone_chamber_4")
		{
			name = "The Crazy Place Center";
		}
		else if (zone == "zone_chamber_5")
		{
			name = "The Crazy Place Ice & Wind";
		}
		else if (zone == "zone_chamber_6")
		{
			name = "The Crazy Place Fire Chamber";
		}
		else if (zone == "zone_chamber_7")
		{
			name = "The Crazy Place Wind & Fire";
		}
		else if (zone == "zone_chamber_8")
		{
			name = "The Crazy Place Wind Chamber";
		}
		else if (zone == "zone_robot_head")
		{
			name = "Robot's Head";
		}
	}

	return name;
}
