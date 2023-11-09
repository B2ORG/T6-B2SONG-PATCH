#include maps\mp\_utility;
#include maps\mp\gametypes_zm\_hud_util;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_stats;
#include maps\mp\zombies\_zm_zonemgr;

init()
{
    precacheshader("waypoint_revive");

    level.SONG_TIMING = array();
    level.SONG_TIMING["version"] = 1;
    level.SONG_TIMING["debug"] = false;
    level.SONG_TIMING["hud_right_pos"] = 30;
	level.SONG_TIMING["tenth_timer_in_use"] = false;
    level.SONG_TIMING["allow_firstbox"] = true;
	level.SONG_TIMING["split_hud"] = get_split_hud_properties();
	level.SONG_TIMING["randomize_color"] = false;
	level.SONG_TIMING["leaderboards_enabled"] = true;

	// if (is_debug())
	// 	level.destructible_callbacks["headless"] = ::sndmusegg3_counter_override;

    set_dvars();

    level thread song_main();
    level thread song_player();
}

song_main()
{
	level endon("end_game");

	level waittill("initial_players_connected");

	if (is_town() || is_farm() || is_depot())
		bad_map();
	thread welcome_prints();

    flag_wait("initial_blackscreen_passed");
    flag_set("game_started");

	level thread song_timing();

    song_hud();
    level thread first_box_handler();
    level thread perma_perks_handler();

	if (has_permaperks_system() && isDefined(level.B2_FRIDGE))
		thread [[level.B2_FRIDGE]](::player_rig_fridge);

    if (isDefined(level.B2_POWERUP_TRACKING))
        level thread [[level.B2_POWERUP_TRACKING]]();

    if (is_nuketown())
        level thread move_chest();

	level thread clear_sound_lock();

	if (is_anypercent())
		level thread [[level.B2_SONG_ANYPERCENT.powerup_rig]]();
}

song_player()
{
	level endon("end_game");

    while (true)
    {
	    level waittill("connected", player );
        player thread player_thread();
    }
}

player_thread()
{
	level endon("end_game");
	self endon("disconnect");

    self waittill("spawned_player");

    if (is_debug())
        self.score = 666666;

    self thread velocity_meter();
    self thread zone_hud();
	self thread fill_up_bank();
	self thread set_characters();

	if (is_anypercent())
		self thread [[level.B2_SONG_ANYPERCENT.disable_oob_safety]]();
	// if (is_debug())
	// 	self thread get_my_coordinates();
}

song_hud()
{
	level.hud_color = (1, 1, 1);
	if (song_config("randomize_color"))
		level.hud_color = get_random_hud_color();

    level thread game_timer();
    level thread round_timer();
    level thread attempts_hud();
    level thread gspeed_watcher();

    level thread generate_sign(-186, "MUSIC LOCK", ::eval_music_override);
    level thread generate_sign(-62, "POINT DROP", ::eval_point_drop);
    level thread generate_sign(62, "FIRST BOX", ::eval_first_box);
    level thread generate_sign(186, "ANYPERCENT", ::is_anypercent);
}


/*						UTILITIES						*/

print(arg)
{}

debug_print(text)
{
    if (is_debug())
        print("DEBUG: " + text);
}

bad_map()
{
	wait 0.75;
	iPrintLn("^1MAP NOT SUPPORTED!");
	wait 0.75;
	level notify("end_game");
}

welcome_prints()
{
	level endon("end_game");

	wait 0.75;
	iPrintLn("B2^1SONG^7 PATCH ^1V" + song_config("version"));
	wait 0.75;
	iPrintLn("Source: ^1github.com/B2ORG/T6-B2SONG-PATCH");

	if (level.players.size > 1)
	{
		wait 0.75;
		iPrintLn("^1REMINDER^7 - Since April 2023, all coops require all players POV to be publicly uploaded!");
	}

	if (leaderboards_enabled())
	{
		wait 0.75;
		iPrintLn("Leaderboard updated on: ^1"+ level.B2_SONG_LEADERBOARD["date"] + " ^7by ^1" + level.B2_SONG_LEADERBOARD["update_by"]);
	}
}

is_debug()
{
    if (song_config("debug"))
        return true;
    return false;
}

leaderboards_enabled()
{
	if (song_config("leaderboards_enabled") && isDefined(level.B2_SONG_LEADERBOARD))
		return true;
	return false;
}

force_restart(reason, waittime)
{
	level endon("end_game");

	if (isDefined(reason))
		iPrintLn(reason);

	if (isDefined(waittime))
		wait waittime;

	if (getDvar("song_attempts") != "" && getDvarInt("song_attempts") > 0)
		setDvar("song_attempts", getDvarInt("song_attempts") - 1);

	wait 0.05;

	if (is_plutonium())
		map_restart();
	else
		level notify("end_game");
}

player_thread_black_screen_waiter()
{
	level endon("end_game");

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

get_split_hud_properties()
{
	properties = array();

	switch (level.script)
	{
		case "zm_transit":
		case "zm_highrise":
		case "zm_buried":
			properties["ypos"] = -20;
			properties["optimize"] = false;
			break;
		case "zm_nuked":
			properties["ypos"] = -20;
			properties["optimize"] = true;
			break;
		case "zm_prison":
			properties["ypos"] = 40;
			properties["optimize"] = false;
		case "zm_tomb":
			properties["ypos"] = 40;
			properties["optimize"] = true;
			break;
		default:
			debug_print("get_split_hud_properties(): Could not get hud properties for map '" + level.script + "'");
	}

	return properties;
}

is_town()
{
	if (level.script == "zm_transit" && level.scr_zm_map_start_location == "town" && level.scr_zm_ui_gametype_group == "zsurvival")
		return true;
	return false;
}

is_farm()
{
	if (level.script == "zm_transit" && level.scr_zm_map_start_location == "farm" && level.scr_zm_ui_gametype_group == "zsurvival")
		return true;
	return false;
}

is_depot()
{
	if (level.script == "zm_transit" && level.scr_zm_map_start_location == "transit" && level.scr_zm_ui_gametype_group == "zsurvival")
		return true;
	return false;
}

is_tranzit()
{
	if (level.script == "zm_transit" && level.scr_zm_map_start_location == "transit" && level.scr_zm_ui_gametype_group == "zclassic")
		return true;
	return false;
}

is_nuketown()
{
	if (level.script == "zm_nuked")
		return true;
	return false;
}

is_die_rise()
{
	if (level.script == "zm_highrise")
		return true;
	return false;
}

is_mob()
{
	if (level.script == "zm_prison")
		return true;
	return false;
}

is_buried()
{
	if (level.script == "zm_buried")
		return true;
	return false;
}

is_origins()
{
	if (level.script == "zm_tomb")
		return true;
	return false;
}

set_dvars()
{
    flag_init("game_started");
    flag_init("box_rigged");

    setdvar("player_strafespeedscale", 1);
    setdvar("player_backspeedscale", 0.9);
    setdvar("g_speed", 190);
}

is_anypercent()
{
	if (isDefined(level.B2_SONG_ANYPERCENT) && level.B2_SONG_ANYPERCENT.enabled)
		return true;
	return false;
}

is_plutonium()
{
	// Returns true for Pluto versions r2693 and above
	if (getDvar("cg_weaponCycleDelay") == "")
		return false;
	return true;
}

has_permaperks_system()
{
	/* Refer to init_persistent_abilities() */
	if (isDefined(level.pers_upgrade_boards))
		return true;
	return false;
}

to_string_zfill(num)
{
	if (num == 0)
		return "00";
	if (num < 10)
		return "0" + num;
	return "" + num;
}

to_string_rfill(num)
{
	num = "" + num;
	if (num.size == 1)
		return num + "0";
	return num;
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
		case "mannequin":
			message = "MANNEQUINS UNVEILED";
			break;
        default:
            message = content;
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
	level endon("end_game");

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

get_random_hud_color(override)
{
	/*
	colors = array();
	colors["red"] = (1, 0, 0);
	colors["green"] = (0, 1, 0);
	colors["blue"] = (0, 0, 1);
	colors["orange"] = (1, 0.5, 0);
	colors["yellow"] = (1, 1, 0);
	colors["light green"] = (0.5, 1, 0);
	colors["mint"] = (0, 1, 0.5);
	colors["cyan"] = (0, 1, 1);
	colors["light blue"] = (0, 0.5, 1);
	colors["purple"] = (0.5, 0, 1);
	colors["light pink"] = (1, 0, 1);
	colors["pink"] = (1, 0, 0.5);
	colors["white"] = (1, 1, 1);
	*/
	colors = array((1, 0, 0), (0, 1, 0), (0, 0, 1), (1, 0.5, 0), (1, 1, 0), (0.5, 1, 0), (0, 1, 0.5), (0, 1, 1), (0, 0.5, 1), (0.5, 0, 1), (1, 0, 1), (1, 0, 0.5), (1, 1, 1));

    if (isDefined(override) && isDefined(colors[override]))
		return colors[override];

	return colors[randomIntRange(0, colors.size)];
}

draw_song(split, songcode)
{
	posy = song_config("split_hud")["ypos"];

	increment = 140;
	s_increment = 18;
	textscale = 1.8;
	if (song_config("split_hud")["optimize"])
	{
		textscale = 1.4;
		increment = 80;
		s_increment = 12;
	}

	posy += level.activated_songs * increment;

	debug_print("draw_song(): drawing song " + songcode + " on posy " + posy);

	song_head = createserverfontstring("objective", textscale);
	song_head setpoint("TOPLEFT", "TOPLEFT", -40, posy);
	song_head.color = (1, 1, 1);
	song_head.alpha = 1;
	song_head setText(get_song_title(songcode) + "\n^3" + split.time_readable);
}

draw_split(split, num_of_splits)
{
	increment = 140;
	s_increment = 22;
	textscale = 1.5;
	if (song_config("split_hud")["optimize"])
	{
		textscale = 1.2;
		increment = 80;
		s_increment = 17;
	}

	posy = song_config("split_hud")["ypos"] + s_increment;
	posy += (level.activated_songs * increment) + (num_of_splits * s_increment);

	debug_print("draw_split(): drawing split nr " + num_of_splits + " on posy " + posy);
	
	split_hud = createserverfontstring("default", textscale);
	split_hud setpoint("TOPLEFT", "TOPLEFT", -40, posy);
	split_hud.color = (1, 1, 1);
	split_hud.alpha = 1;
	split_hud setText(split.message);
}

watch_for_kill_trigger(trigger, func, arg1, arg2)
{
	level endon("end_game");

	level waittill(trigger);
	[[func]](arg1, arg2);
	self notify(trigger + "_wrapped");
}

hud_delete(hud_elem, fade_time)
{
	level endon("end_game");

	hud_elem fadeOverTime(fade_time);
	hud_elem.alpha = 0;

	wait fade_time + 0.05;
	hud_elem delete();
}

game_timer()
{
    self endon("disconnect");
    level endon("end_game");

    timer_hud = createserverfontstring("big" , 1.6);
	timer_hud setPoint("TOPRIGHT", "TOPRIGHT", song_config("hud_right_pos"), 0);
	if (song_config("tenth_timer_in_use"))
		timer_hud setPoint("LEFT", "TOPRIGHT", -18, 12);
	timer_hud.alpha = 1;
	timer_hud.color = level.hud_color;

	if (song_config("tenth_timer_in_use"))
		timer_hud setTenthsTimerUp(0.05);
	else
		timer_hud setTimerUp(0);
}

round_timer()
{
    level endon("end_game");

	round_hud = createserverfontstring("big" , 1.6);
	round_hud setPoint("TOPRIGHT", "TOPRIGHT", song_config("hud_right_pos"), 16);
	round_hud.color = level.hud_color;
	round_hud.alpha = 0;

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

eval_first_box()
{
    if (isDefined(level.is_first_box) && level.is_first_box)
        return true;
    return false;
}

gspeed_watcher()
{
	level endon("end_game");

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

current_time_text()
{
	return timer_text((getTime() - level.song_start_timestamp) / 1000);
}

timer_text(initial_seconds)
{
	if (isstring(initial_seconds))
		initial_seconds = float(initial_seconds);

	time_array = array();

	if (isSubStr("" + initial_seconds, "."))
		time_array["miliseconds"] = int(strTok("" + initial_seconds, ".")[1]);
	else
		time_array["miliseconds"] = 0;
	time_array["seconds"] = int(initial_seconds);
	time_array["minutes"] = 0;
	time_array["hours"] = 0;

	if (time_array["seconds"] >= 60)
	{
		c0 = get_time_element(time_array["seconds"], 60);
		time_array["minutes"] = c0[0];
		time_array["seconds"] = c0[1];

		if (time_array["minutes"] >= 60)
		{
			c1 = get_time_element(time_array["minutes"], 60);
			time_array["hours"] = c1[0];
			time_array["minutes"] = c1[1];
		}
	}

	time_array["miliseconds"] = to_string_rfill(time_array["miliseconds"]);
	time_array["seconds"] = to_string_zfill(time_array["seconds"]);
	time_array["minutes"] = to_string_zfill(time_array["minutes"]);
	time_array["hours"] = to_string_zfill(time_array["hours"]);

	if (time_array["hours"] != "00")
		return time_array["hours"] + ":" + time_array["minutes"] + ":" + time_array["seconds"] + "." + time_array["miliseconds"];
	return time_array["minutes"] + ":" + time_array["seconds"] + "." + time_array["miliseconds"];
}

get_time_element(value, step)
{
	for (i = 0; value >= step * (i + 1); i++) {}
	remainer = value - (step * i);
	debug_print("get_time_element(): i=" + i + " remainer=" + remainer);
	return array(i, remainer);
}

number_as_string(num, upper)
{
	number_table = array();
	number_table[0] = "ZERO";
	number_table[1] = "FIRST";
	number_table[2] = "SECOND";
	number_table[3] = "THIRD";
	number_table[4] = "FOURTH";
	number_table[5] = "FIFTH";

	str = number_table[int(num)];
	if (!isDefined(str))
		return "";
	
	if (!upper)
		return toLower(str);
	return str;
}

first_box_handler()
{
    level endon("end_game");

	flag_wait("initial_blackscreen_passed");

	// Init thread counting box hits
	thread init_boxhits_watcher();
	// Scan weapons in the box
	thread scan_in_box();
	// First Box main loop
	thread first_box();
}

init_boxhits_watcher()
{
    level endon("end_game");

	level.total_box_hits = 0;

	while (!isDefined(level.chests))
		wait 0.05;

	foreach(chest in level.chests)
		chest thread watch_box_state();
}

watch_box_state()
{
    level endon("end_game");

    while (!isDefined(self.zbarrier))
        wait 0.05;

	while (true)
	{
        while (self.zbarrier getzbarrierpiecestate(2) != "opening")
            wait 0.05;
		level.total_box_hits++;
        while (self.zbarrier getzbarrierpiecestate(2) == "opening")
            wait 0.05;
	}
}

scan_in_box()
{
    level endon("end_game");

    if (is_town() || is_farm() || is_depot() || is_tranzit())
        should_be_in_box = 25;
	else if (is_nuketown())
        should_be_in_box = 26;
	else if (is_die_rise())
        should_be_in_box = 24;
	else if (is_mob())
        should_be_in_box = 16;
    else if (is_buried())
        should_be_in_box = 22;
	else if (is_origins())
		should_be_in_box = 23;

	offset = 0;
	if (is_die_rise() || is_origins())
		offset = 1;

    while (isDefined(should_be_in_box))
    {
        wait 0.05;

        in_box = 0;

		foreach (weapon in getarraykeys(level.zombie_weapons))
        {
            if (maps\mp\zombies\_zm_weapons::get_is_in_box(weapon))
                in_box++;
        }

		// debug_print("in_box: " + in_box + " should: " + should_be_in_box);

        if (in_box == should_be_in_box)
			continue;

		else if ((offset > 0) && (in_box == (should_be_in_box + offset)))
			continue;

		level.is_first_box = true;
		break;
    }
}

first_box()
{	
	if (!song_config("allow_firstbox"))
		return;

	thread box_watch_dvar();
	if (is_plutonium())
		thread box_watch_chat();
}

box_watch_dvar()
{
    level endon("end_game");
	level endon("break_firstbox");

	setDvar("fb", "");
	while (true)
	{
		wait 0.05;

		if (getDvar("fb") == "")
			continue;

		thread rig_box(getDvar("fb"), level.players[0]);
		wait_network_frame();

		while (flag("box_rigged"))
			wait 0.05;

		setDvar("fb", "");
	}
}

box_watch_chat()
{
    level endon("end_game");
	level endon("break_firstbox");

	while (true)
	{
		message = undefined;

		level waittill("say", message, player);

		if (isSubStr(message, "fb"))
			wpn_key = getSubStr(message, 3);
		else
			continue;

		thread rig_box(wpn_key, player);
		wait_network_frame();

		wpn_key = undefined;

		while (flag("box_rigged"))
			wait 0.05;
	}
}

rig_box(gun, player)
{
    level endon("end_game");

	weapon_key = get_weapon_key(gun, ::box_weapon_verification);
	if (isDefined(player))
		weapon_key = player player_box_weapon_verification(weapon_key);

	if (weapon_key == "")
	{
		iPrintLn("Wrong weapon key: ^1" + gun);
		return;
	}

	// weapon_name = level.zombie_weapons[weapon_key].name;
	iPrintLn(player.name + "^7 set box weapon to: ^3" + weapon_display_wrapper(weapon_key));
	level.is_first_box = true;

	saved_check = level.special_weapon_magicbox_check;
	current_box_hits = level.total_box_hits;
	removed_guns = array();

	flag_set("box_rigged");
	// debug_print("FIRST BOX: flag('box_rigged'): " + flag("box_rigged"));

	level.special_weapon_magicbox_check = undefined;
	foreach(weapon in getarraykeys(level.zombie_weapons))
	{
		if ((weapon != weapon_key) && level.zombie_weapons[weapon].is_in_box == 1)
		{
			removed_guns[removed_guns.size] = weapon;
			level.zombie_weapons[weapon].is_in_box = 0;
			// debug_print("FIRST BOX: setting " + weapon + ".is_in_box to 0");
		}
	}

	/* Critical loop responsible for restoring proper state */
	while ((current_box_hits == level.total_box_hits) || !isDefined(level.total_box_hits))
		wait 0.05;
	
	wait 5;

	level.special_weapon_magicbox_check = saved_check;

	// debug_print("FIRST BOX: removed_guns.size " + removed_guns.size);
	if (removed_guns.size > 0)
	{
		foreach(rweapon in removed_guns)
		{
			level.zombie_weapons[rweapon].is_in_box = 1;
			// debug_print("FIRST BOX: setting " + rweapon + ".is_in_box to 1");
		}
	}

	flag_clear("box_rigged");
}

get_weapon_key(weapon_str, verifier)
{
	switch(weapon_str)
	{
		case "mk1":
			key = "ray_gun_zm";
			break;
		case "mk2":
			key = "raygun_mark2_zm";
			break;
		case "monk":
			key = "cymbal_monkey_zm";
			break;
		case "emp":
			key = "emp_grenade_zm";
			break;
		case "time":
			key = "time_bomb_zm";
			break;
		case "sliq":
			key = "slipgun_zm";
			break;
		case "blunder":
			key = "blundergat_zm";
			break;
		case "paralyzer":
			key = "slowgun_zm";
			break;

		case "ak47":
			key = "ak47_zm";
			break;
		case "an94":
			key = "an94_zm";
			break;
		case "barret":
			key = "barretm82_zm";
			break;
		case "b23r":
			key = "beretta93r_zm";
			break;
		case "b23re":
			key = "beretta93r_extclip_zm";
			break;
		case "dsr":
			key = "dsr50_zm";
			break;
		case "evo":
			key = "evoskorpion_zm";
			break;
		case "57":
			key = "fiveseven_zm";
			break;
		case "257":
			key = "fivesevendw_zm";
			break;
		case "fal":
			key = "fnfal_zm";
			break;
		case "galil":
			key = "galil_zm";
			break;
		case "mtar":
			key = "tar21_zm";
			break;
		case "hamr":
			key = "hamr_zm";
			break;
		case "m27":
			key = "hk416_zm";
			break;
		case "exe":
			key = "judge_zm";
			break;
		case "kap":
			key = "kard_zm";
			break;
		case "bk":
			key = "knife_ballistic_zm";
			break;
		case "ksg":
			key = "ksg_zm";
			break;
		case "wm":
			key = "m32_zm";
			break;
		case "mg":
			key = "mg08_zm";
			break;
		case "lsat":
			key = "lsat_zm";
			break;
		case "dm":
			key = "minigun_alcatraz_zm";
		case "mp40":
			key = "mp40_stalker_zm";
			break;
		case "pdw":
			key = "pdw57_zm";
			break;
		case "pyt":
			key = "python_zm";
			break;
		case "rnma":
			key = "rnma_zm";
			break;
		case "type":
			key = "type95_zm";
			break;
		case "rpd":
			key = "rpd_zm";
			break;
		case "s12":
			key = "saiga12_zm";
			break;
		case "scar":
			key = "scar_zm";
			break;
		case "m1216":
			key = "srm1216_zm";
			break;
		case "tommy":
			key = "thompson_zm";
			break;
		case "chic":
			key = "qcw05_zm";
			break;
		case "rpg":
			key = "usrpg_zm";
			break;
		case "m8":
			key = "xm8_zm";
			break;
		case "m16":
			key = "m16_zm";
			break;
		case "remington":
			key = "870mcs_zm";
			break;
		case "oly":
		case "olympia":
			key = "rottweil72_zm";
			break;
		case "mp5":
			key = "mp5k_zm";
			break;
		case "ak74":
			key = "ak74u_zm";
			break;
		case "m14":
			key = "m14_zm";
			break;
		case "svu":
			key = "svu_zm";
			break;
		default:
			key = weapon_str;
	}

	if (!isDefined(verifier))
		verifier = ::default_weapon_verification;

	key = [[verifier]](key);

	// debug_print("get_weapon_key(): weapon_key: " + key);
	return key;
}

default_weapon_verification()
{
    weapon_key = get_base_weapon_name(weapon_key, 1);

    if (!is_weapon_included(weapon_key))
        return "";

	return weapon_key;
}

box_weapon_verification(weapon_key)
{
	if (!is_true(level.zombie_weapons[weapon_key].is_in_box))
		return "";
	return weapon_key;
}

player_box_weapon_verification(weapon_key)
{
	if (self has_weapon_or_upgrade(weapon_key))
		return "";
	if (!limited_weapon_below_quota(weapon_key, self, getentarray("specialty_weapupgrade", "script_noteworthy")))
		return "";

	switch (weapon_key)
	{
		case "ray_gun_zm":
			if (self has_weapon_or_upgrade("raygun_mark2_zm"))
				return "";
		case "raygun_mark2_zm":
			if (self has_weapon_or_upgrade("ray_gun_zm"))
				return "";
	}

	return weapon_key;
}

weapon_display_wrapper(weapon_key)
{
	if (weapon_key == "emp_grenade_zm")
		return "Emp Grenade";
	if (weapon_key == "cymbal_monkey_zm")
		return "Cymbal Monkey";
	
	return get_weapon_display_name(weapon_key);
}

move_chest()
{
	level endon("end_game");

    wait 1;

    level.forced_box_location = "start_chest2";

	if (isDefined(level._zombiemode_custom_box_move_logic))
		kept_move_logic = level._zombiemode_custom_box_move_logic;

	level._zombiemode_custom_box_move_logic = ::force_next_location;
	foreach(chest in level.chests)
	{
		if (!chest.hidden && chest.script_noteworthy == level.forced_box_location)
			return;

		if (!chest.hidden)
		{
			level.chest_min_move_usage = 8;

			flag_set("moving_chest_now");
			chest thread maps\mp\zombies\_zm_magicbox::treasure_chest_move();

			wait 0.05;
			level notify("weapon_fly_away_start");
			wait 0.05;
			level notify("weapon_fly_away_end");
			break;
		}
	}

	while (flag("moving_chest_now"))
		wait 0.05;

	if (isDefined(kept_move_logic))
		level._zombiemode_custom_box_move_logic = kept_move_logic;

	level.chest_min_move_usage = 4;
	return;
}

force_next_location()
{
	for (b=0; b<level.chests.size; b++)
	{
		if (level.chests[b].script_noteworthy == level.forced_box_location)
			level.chest_index = b;
	}
}

fill_up_bank()
{
	level endon("end_game");
	self endon("disconnect");

	flag_wait("initial_blackscreen_passed");

    if (has_permaperks_system())
        self.account_value = level.bank_account_max;
}


perma_perks_handler()
{
	if (!has_permaperks_system())
		return;

	foreach (player in level.players)
		player thread award_permaperks_safe();
}

permaperk_array(code, maps_award, maps_take)
{
	if (!isDefined(maps_award))
		maps_award = array("zm_transit", "zm_highrise", "zm_buried");
	if (!isDefined(maps_take))
		maps_take = array();

	permaperk = array();
	permaperk["code"] = code;
	permaperk["maps_award"] = maps_award;
	permaperk["maps_take"] = maps_take;

	return permaperk;
}

award_permaperks_safe()
{
	level endon("end_game");
	self endon("disconnect");

	while (!isalive(self))
		wait 0.05;

	wait 0.5;

	perks_to_process = array();
	perks_to_process[perks_to_process.size] = permaperk_array("revive");
	perks_to_process[perks_to_process.size] = permaperk_array("multikill_headshots");
	perks_to_process[perks_to_process.size] = permaperk_array("perk_lose");
	perks_to_process[perks_to_process.size] = permaperk_array("jugg");
	perks_to_process[perks_to_process.size] = permaperk_array("flopper", array("zm_buried"));
	perks_to_process[perks_to_process.size] = permaperk_array("box_weapon", array("zm_highrise", "zm_buried"), array("zm_transit"));
	perks_to_process[perks_to_process.size] = permaperk_array("cash_back");
	perks_to_process[perks_to_process.size] = permaperk_array("sniper");
	perks_to_process[perks_to_process.size] = permaperk_array("insta_kill");
	perks_to_process[perks_to_process.size] = permaperk_array("pistol_points");
	perks_to_process[perks_to_process.size] = permaperk_array("double_points");

	foreach (perk in perks_to_process)
	{
		self resolve_permaperk(perk);
		wait 0.05;
	}

	wait 0.5;
	perks_to_process = undefined;
	self uploadstatssoon();
}

resolve_permaperk(perk)
{
	wait 0.05;

	perk_code = perk["code"];

	if (isinarray(perk["maps_award"], level.script) && !self.pers_upgrades_awarded[perk_code])
	{
		for (j = 0; j < level.pers_upgrades[perk_code].stat_names.size; j++)
		{
			stat_name = level.pers_upgrades[perk_code].stat_names[j];
			stat_value = level.pers_upgrades[perk_code].stat_desired_values[j];

			self award_permaperk(stat_name, perk_code, stat_value);
		}
	}

	if (isinarray(perk["maps_take"], level.script) && self.pers_upgrades_awarded[perk_code])
		self remove_permaperk(perk_code);
}

award_permaperk(stat_name, perk_code, stat_value)
{
	// debug_print("awarding: " + stat_name + " " + perk_code + " " + stat_value);
	self.stats_this_frame[stat_name] = 1;
	self set_global_stat(stat_name, stat_value);
	self playsoundtoplayer("evt_player_upgrade", self);
}

remove_permaperk(perk_code)
{
	// debug_print("removing: " + perk_code);
	self.pers_upgrades_awarded[perk_code] = 0;
	self playsoundtoplayer("evt_player_downgrade", self);
}

clear_sound_lock()
{
	level endon("end_game");
	
	while(true)
	{
		wait 0.1;

		if (!is_debug() && !is_anypercent())
			continue;

		if (is_true(level.music_override))
		{
			if (is_debug())
			{
				wait 5;
				iPrintLn("DEBUG: ^1CLEARED MUSIC_OVERRIDE");
			}
			level.music_override = 0;
		}
	}
}


/*						CORE						*/


song_timing()
{
	level.song_start_timestamp = getTime();
	level.activated_songs = 0;
	level.printed_wrs = 0;
	setup_songs();
	start_tracking();
	level thread song_display();
}

setup_songs()
{
	level.songs = array();
	level.splits = array();
	setup_song("carrion", "zm_transit", ::transit_tracker_wrapper, ::progress_meteors, false, array("OPEN DEPOT", "SECOND TEDDY", "CARRION"));
	setup_song("lullaby", "zm_nuked", ::nuketown_tracker_wrapper1, ::progress_meteors, false, array("2ND FLOOR YELLOW HOUSE", "GREEN HOUSE", "SAMANTHA'S LULLABY"));
	setup_song("cominghome", "zm_nuked", ::nuketown_tracker_wrapper2, ::progress_mannequins, true, array("CLEAR MID", "CLEAR GREEN ZONE", "CLEAR YELLOW ZONE"));
	setup_song("damned", "zm_nuked", ::nuketown_tracker_wrapper3, ::progress_population, false, array("END OF ROUND 2", "END OF ROUND 4", "RE-DAMNED"));
	setup_song("fall", "zm_highrise", ::dierise_tracker_wrapper, ::progress_meteors, false, array("FIRST TEDDY", "SECOND TEDDY", "THIRD TEDDY"));
	setup_song("wawg", "zm_prison", ::motd_tracker_wrapper1, undefined, false, array("ENTER SHOWERS", "ENTER TUNNELS", "WHERE ARE WE GOING"));
	setup_song("rusty", "zm_prison", ::motd_tracker_wrapper2, ::progress_meteors, false, array("SECOND BOTTLE", "GONDOLA START", "RUSTY CAGE"));
	setup_song("alwaysrunning", "zm_buried", ::buried_tracker_wrapper, ::progress_meteors, false, array("ENTER BANK", "SECOND TEDDY", "ALWAYS RUNNING"));
	/* Splits are hidden for archangel to prevent duplicated iprintlns */
	setup_song("archangel", "zm_tomb", ::origins_tracker_wrapper1, ::progress_meteors, true, array("FIRST DOOR", "SECOND DOOR", "ENTER NML", "ARCHANGEL"));
	setup_song("aether", "zm_tomb", ::origins_tracker_wrapper2, ::progress_plates, false, array("FIRST DOOR", "SECOND DOOR", "OPEN GEN5", "AETHER"));
	setup_song("shepherd", "zm_tomb", ::origins_tracker_wrapper3, ::progress_radios, false, array("ENTER NML", "FIRST RADIO", "SECOND RADIO", "SHEPHERD OF FIRE"));
}

start_tracking()
{
	level.progress_meteor = true;
	level.progress_mannequin = true;
	level.progress_population = true;
	level.progress_plates = true;
	level.progress_radios = true;

	i = 0;
	foreach(song in level.songs)
	{
		if (song.map == level.script)
		{
			song thread [[song.display_progress]](i);
			song thread [[song.progress_tracking]]();
			song thread show_wr(i);
			i++;
		}
	}
}

song_display()
{
	level endon("end_game");

	while (true)
	{
		level waittill("song_done", song_code);

		debug_print("song_display(): Trigger 'song_done' received. song_code='" + song_code + "' activated_songs='" + level.activated_songs + "'");

		wait 0.05;

		splits = array_reverse(level.splits[song_code]);

		for (i = 0; i < splits.size; i++)
		{
			if (i == 0)
				draw_song(splits[i], song_code);
			else
				draw_split(splits[i], i);
		}

		toggle_tracking_off(song_code);

		level.activated_songs++;
	}
}

setup_song(code, map, progress_func, display_func, secret_splits, list_splits/*, wr_func, split_func*/)
{
	/*
	if (!isDefined(split_func))
		split_func = ::;
	if (!isDefined(wr_func))
		wr_func = ::show_wr;
	*/

	song = spawnStruct();
	song.code = code;
	song.title = get_song_title(code);
	song.map = map;
	song.progress_tracking = progress_func;
	song.display_progress = display_func;
	song.secret_splits = secret_splits;
	song.splits = list_splits;
	// song.split_generator = split_func;
	// song.show_wr = wr_func;

	level.songs[level.songs.size] = song;
}

split_handler(num_of_splits, custom)
{
	level endon("end_game");

	level.splits[self.code] = array();

	for (s = 0; s < num_of_splits; s++)
	{
		self waittill("split", index, data);

		if (isDefined(data))
			debug_print("split_handler(): trigger 'split' received with index='" + index + "' data='" + data + "'");

		// last_split = self [[self.split_generator]](index, s);
		last_split = self eval_split(index, s);

		if (!self.secret_splits)
			iPrintLn(last_split.message);
		else if (is_debug())
			iPrintLn("^1[THIS WILL BE HIDDEN] ^7" + last_split.message);

		if (isDefined(custom) && [[custom]](self, index, data))
			break;
	}

	level notify("song_done", self.code);
}

toggle_tracking_off(code)
{
	switch (code)
	{
		case "carrion":
		case "lullaby":
		case "fall":
		case "rusty":
		case "alwaysrunning":
		case "archangel":
			level.progress_meteor = false;
			break;
		case "cominghome":
			level.progress_mannequin = false;
			break;
		case "damned":
			level.progress_population = false;
			break;
		case "aether":
			level.progress_plates = false;
			break;
		case "shepherd":
			level.progress_radios = false;
			break;
		default:
			debug_print("toggle_tracking_off(): unknown code " + code);
	}
}

transit_tracker_wrapper()
{
	self thread track_zone(0, array("zone_pri2", "zone_station_ext"), undefined, true);
	self thread track_item(1, 2);
	self thread track_item(1, 3);
	self thread split_handler(3);
}

nuketown_tracker_wrapper1()
{
	self thread track_zone(0, array("openhouse2_f2_zone"), ::yellowhouse_bounds);
	self thread track_zone(1, array("openhouse1_f1_zone", "openhouse1_f2_zone"), ::greenhouse_bounds);
	self thread track_item(2, 3);
	self thread split_handler(3);
}

nuketown_tracker_wrapper2()
{
	mid_zones = array("culdesac_yellow_zone", "culdesac_green_zone", "truck_zone"/*, "culdesac_2_truck"*/);
	green_zones = array("openhouse1_f1_zone", "openhouse1_f2_zone", "openhouse1_backyard_zone");
	yellow_zones = array("openhouse2_f1_zone", "openhouse2_f2_zone", "openhouse2_backyard_zone", "ammo_door_zone");

	self.heads_off_in_zone = array();
	self.mannequins = array();
	self.mannequin_detected = 0;
	self thread track_mannequins(0, mid_zones, "mid");
	self thread track_mannequins(1, green_zones, "green");
	self thread track_mannequins(2, yellow_zones, "yellow");
	self thread split_handler(3);

	thread give_up_show_mannequins();
	self thread debug_controller();
	self thread mannequin_integrity();

}

nuketown_tracker_wrapper3()
{
	self thread track_rounds(0);
	self thread track_clock(2);
	self thread split_handler(3);
}

dierise_tracker_wrapper()
{
	self thread track_item(0);
	self thread split_handler(3);
}

motd_tracker_wrapper1()
{
	self thread track_zone(0, array("cellblock_shower"));
	self thread track_zone(1, array("zone_citadel_stairs"));
	self thread track_notification(2, "level", "nixie_935");
	self thread split_handler(3);
}

motd_tracker_wrapper2()
{
	self thread track_item(0, 2);
	self thread track_notification(1, "level", "gondola_moving");
	self thread track_item(2, 3);
	self thread split_handler(3);
}

buried_tracker_wrapper()
{
	self thread track_zone(0, array("zone_bank"), ::eval_bank_floor);
	self thread track_item(1, 2);
	self thread track_item(2, 3);
	self thread split_handler(3);
}

origins_tracker_wrapper1()
{
	self thread track_zone(0, array("zone_bunker_1a", "zone_bunker_2a"), undefined, true);
	self thread track_zone(1, array("zone_bunker_4a", "zone_bunker_3a"), undefined, true);
	self thread track_zone(2, array("zone_nml_2a"));
	self thread track_item(3, 3);
	self thread split_handler(4);
}

origins_tracker_wrapper2()
{
	self thread track_zone(0, array("zone_bunker_1a", "zone_bunker_2a"), undefined, true);
	self thread track_zone(1, array("zone_bunker_4a", "zone_bunker_3a"), undefined, true);
	self thread track_zone(2, array("zone_nml_farm"), undefined, true);
	self thread track_item(3, 3, self.code);
	self thread split_handler(4);
}

origins_tracker_wrapper3()
{
	self thread track_zone(0, array("zone_nml_2a"));
	self thread track_item(1, 1, self.code);
	self thread track_item(2, 2, self.code);
	self thread track_item(3, 3, self.code);
	self thread split_handler(4);
}

track_item(split_index, notify_after_x_activations, meta)
{
	level endon("end_game");

	if (!isDefined(meta))
	{
		while (!isDefined(level.meteor_counter))
			wait 0.05;

		if (isDefined(notify_after_x_activations))
		{
			while (level.meteor_counter < notify_after_x_activations)
				wait 0.05;
		}
		else
		{
			state = 0;
			while (true)
			{
				if (level.meteor_counter != state)
				{
					self notify("split", split_index, level.meteor_counter);
					state = level.meteor_counter;
					split_index++;
				}

				wait 0.05;
			}
		}

		self notify("split", split_index, level.meteor_counter);
	}
	else if (meta == "aether")
	{
		while (!isDefined(level.snd115count))
			wait 0.05;

		if (isDefined(notify_after_x_activations))
		{
			while (level.snd115count < notify_after_x_activations)
				wait 0.05;
		}
		else
		{
			state = 0;
			while (true)
			{
				if (level.snd115count != state)
				{
					self notify("split", split_index, level.snd115count);
					state = level.snd115count;
				}

				wait 0.05;
			}
		}

		self notify("split", split_index, level.snd115count);
	}

	else if (meta == "shepherd")
	{
		while (!isDefined(level.found_ee_radio_count))
			wait 0.05;

		if (isDefined(notify_after_x_activations))
		{
			while (level.found_ee_radio_count < notify_after_x_activations)
				wait 0.05;
		}
		else
		{
			state = 0;
			while (true)
			{
				if (level.found_ee_radio_count != state)
				{
					self notify("split", split_index, level.found_ee_radio_count);
					state = level.found_ee_radio_count;
				}

				wait 0.05;
			}
		}

		self notify("split", split_index, level.found_ee_radio_count);
	}
}

track_zone(split_index, zone_names, eval_func, eval_activity)
{
	level endon("end_game");

	debug_print("track_zone(): split_index=" + split_index + " / eval_func=" + isDefined(eval_func));

	break_out = false;
	while (!break_out)
	{
		if (isDefined(eval_activity) && eval_activity)
		{
			foreach(zone in zone_names)
			{
				if (isinarray(get_active_zone_names(), zone))
				{
					if (isDefined(eval_func) && ![[eval_func]]())
						continue;

					self notify("split", split_index, true);
					break_out = true;
					break;
				}
			}
		}
		else
		{
			foreach(player in level.players)
			{
				if (isinarray(zone_names, player get_current_zone()))
				{
					if (isDefined(eval_func) && ![[eval_func]](player))
						continue;

					self notify("split", split_index, player);
					break_out = true;
					break;
				}
			}
		}

		wait 0.05;
	}
}

track_mannequins(split_index, zone_collection, zone_code)
{
	level endon("end_game");
	level endon("kill_mannequin_tracking");

	destructibles = getentarray("destructible", "targetname");
	self.mannequins[zone_code] = array();
	self.heads_off_in_zone[zone_code] = 0;
	
	for (i = 0; i < destructibles.size; i++)
	{
		if (issubstr(destructibles[i].destructibledef, "male"))
		{
			foreach(zone in zone_collection)
			{
				if (destructibles[i] entity_in_zone(zone, true))
				{
					debug_print("track_mannequins(): [" + self.mannequin_detected + "] mannequinn '" + destructibles[i].destructibledef + "' of origin '" + destructibles[i].origin + "' found in zone '" + zone + "' and is being assigned to '" + zone_code + "'");
					self.mannequins[zone_code][self.mannequins[zone_code].size] = destructibles[i];
					self.mannequin_detected++;
				}
			}
		}
	}

	debug_print(self.mannequins[zone_code].size + " mannequins found for zone " + zone_code);

	foreach(mann in self.mannequins[zone_code])
	{
		self thread wait_for_destruction(mann, zone_code);
		mann thread mannequinn_debugger();
	}

	while (self.heads_off_in_zone[zone_code] != self.mannequins[zone_code].size)
		wait 0.05;

	self notify("split", split_index, zone_code);
}

wait_for_destruction(ent, zone_code)
{
	level endon("end_game");

	ent waittill("broken");
	ent.is_broken = true;
	self.heads_off_in_zone[zone_code]++;
}

track_clock(split_index)
{
	level endon("end_game");

	level waittill("magic_door_power_up_grabbed");
    if (level.population_count == 15)
	{
		debug_print("track_clock(): notifying");
		self notify("split", split_index, level.population_count);
	}
	debug_print("track_clock(): trigger received");
}

track_rounds(split_index)
{
	level endon("end_game");

	level waittill("end_of_round");
	level waittill("end_of_round");
	self notify("split", split_index, level.round_number);
	level waittill("end_of_round");
	level waittill("end_of_round");
	self notify("split", split_index + 1, level.round_number);
}

track_notification(split_index, type, trigger)
{
	level endon("end_game");

	switch (type)
	{
		case "flag":
			flag_wait(trigger);
			break;
		case "level":
			level waittill(trigger);
			break;
		default:
			type waittill(trigger);
	}

	self notify("split", split_index, trigger);
}

eval_bank_floor(player)
{
	if (player.origin[2] > 0 && player.origin[2] < 25)
		return true;
	return false;
}

eval_split(split_index, stub)
{
	split = spawnStruct();
	split.time = getTime();
	split.text = self.splits[split_index];
	split.time_readable = current_time_text();
	split.message = split.text + ": ^3" + split.time_readable;

	level.splits[self.code][level.splits[self.code].size] = split;
	return split;
}

eval_split_both(split_index, split_number)
{
	split = spawnStruct();
	split.time = getTime();
	if (split_index == 0)
		split.text = self.splits[0] + " " + (split_number + 1);
	else
		split.text = self.splits[1];
	split.time_readable = current_time_text();
	split.message = split.text + ": ^3" + split.time_readable;

	level.splits[self.code][level.splits[self.code].size] = split;
	return split;
}

notify_on_1(song, index, data)
{
	if (index == 1)
		return true;
	return false;
}

yellowhouse_bounds(player)
{
	if (player.origin[0] > 600 && player.origin[2] > 79)
		return true;
	return false;
}

greenhouse_bounds(player)
{
	if (player.origin[0] < -490 && player.origin[1] > 251)
		return true;
	return false;
}

get_song_title(code)
{
	switch (code)
	{
		case "carrion":
			return "CARRION";
		case "lullaby":
			return "SAMANTHA'S LULLABY";
		case "cominghome":
			return "COMING HOME";
		case "damned":
			return "RE-DAMNED";
		case "fall":
			return "WE ALL FALL DOWN";
		case "rusty":
			return "RUSTY CAGE";
		case "wawg":
			return "WHERE ARE WE GOING";
		case "alwaysrunning":
			return "ALWAYS RUNNING";
		case "archangel":
			return "ARCHANGEL";
		case "aether":
			return "AETHER";
		case "shepherd":
			return "SHEPHERD OF FIRE";
		default:
			return "UNKNOWN SONG";
	}
}

progress_hud(pos_multi)
{
	progress_hud = createserverfontstring("objective" , 1);
	progress_hud setPoint("TOPRIGHT", "TOPRIGHT", song_config("hud_right_pos"), 90 + (15 * pos_multi));
	progress_hud.color = (1, 1, 1);
	progress_hud.alpha = 0;

	return progress_hud;
}

progress_meteors(pos_multi)
{
	level endon("end_game");

	progress_hud = progress_hud(pos_multi);
	switch (self.code)
	{
		case "carrion":
		case "lullaby":
		case "fall":
		case "alwaysrunning":
			progress_hud.label = &"TEDDY BEARS: ^3";
			break;
		case "rusty":
			progress_hud.label = &"BOTTLES: ^3";
			break;
		case "archangel":
			progress_hud.label = &"METEORS: ^3";
			break;
		default:
			progress_hud.label = &"GOAL: ^3";
	}
	progress_hud setValue(0);
	progress_hud.alpha = 1;

	while (!isDefined(level.meteor_counter))
		wait 0.05;

	while (level.progress_meteor)
	{
		progress_hud setValue(level.meteor_counter);
		wait 0.05;
	}

	progress_hud.alpha = 0;
	progress_hud fadeOverTime(1);
	progress_hud delete();
}

progress_mannequins(pos_multi)
{
	level endon("end_game");
	self endon("kill_mannequin_tracking_wrapped");

	progress_hud = progress_hud(pos_multi);
	progress_hud.label = &"MANNEQUINS: ^3";
	progress_hud setValue(28);
	progress_hud.alpha = 1;

	self thread watch_for_kill_trigger("kill_mannequin_tracking", ::hud_delete, progress_hud, 1);

	while (!isDefined(level.mannequin_count))
		wait 0.05;

	while (level.progress_mannequin)
	{
		progress_hud setValue(level.mannequin_count);
		wait 0.05;
	}

	progress_hud.alpha = 0;
	progress_hud fadeOverTime(1);
	progress_hud delete();
}

progress_population(pos_multi)
{
	level endon("end_game");

	progress_hud = progress_hud(pos_multi);
	progress_hud.label = &"POPULATION: ^3";
	progress_hud setValue(100);
	progress_hud.alpha = 1;

	while (!isDefined(level.population_count))
		wait 0.05;

	while (level.progress_population)
	{
		progress_hud setValue(level.population_count);
		wait 0.05;
	}

	progress_hud.alpha = 0;
	progress_hud fadeOverTime(1);
	progress_hud delete();
}

progress_plates(pos_multi)
{
	level endon("end_game");

	progress_hud = progress_hud(pos_multi);
	progress_hud.label = &"NUMBER PLATES: ^3";
	progress_hud setValue(0);
	progress_hud.alpha = 1;

	while (!isDefined(level.snd115count))
		wait 0.05;

	while (level.progress_plates)
	{
		progress_hud setValue(level.snd115count);
		wait 0.05;
	}

	progress_hud.alpha = 0;
	progress_hud fadeOverTime(1);
	progress_hud delete();
}

progress_radios(pos_multi)
{
	level endon("end_game");

	progress_hud = progress_hud(pos_multi);
	progress_hud.label = &"RADIOS: ^3";
	progress_hud setValue(0);
	progress_hud.alpha = 1;

	while (!isDefined(level.found_ee_radio_count))
		wait 0.05;

	while (level.progress_radios)
	{
		progress_hud setValue(level.found_ee_radio_count);
		wait 0.05;
	}

	progress_hud.alpha = 0;
	progress_hud fadeOverTime(1);
	progress_hud delete();
}

give_up_show_mannequins()
{
	level endon("end_game");

	while (true)
	{
		level waittill("say", text, player);

		if (text == "fuckit")
		{
			iPrintLn("^1" + player.name + " ^7has given up");
			allert("mannequin");
			level notify("unveil_mannequins");
		}
		break;
	}
}

mannequinn_debugger()
{
	level endon("end_game");

	level waittill("unveil_mannequins");

	if (is_true(self.is_broken))
		return;

    hud_elem = newhudelem();
    hud_elem.x = self.origin[0];
    hud_elem.y = self.origin[1];
    hud_elem.z = self.origin[2] + 45;
    hud_elem.alpha = 1;
    hud_elem.archived = 1;
    hud_elem setshader("waypoint_revive", 7, 7);
    hud_elem setwaypoint(1);
    hud_elem.hidewheninmenu = 1;
    hud_elem.immunetodemogamehudsettings = 1;

	self waittill("broken");
	hud_elem.alpha = 0;
	hud_elem destroy();
}

debug_controller()
{
	level endon("end_game");

	if (!is_debug())
		return;

	while (level.mannequin_count > 5)
		wait 0.05;

	level notify("unveil_mannequins");
}

show_wr(index)
{
	level endon("end_game");

	if (!leaderboards_enabled())
		return;

	// debug_print(self.code + " trying to show WR");

	waittime = index / 10;
	wait waittime;

	posy = 40 + (40 * level.printed_wrs);
	str_playersize = "" + get_players().size;

	time = level.B2_SONG_LEADERBOARD[self.code][str_playersize]["wr"];
	players = level.B2_SONG_LEADERBOARD[self.code][str_playersize]["player"];

	// debug_print("show_wr(" + index + "): are defined time='" + isDefined(time) + "' players='" + isDefined(players) + "' playerindex-isstring='" + (isDefined(str_playersize) && isstring(str_playersize)) + "'");
	// debug_print("show_wr(" + index + "): time='" + time + "' players='" + players + "'");

	if (!isDefined(time) || !isDefined(players))
		debug_print("show_wr(): are defined: time=" + isDefined(time) + " players=" + players);

	wrhud = createserverfontstring("big", 1.7);
	wrhud setPoint("TOPLEFT", "TOPLEFT", -40, posy);
	wrhud.color = (1, 1, 1);
	wrhud.alpha = 0;
	wrhud setText("WR " + get_song_title(self.code) + ": ^1" + timer_text(time));

	wrbyhud = createserverfontstring("objective", 1.2);
	wrbyhud setPoint("TOPLEFT", "TOPLEFT", -40, posy + 19);
	wrbyhud.color = (1, 1, 1);
	wrbyhud.alpha = 0;
	wrbyhud setText("BY: ^1" + players);

	level.printed_wrs++;

	wrhud FadeOverTime(1);
	wrbyhud FadeOverTime(1);
	wrhud.alpha = 1;
	wrbyhud.alpha = 1;

	wait 7 - waittime;

	wrhud FadeOverTime(1);
	wrbyhud FadeOverTime(1);
	wrhud.alpha = 0;
	wrbyhud.alpha = 0;
	wait 1;
	wrhud destroy();
	wrbyhud destroy();
}

// Borrowed from https://github.com/Jbleezy/BO2-Reimagined
translate_zone(zone)
{
	if (!isDefined(zone))
		return "";

	name = zone;

	if (level.script == "zm_transit" || level.script == "zm_transit_dr")
	{
		if (zone == "zone_pri")
			name = "Bus Depot";
		else if (zone == "zone_pri2")
			name = "Bus Depot Hallway";
		else if (zone == "zone_station_ext")
			name = "Outside Bus Depot";
		else if (zone == "zone_trans_2b")
			name = "Fog After Bus Depot";
		else if (zone == "zone_trans_2")
			name = "Tunnel Entrance";
		else if (zone == "zone_amb_tunnel")
			name = "Tunnel";
		else if (zone == "zone_trans_3")
			name = "Tunnel Exit";
		else if (zone == "zone_roadside_west")
			name = "Outside Diner";
		else if (zone == "zone_gas")
			name = "Gas Station";
		else if (zone == "zone_roadside_east")
			name = "Outside Garage";
		else if (zone == "zone_trans_diner")
			name = "Fog Outside Diner";
		else if (zone == "zone_trans_diner2")
			name = "Fog Outside Garage";
		else if (zone == "zone_gar")
			name = "Garage";
		else if (zone == "zone_din")
			name = "Diner";
		else if (zone == "zone_diner_roof")
			name = "Diner Roof";
		else if (zone == "zone_trans_4")
			name = "Fog After Diner";
		else if (zone == "zone_amb_forest")
			name = "Forest";
		else if (zone == "zone_trans_10")
			name = "Outside Church";
		else if (zone == "zone_town_church")
			name = "Outside Church To Town";
		else if (zone == "zone_trans_5")
			name = "Fog Before Farm";
		else if (zone == "zone_far")
			name = "Outside Farm";
		else if (zone == "zone_far_ext")
			name = "Farm";
		else if (zone == "zone_brn")
			name = "Barn";
		else if (zone == "zone_farm_house")
			name = "Farmhouse";
		else if (zone == "zone_trans_6")
			name = "Fog After Farm";
		else if (zone == "zone_amb_cornfield")
			name = "Cornfield";
		else if (zone == "zone_cornfield_prototype")
			name = "Prototype";
		else if (zone == "zone_trans_7")
			name = "Upper Fog Before Power Station";
		else if (zone == "zone_trans_pow_ext1")
			name = "Fog Before Power Station";
		else if (zone == "zone_pow")
			name = "Outside Power Station";
		else if (zone == "zone_prr")
			name = "Power Station";
		else if (zone == "zone_pcr")
			name = "Power Station Control Room";
		else if (zone == "zone_pow_warehouse")
			name = "Warehouse";
		else if (zone == "zone_trans_8")
			name = "Fog After Power Station";
		else if (zone == "zone_amb_power2town")
			name = "Cabin";
		else if (zone == "zone_trans_9")
			name = "Fog Before Town";
		else if (zone == "zone_town_north")
			name = "North Town";
		else if (zone == "zone_tow")
			name = "Center Town";
		else if (zone == "zone_town_east")
			name = "East Town";
		else if (zone == "zone_town_west")
			name = "West Town";
		else if (zone == "zone_town_south")
			name = "South Town";
		else if (zone == "zone_bar")
			name = "Bar";
		else if (zone == "zone_town_barber")
			name = "Bookstore";
		else if (zone == "zone_ban")
			name = "Bank";
		else if (zone == "zone_ban_vault")
			name = "Bank Vault";
		else if (zone == "zone_tbu")
			name = "Below Bank";
		else if (zone == "zone_trans_11")
			name = "Fog After Town";
		else if (zone == "zone_amb_bridge")
			name = "Bridge";
		else if (zone == "zone_trans_1")
			name = "Fog Before Bus Depot";
	}
	else if (level.script == "zm_nuked")
	{
		if (zone == "culdesac_yellow_zone")
			name = "Yellow House Cul-de-sac";
		else if (zone == "culdesac_green_zone")
			name = "Green House Cul-de-sac";
		else if (zone == "truck_zone")
			name = "Truck";
		else if (zone == "openhouse1_f1_zone")
			name = "Green House Downstairs";
		else if (zone == "openhouse1_f2_zone")
			name = "Green House Upstairs";
		else if (zone == "openhouse1_backyard_zone")
			name = "Green House Backyard";
		else if (zone == "openhouse2_f1_zone")
			name = "Yellow House Downstairs";
		else if (zone == "openhouse2_f2_zone")
			name = "Yellow House Upstairs";
		else if (zone == "openhouse2_backyard_zone")
			name = "Yellow House Backyard";
		else if (zone == "ammo_door_zone")
			name = "Yellow House Backyard Door";
	}
	else if (level.script == "zm_highrise")
	{
		if (zone == "zone_green_start")
			name = "Green Highrise Level 3b";
		else if (zone == "zone_green_escape_pod")
			name = "Escape Pod";
		else if (zone == "zone_green_escape_pod_ground")
			name = "Escape Pod Shaft";
		else if (zone == "zone_green_level1")
			name = "Green Highrise Level 3a";
		else if (zone == "zone_green_level2a")
			name = "Green Highrise Level 2a";
		else if (zone == "zone_green_level2b")
			name = "Green Highrise Level 2b";
		else if (zone == "zone_green_level3a")
			name = "Green Highrise Restaurant";
		else if (zone == "zone_green_level3b")
			name = "Green Highrise Level 1a";
		else if (zone == "zone_green_level3c")
			name = "Green Highrise Level 1b";
		else if (zone == "zone_green_level3d")
			name = "Green Highrise Behind Restaurant";
		else if (zone == "zone_orange_level1")
			name = "Upper Orange Highrise Level 2";
		else if (zone == "zone_orange_level2")
			name = "Upper Orange Highrise Level 1";
		else if (zone == "zone_orange_elevator_shaft_top")
			name = "Elevator Shaft Level 3";
		else if (zone == "zone_orange_elevator_shaft_middle_1")
			name = "Elevator Shaft Level 2";
		else if (zone == "zone_orange_elevator_shaft_middle_2")
			name = "Elevator Shaft Level 1";
		else if (zone == "zone_orange_elevator_shaft_bottom")
			name = "Elevator Shaft Bottom";
		else if (zone == "zone_orange_level3a")
			name = "Lower Orange Highrise Level 1a";
		else if (zone == "zone_orange_level3b")
			name = "Lower Orange Highrise Level 1b";
		else if (zone == "zone_blue_level5")
			name = "Lower Blue Highrise Level 1";
		else if (zone == "zone_blue_level4a")
			name = "Lower Blue Highrise Level 2a";
		else if (zone == "zone_blue_level4b")
			name = "Lower Blue Highrise Level 2b";
		else if (zone == "zone_blue_level4c")
			name = "Lower Blue Highrise Level 2c";
		else if (zone == "zone_blue_level2a")
			name = "Upper Blue Highrise Level 1a";
		else if (zone == "zone_blue_level2b")
			name = "Upper Blue Highrise Level 1b";
		else if (zone == "zone_blue_level2c")
			name = "Upper Blue Highrise Level 1c";
		else if (zone == "zone_blue_level2d")
			name = "Upper Blue Highrise Level 1d";
		else if (zone == "zone_blue_level1a")
			name = "Upper Blue Highrise Level 2a";
		else if (zone == "zone_blue_level1b")
			name = "Upper Blue Highrise Level 2b";
		else if (zone == "zone_blue_level1c")
			name = "Upper Blue Highrise Level 2c";
	}
	else if (level.script == "zm_prison")
	{
		if (zone == "zone_start")
			name = "D-Block";
		else if (zone == "zone_library")
			name = "Library";
		else if (zone == "zone_cellblock_west")
			name = "Cell Block 2nd Floor";
		else if (zone == "zone_cellblock_west_gondola")
			name = "Cell Block 3rd Floor";
		else if (zone == "zone_cellblock_west_gondola_dock")
			name = "Cell Block Gondola";
		else if (zone == "zone_cellblock_west_barber")
			name = "Michigan Avenue";
		else if (zone == "zone_cellblock_east")
			name = "Times Square";
		else if (zone == "zone_cafeteria")
			name = "Cafeteria";
		else if (zone == "zone_cafeteria_end")
			name = "Cafeteria End";
		else if (zone == "zone_infirmary")
			name = "Infirmary 1";
		else if (zone == "zone_infirmary_roof")
			name = "Infirmary 2";
		else if (zone == "zone_roof_infirmary")
			name = "Roof 1";
		else if (zone == "zone_roof")
			name = "Roof 2";
		else if (zone == "zone_cellblock_west_warden")
			name = "Sally Port";
		else if (zone == "zone_warden_office")
			name = "Warden's Office";
		else if (zone == "cellblock_shower")
			name = "Showers";
		else if (zone == "zone_citadel_shower")
			name = "Citadel To Showers";
		else if (zone == "zone_citadel")
			name = "Citadel";
		else if (zone == "zone_citadel_warden")
			name = "Citadel To Warden's Office";
		else if (zone == "zone_citadel_stairs")
			name = "Citadel Tunnels";
		else if (zone == "zone_citadel_basement")
			name = "Citadel Basement";
		else if (zone == "zone_citadel_basement_building")
			name = "China Alley";
		else if (zone == "zone_studio")
			name = "Building 64";
		else if (zone == "zone_dock")
			name = "Docks";
		else if (zone == "zone_dock_puzzle")
			name = "Docks Gates";
		else if (zone == "zone_dock_gondola")
			name = "Upper Docks";
		else if (zone == "zone_golden_gate_bridge")
			name = "Golden Gate Bridge";
		else if (zone == "zone_gondola_ride")
			name = "Gondola";
	}
	else if (level.script == "zm_buried")
	{
		if (zone == "zone_start")
			name = "Processing";
		else if (zone == "zone_start_lower")
			name = "Lower Processing";
		else if (zone == "zone_tunnels_center")
			name = "Center Tunnels";
		else if (zone == "zone_tunnels_north")
			name = "Courthouse Tunnels 2";
		else if (zone == "zone_tunnels_north2")
			name = "Courthouse Tunnels 1";
		else if (zone == "zone_tunnels_south")
			name = "Saloon Tunnels 3";
		else if (zone == "zone_tunnels_south2")
			name = "Saloon Tunnels 2";
		else if (zone == "zone_tunnels_south3")
			name = "Saloon Tunnels 1";
		else if (zone == "zone_street_lightwest")
			name = "Outside General Store & Bank";
		else if (zone == "zone_street_lightwest_alley")
			name = "Outside General Store & Bank Alley";
		else if (zone == "zone_morgue_upstairs")
			name = "Morgue";
		else if (zone == "zone_underground_jail")
			name = "Jail Downstairs";
		else if (zone == "zone_underground_jail2")
			name = "Jail Upstairs";
		else if (zone == "zone_general_store")
			name = "General Store";
		else if (zone == "zone_stables")
			name = "Stables";
		else if (zone == "zone_street_darkwest")
			name = "Outside Gunsmith";
		else if (zone == "zone_street_darkwest_nook")
			name = "Outside Gunsmith Nook";
		else if (zone == "zone_gun_store")
			name = "Gunsmith";
		else if (zone == "zone_bank")
			name = "Bank";
		else if (zone == "zone_tunnel_gun2stables")
			name = "Stables To Gunsmith Tunnel 2";
		else if (zone == "zone_tunnel_gun2stables2")
			name = "Stables To Gunsmith Tunnel";
		else if (zone == "zone_street_darkeast")
			name = "Outside Saloon & Toy Store";
		else if (zone == "zone_street_darkeast_nook")
			name = "Outside Saloon & Toy Store Nook";
		else if (zone == "zone_underground_bar")
			name = "Saloon";
		else if (zone == "zone_tunnel_gun2saloon")
			name = "Saloon To Gunsmith Tunnel";
		else if (zone == "zone_toy_store")
			name = "Toy Store Downstairs";
		else if (zone == "zone_toy_store_floor2")
			name = "Toy Store Upstairs";
		else if (zone == "zone_toy_store_tunnel")
			name = "Toy Store Tunnel";
		else if (zone == "zone_candy_store")
			name = "Candy Store Downstairs";
		else if (zone == "zone_candy_store_floor2")
			name = "Candy Store Upstairs";
		else if (zone == "zone_street_lighteast")
			name = "Outside Courthouse & Candy Store";
		else if (zone == "zone_underground_courthouse")
			name = "Courthouse Downstairs";
		else if (zone == "zone_underground_courthouse2")
			name = "Courthouse Upstairs";
		else if (zone == "zone_street_fountain")
			name = "Fountain";
		else if (zone == "zone_church_graveyard")
			name = "Graveyard";
		else if (zone == "zone_church_main")
			name = "Church Downstairs";
		else if (zone == "zone_church_upstairs")
			name = "Church Upstairs";
		else if (zone == "zone_mansion_lawn")
			name = "Mansion Lawn";
		else if (zone == "zone_mansion")
			name = "Mansion";
		else if (zone == "zone_mansion_backyard")
			name = "Mansion Backyard";
		else if (zone == "zone_maze")
			name = "Maze";
		else if (zone == "zone_maze_staircase")
			name = "Maze Staircase";
	}
	else if (level.script == "zm_tomb")
	{
		if (isDefined(self.teleporting) && self.teleporting)
			return "";

		if (zone == "zone_start")
			name = "Lower Laboratory";
		else if (zone == "zone_start_a")
			name = "Upper Laboratory";
		else if (zone == "zone_start_b")
			name = "Generator 1";
		else if (zone == "zone_bunker_1a")
			name = "Generator 3 Bunker 1";
		else if (zone == "zone_fire_stairs")
			name = "Fire Tunnel";
		else if (zone == "zone_bunker_1")
			name = "Generator 3 Bunker 2";
		else if (zone == "zone_bunker_3a")
			name = "Generator 3";
		else if (zone == "zone_bunker_3b")
			name = "Generator 3 Bunker 3";
		else if (zone == "zone_bunker_2a")
			name = "Generator 2 Bunker 1";
		else if (zone == "zone_bunker_2")
			name = "Generator 2 Bunker 2";
		else if (zone == "zone_bunker_4a")
			name = "Generator 2";
		else if (zone == "zone_bunker_4b")
			name = "Generator 2 Bunker 3";
		else if (zone == "zone_bunker_4c")
			name = "Tank Station";
		else if (zone == "zone_bunker_4d")
			name = "Above Tank Station";
		else if (zone == "zone_bunker_tank_c")
			name = "Generator 2 Tank Route 1";
		else if (zone == "zone_bunker_tank_c1")
			name = "Generator 2 Tank Route 2";
		else if (zone == "zone_bunker_4e")
			name = "Generator 2 Tank Route 3";
		else if (zone == "zone_bunker_tank_d")
			name = "Generator 2 Tank Route 4";
		else if (zone == "zone_bunker_tank_d1")
			name = "Generator 2 Tank Route 5";
		else if (zone == "zone_bunker_4f")
			name = "zone_bunker_4f";
		else if (zone == "zone_bunker_5a")
			name = "Workshop Downstairs";
		else if (zone == "zone_bunker_5b")
			name = "Workshop Upstairs";
		else if (zone == "zone_nml_2a")
			name = "No Man's Land Walkway";
		else if (zone == "zone_nml_2")
			name = "No Man's Land Entrance";
		else if (zone == "zone_bunker_tank_e")
			name = "Generator 5 Tank Route 1";
		else if (zone == "zone_bunker_tank_e1")
			name = "Generator 5 Tank Route 2";
		else if (zone == "zone_bunker_tank_e2")
			name = "zone_bunker_tank_e2";
		else if (zone == "zone_bunker_tank_f")
			name = "Generator 5 Tank Route 3";
		else if (zone == "zone_nml_1")
			name = "Generator 5 Tank Route 4";
		else if (zone == "zone_nml_4")
			name = "Generator 5 Tank Route 5";
		else if (zone == "zone_nml_0")
			name = "Generator 5 Left Footstep";
		else if (zone == "zone_nml_5")
			name = "Generator 5 Right Footstep Walkway";
		else if (zone == "zone_nml_farm")
			name = "Generator 5";
		else if (zone == "zone_nml_celllar")
			name = "Generator 5 Cellar";
		else if (zone == "zone_bolt_stairs")
			name = "Lightning Tunnel";
		else if (zone == "zone_nml_3")
			name = "No Man's Land 1st Right Footstep";
		else if (zone == "zone_nml_2b")
			name = "No Man's Land Stairs";
		else if (zone == "zone_nml_6")
			name = "No Man's Land Left Footstep";
		else if (zone == "zone_nml_8")
			name = "No Man's Land 2nd Right Footstep";
		else if (zone == "zone_nml_10a")
			name = "Generator 4 Tank Route 1";
		else if (zone == "zone_nml_10")
			name = "Generator 4 Tank Route 2";
		else if (zone == "zone_nml_7")
			name = "Generator 4 Tank Route 3";
		else if (zone == "zone_bunker_tank_a")
			name = "Generator 4 Tank Route 4";
		else if (zone == "zone_bunker_tank_a1")
			name = "Generator 4 Tank Route 5";
		else if (zone == "zone_bunker_tank_a2")
			name = "zone_bunker_tank_a2";
		else if (zone == "zone_bunker_tank_b")
			name = "Generator 4 Tank Route 6";
		else if (zone == "zone_nml_9")
			name = "Generator 4 Left Footstep";
		else if (zone == "zone_air_stairs")
			name = "Wind Tunnel";
		else if (zone == "zone_nml_11")
			name = "Generator 4";
		else if (zone == "zone_nml_12")
			name = "Generator 4 Right Footstep";
		else if (zone == "zone_nml_16")
			name = "Excavation Site Front Path";
		else if (zone == "zone_nml_17")
			name = "Excavation Site Back Path";
		else if (zone == "zone_nml_18")
			name = "Excavation Site Level 3";
		else if (zone == "zone_nml_19")
			name = "Excavation Site Level 2";
		else if (zone == "ug_bottom_zone")
			name = "Excavation Site Level 1";
		else if (zone == "zone_nml_13")
			name = "Generator 5 To Generator 6 Path";
		else if (zone == "zone_nml_14")
			name = "Generator 4 To Generator 6 Path";
		else if (zone == "zone_nml_15")
			name = "Generator 6 Entrance";
		else if (zone == "zone_village_0")
			name = "Generator 6 Left Footstep";
		else if (zone == "zone_village_5")
			name = "Generator 6 Tank Route 1";
		else if (zone == "zone_village_5a")
			name = "Generator 6 Tank Route 2";
		else if (zone == "zone_village_5b")
			name = "Generator 6 Tank Route 3";
		else if (zone == "zone_village_1")
			name = "Generator 6 Tank Route 4";
		else if (zone == "zone_village_4b")
			name = "Generator 6 Tank Route 5";
		else if (zone == "zone_village_4a")
			name = "Generator 6 Tank Route 6";
		else if (zone == "zone_village_4")
			name = "Generator 6 Tank Route 7";
		else if (zone == "zone_village_2")
			name = "Church";
		else if (zone == "zone_village_3")
			name = "Generator 6 Right Footstep";
		else if (zone == "zone_village_3a")
			name = "Generator 6";
		else if (zone == "zone_ice_stairs")
			name = "Ice Tunnel";
		else if (zone == "zone_bunker_6")
			name = "Above Generator 3 Bunker";
		else if (zone == "zone_nml_20")
			name = "Above No Man's Land";
		else if (zone == "zone_village_6")
			name = "Behind Church";
		else if (zone == "zone_chamber_0")
			name = "The Crazy Place Lightning Chamber";
		else if (zone == "zone_chamber_1")
			name = "The Crazy Place Lightning & Ice";
		else if (zone == "zone_chamber_2")
			name = "The Crazy Place Ice Chamber";
		else if (zone == "zone_chamber_3")
			name = "The Crazy Place Fire & Lightning";
		else if (zone == "zone_chamber_4")
			name = "The Crazy Place Center";
		else if (zone == "zone_chamber_5")
			name = "The Crazy Place Ice & Wind";
		else if (zone == "zone_chamber_6")
			name = "The Crazy Place Fire Chamber";
		else if (zone == "zone_chamber_7")
			name = "The Crazy Place Wind & Fire";
		else if (zone == "zone_chamber_8")
			name = "The Crazy Place Wind Chamber";
		else if (zone == "zone_robot_head")
			name = "Robot's Head";
	}

	return name;
}

get_my_coordinates()
{
	level endon("end_game");
	self endon("disconnect");

	player_thread_black_screen_waiter();

    self.coordinates_x_hud = createfontstring("objective" , 1.1);
	self.coordinates_x_hud setpoint("CENTER", "BOTTOM", -40, 10);
	self.coordinates_x_hud.alpha = 0.66;
	self.coordinates_x_hud.color = (1, 1, 1);
	self.coordinates_x_hud.hidewheninmenu = 0;

    self.coordinates_y_hud = createfontstring("objective" , 1.1);
	self.coordinates_y_hud setpoint("CENTER", "BOTTOM", 0, 10);
	self.coordinates_y_hud.alpha = 0.66;
	self.coordinates_y_hud.color = (1, 1, 1);
	self.coordinates_y_hud.hidewheninmenu = 0;

    self.coordinates_z_hud = createfontstring("objective" , 1.1);
	self.coordinates_z_hud setpoint("CENTER", "BOTTOM", 40, 10);
	self.coordinates_z_hud.alpha = 0.66;
	self.coordinates_z_hud.color = (1, 1, 1);
	self.coordinates_z_hud.hidewheninmenu = 0;

	while (true)
	{
		self.coordinates_x_hud setValue(naive_round(self.origin[0]));
		self.coordinates_y_hud setValue(naive_round(self.origin[1]));
		self.coordinates_z_hud setValue(naive_round(self.origin[2]));

		wait 0.05;
	}
}

// Yes it's not super accurate, it doesn't have to be
naive_round(floating_point)
{
	floating_point = int(floating_point * 1000);
	return floating_point / 1000;
}

mannequin_integrity()
{
	level endon("end_game");

	wait 0.1;

	detections = 0;
	foreach(mannequin_zone in self.mannequins)
		detections += mannequin_zone.size;

	debug_print("mannequin_integrity(): detected count: " + detections + " current dvar: " + getDvar("song_attempts"));

	/* Not sure why it should be 29 in this check, but it works so */
	if (detections < 29)
	{
		if (!is_debug())
			level notify("kill_mannequin_tracking");
		else
			debug_print("mannequin_integrity(): sending 'kill_mannequin_tracking' trigger");

		iPrintLn("^1WARNING: ^7Mannequin number incorrect.");
		iPrintLn("Restart within 5 seconds to not lose an attempt");

		if (getDvar("song_attempts") != "")
		{
			num = getDvarInt("song_attempts");
			setDvar("song_attempts", num - 1);
			wait 5;
			setDvar("song_attempts", num + 1);
		}
		else
		{
			setDvar("song_attempts", -1);
			wait 5;
			setDvar("song_attempts", 0);
		}
	}
}

/*
sndmusegg3_counter_override()
{
    if (level.mannequin_count <= 0)
        return;

    level.mannequin_count--;
	debug_print("mannequin callback: " + level.mannequin_count);

    if (level.mannequin_count <= 0)
    {
        while (isdefined(level.music_override) && level.music_override)
            wait 5;

        level thread sndmuseggplay(spawn("script_origin", (0, 0, 0)), "zmb_nuked_song_3", 80);
    }
}

sndmuseggplay(ent, alias, time)
{
    level.music_override = 1;
    wait 1;
    ent playsound(alias);
    level thread sndeggmusicwait(time);
    level waittill_either("end_game", "sndSongDone");
    ent stopsounds();
    wait 0.05;
    ent delete();
    level.music_override = 0;
}

sndeggmusicwait(time)
{
    level endon("end_game");
    wait(time);
    level notify("sndSongDone");
}
*/

pull_character_preset(character_name)
{
	preset = array();
	preset["model"] = undefined;
	preset["viewmodel"] = undefined;
	preset["favourite_wall_weapons"] = undefined;
	preset["whos_who_shader"] = undefined;
	preset["talks_in_danger"] = undefined;
	preset["rich_sq_player"] = undefined;
	preset["character_name"] = undefined;
	preset["has_weasel"] = undefined;
	preset["voice"] = undefined;
	preset["is_female"] = 0;

	if (is_tranzit() || is_die_rise() || is_buried())
	{
		switch(toLower(character_name))
		{
			case "russman":
				preset["index"] = 0;
				preset["model"] = "c_zom_player_oldman_fb";
				preset["viewmodel"] = "c_zom_oldman_viewhands";
				preset["favourite_wall_weapons"] = array("frag_grenade_zm", "claymore_zm");
				preset["whos_who_shader"] = "c_zom_player_oldman_dlc1_fb";
				preset["character_name"] = "Russman";

				if (is_die_rise())
					preset["model"] = "c_zom_player_oldman_dlc1_fb";

				break;

			case "stuhlinger":
				preset["index"] = 1;
				preset["model"] = "c_zom_player_reporter_fb";
				preset["viewmodel"] = "c_zom_reporter_viewhands";
				preset["favourite_wall_weapons"] = array("beretta93r_zm");
				preset["whos_who_shader"] = "c_zom_player_reporter_dlc1_fb";
				preset["talks_in_danger"] = 1;
				preset["rich_sq_player"] = 1;
				preset["character_name"] = "Stuhlinger";

				if (is_die_rise())
					preset["model"] = "c_zom_player_reporter_dlc1_fb";

				break;

			case "misty":
				preset["index"] = 2;
				preset["model"] = "c_zom_player_farmgirl_fb";
				preset["viewmodel"] = "c_zom_farmgirl_viewhands";
				preset["is_female"] = 1;
				preset["favourite_wall_weapons"] = array("rottweil72_zm", "870mcs_zm");
				preset["whos_who_shader"] = "c_zom_player_farmgirl_dlc1_fb";
				preset["character_name"] = "Misty";

				if (is_die_rise())
					preset["model"] = "c_zom_player_farmgirl_dlc1_fb";

				break;

			case "marlton":
				preset["index"] = 3;
				preset["model"] = "c_zom_player_engineer_fb";
				preset["viewmodel"] = "c_zom_engineer_viewhands";
				preset["favourite_wall_weapons"] = array("m14_zm", "m16_zm");
				preset["whos_who_shader"] = "c_zom_player_engineer_dlc1_fb";
				preset["character_name"] = "Marlton";

				if (is_die_rise())
					preset["model"] = "c_zom_player_engineer_dlc1_fb";
			
				break;
		}
	}

	else if (is_town() || is_farm() || is_depot() || is_nuketown())
	{
		switch(toLower(character_name))
		{
			case "cia":
				preset["index"] = 0;
				preset["model"] = "c_zom_player_cia_fb";
				preset["viewmodel"] = "c_zom_suit_viewhands";
				break;
			case "cdc":
				preset["index"] = 1;
				preset["model"] = "c_zom_player_cdc_fb";
				preset["viewmodel"] = "c_zom_hazmat_viewhands";

				if (is_nuketown())
					preset["viewmodel"] = "c_zom_hazmat_viewhands_light";

				break;
		}
	}

	else if (is_mob())
	{
		switch(toLower(character_name))
		{
			case "finn":
				preset["index"] = 0;
				preset["model"] = "c_zom_player_oleary_fb";
				preset["viewmodel"] = "c_zom_oleary_shortsleeve_viewhands";
				preset["favourite_wall_weapons"] = array("judge_zm");
				preset["character_name"] = "Finn";
				break;

			case "sal":
				preset["index"] = 1;
				preset["model"] = "c_zom_player_deluca_fb";
				preset["viewmodel"] = "c_zom_deluca_longsleeve_viewhands";
				preset["favourite_wall_weapons"] = array("thompson_zm");
				preset["character_name"] = "Sal";
				break;

			case "billy":
				preset["index"] = 2;
				preset["model"] = "c_zom_player_handsome_fb";
				preset["viewmodel"] = "c_zom_handsome_sleeveless_viewhands";
				preset["favourite_wall_weapons"] = array("blundergat_zm");
				preset["character_name"] = "Billy";
				break;

			case "arlington":
			case "weasel":
				preset["index"] = 3;
				preset["model"] = "c_zom_player_arlington_fb";
				preset["viewmodel"] = "c_zom_arlington_coat_viewhands";
				preset["favourite_wall_weapons"] = array("ray_gun_zm");
				preset["character_name"] = "Arlington";
				preset["has_weasel"] = 1;
				break;
		}
	}

	else if (is_origins())
	{
		switch(toLower(character_name))
		{
			case "dempsey":
				preset["index"] = 0;
				preset["model"] = "c_zom_tomb_dempsey_fb";
				preset["viewmodel"] = "c_zom_dempsey_viewhands";
				preset["character_name"] = "Dempsey";
				break;

			case "nikolai":
				preset["index"] = 1;
				preset["model"] = "c_zom_tomb_nikolai_fb";
				preset["viewmodel"] = "c_zom_nikolai_viewhands";
				preset["character_name"] = "Nikolai";
				preset["voice"] = "russian";
				break;

			case "richtofen":
				preset["index"] = 2;
				preset["model"] = "c_zom_tomb_richtofen_fb";
				preset["viewmodel"] = "c_zom_richtofen_viewhands";
				preset["character_name"] = "Richtofen";
				break;

			case "takeo":
				preset["index"] = 3;
				preset["model"] = "c_zom_tomb_takeo_fb";
				preset["viewmodel"] = "c_zom_takeo_viewhands";
				preset["character_name"] = "Takeo";
				break;
		}
	}

	return preset;
}

set_characters()
{
	level endon("end_game");
	self endon("disconnect");

	player_id = self.clientid;
	while (player_id > 3)
		player_id -= 4;

	translation_layer = array("white", "blue", "yellow", "green");

	if (is_tranzit() || is_die_rise() || is_buried())
		map = "tranzit";
	else if (is_town() || is_farm() || is_depot() || is_nuketown())
		map = "town";
	else if (is_mob())
		map = "mob";
	else if (is_origins())
		map = "origins";

	translation_index = translation_layer[player_id];
	if (!isDefined(level.B2_CHARACTERS[map][translation_index]))
		return;
	character = level.B2_CHARACTERS[map][translation_index];

	prop = pull_character_preset(character);

	self setmodel(prop["model"]);
	self setviewmodel(prop["viewmodel"]);
	self set_player_is_female(prop["is_female"]);
	self.characterindex = prop["index"];

	if (isDefined(prop["favourite_wall_weapons"]))
		self.favorite_wall_weapons_list = prop["favourite_wall_weapons"];
	if (isDefined(prop["whos_who_shader"]))
		self.whos_who_shader = prop["whos_who_shader"];
	if (isDefined(prop["talks_in_danger"]))
		self.talks_in_danger = prop["talks_in_danger"];
	if (isDefined(prop["rich_sq_player"]))
		level.rich_sq_player = self;
	if (isDefined(prop["character_name"]))
		self.character_name = prop["character_name"];
	if (isDefined(prop["has_weasel"]))
		level.has_weasel = prop["has_weasel"];
	if (isDefined(prop["voice"]))
		self.voice = prop["voice"];
}

player_rig_fridge(weapon)
{
	self maps\mp\zombies\_zm_stats::clear_stored_weapondata();

	wpn = array();
	wpn["clip"] = weaponClipSize(weapon);
	wpn["stock"] = weaponMaxAmmo(weapon);
	wpn["dw_name"] = weapondualwieldweaponname(weapon);
	wpn["alt_name"] = weaponaltweaponname(weapon);
	wpn["lh_clip"] = weaponClipSize(wpn["dw_name"]);
	wpn["alt_clip"] = weaponClipSize(wpn["alt_name"]);
	wpn["alt_stock"] = weaponMaxAmmo(wpn["alt_name"]);

	self setdstat("PlayerStatsByMap", "zm_transit", "weaponLocker", "name", weapon);
	self setdstat("PlayerStatsByMap", "zm_transit", "weaponLocker", "clip", wpn["clip"]);
	self setdstat("PlayerStatsByMap", "zm_transit", "weaponLocker", "stock", wpn["stock"]);

	if (isDefined(wpn["alt_name"]) && wpn["alt_name"] != "")
	{
		self setdstat("PlayerStatsByMap", "zm_transit", "weaponLocker", "alt_name", wpn["alt_name"]);
		self setdstat("PlayerStatsByMap", "zm_transit", "weaponLocker", "alt_clip", wpn["alt_clip"]);
		self setdstat("PlayerStatsByMap", "zm_transit", "weaponLocker", "alt_stock", wpn["alt_stock"]);
	}

	if (isDefined(wpn["dw_name"]) && wpn["dw_name"] != "")
	{
		self setdstat("PlayerStatsByMap", "zm_transit", "weaponLocker", "dw_name", wpn["dw_name"]);
		self setdstat("PlayerStatsByMap", "zm_transit", "weaponLocker", "lh_clip", wpn["lh_clip"]);
	}
}
