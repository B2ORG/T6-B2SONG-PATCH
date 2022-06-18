#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/zm_transit;
#include maps/mp/zm_nuked_amb;
#include maps/mp/zm_highrise_amb;
#include maps/mp/zm_alcatraz_amb;
#include maps/mp/zm_alcatraz_sq_nixie;
#include maps/mp/zm_buried_amb;
#include maps/mp/zm_tomb_amb;
#include maps/mp/zm_tomb_ee_side;

init()
{
    level thread OnPlayerConnect();
    level.TESTING = false;
}

OnPlayerConnect()
{
    level thread OnPlayerJoined();

	level waittill("initial_players_connected");
    iPrintLn("Joke v2");
    SetDvars();

    flag_wait("initial_blackscreen_passed");
    level thread TimerMain();
    level thread GenerateSongSplit();
    level thread SongWatcher();
    level thread PapSplits();

    if (level.TESTING)
    {
        level thread DisplayBlocker();

        if (level.script == "zm_nuked")
            level thread MannequinCounter();
    }
}

OnPlayerJoined()
{
    for (;;)
    {
	    level waittill("connecting", player );

        if (level.TESTING)
            player thread ZoneHud();
    }
}

SetDvars()
{
    // Console values according to Plutonium
    setdvar("player_strafespeedscale", 1);
    setdvar("player_backspeedscale", 0.85);
}

TimerMain()
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

GenerateSongSplit()
{
    level.playing_songs = 0;
    songs = GetMapSongs();

    foreach(song in songs)
        level thread SongSplit(song.title, song.trigger);
}

SongSplit(title, trigger)
{
    self endon("disconnect");
    level endon("end_game");

    // y_offset = 125 + (25 * songs);

    split_hud = createserverfontstring("hudsmall" , 1.3);
	split_hud setPoint("TOPRIGHT", "TOPRIGHT", 0, 150);					
	split_hud.alpha = 0;
	split_hud.color = (0.6, 0.8, 1);
	split_hud.hidewheninmenu = 1;

    level waittill (trigger);
    sr_timestamp = GetTimeDetailed(level.songsr_start);
    level.playing_songs += 1;
    y_offset = 125 + (25 * level.playing_songs);
	split_hud setPoint("TOPRIGHT", "TOPRIGHT", 0, y_offset);					
    split_hud setText("" + title + ": " + sr_timestamp);
	split_hud.alpha = 1;
}

GetMapSongs(map)
{
    if (!isdefined(map))
        map = level.script;

    song = array();

    spec_title = GetSpecific(map, "title");
    spec_trigger = GetSpecific(map, "trigger");
    if (spec_title.size != spec_trigger.size)
        return;

    for (i = 0; i < spec_title.size; i++)
    {
        songs = spawnStruct();
        songs.title = spec_title[i];
        songs.trigger = spec_trigger[i];
        song[song.size] = songs;
    }

    return song;
}

GetSpecific(map, type)
{
    if (map == "zm_transit")
    {
        if (type == "title")
            return array("Carrion");
        else if (type == "trigger")
            return array("meteor_activated");
    }
    else if (map == "zm_nuked")
    {
        if (type == "title")
            return array("Samantha's Lullaby", "Coming Home", "Re-Damned");
        else if (type == "trigger")
            return array("meteor_activated", "cominghome_activated", "redamned_activated");
    }
    else if (map == "zm_highrise")
    {
        if (type == "title")
            return array("We All Fall Down");
        else if (type == "trigger")
            return array("meteor_activated");
    }
    else if (map == "zm_prison")
    {
        if (type == "title")
            return array("Where Are We Going", "Rusty Cage");
        else if (type == "trigger")
            return array("meteor_activated", "johnycash_activated");
    }
    else if (map == "zm_buried")
    {
        if (type == "title")
            return array("Always Running");
        else if (type == "trigger")
            return array("meteor_activated");
    }
    else if (map == "zm_tomb")
    {
        if (type == "title")
            return array("Archangel", "Aether", "Shepherd of Fire");
        else if (type == "trigger")
            return array("archengel_activated", "aether_activated", "shepards_activated");
    }
    return array();
}

GetTimeDetailed(start_time)
{
    current_time = int(gettime());
    
    miliseconds = current_time - start_time;
    minutes = 0;
    seconds = 0;

	if( miliseconds > 999 )
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
		miliseconds = "" + miliseconds + "0";

	return "" + minutes + ":" + seconds + "." + miliseconds; 
}

SongWatcher()
{
    switch (level.script)
    {
        case "zm_transit":
        case "zm_highrise":
        case "zm_buried":
            level thread Meteor();
            break;
        case "zm_nuked":
            level thread NuketownWatcher();
            break;
        case "zm_prison":
            level thread Meteor();
            level thread RustyCage();
            break;
        case "zm_tomb":
            level thread OriginsWatcher();
            break;
    }
}

Meteor()
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

NuketownWatcher()
{
    level thread ReDamned();
    level thread Meteor();

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

ReDamned()
{
    level waittill("magic_door_power_up_grabbed");
    if (level.population_count == 15)
    {
        // iPrintLn("redamned_activated");
        level notify ("redamned_activated");
    }
}

RustyCage()
{
    level waittill ("nixie_" + 935);
    // iPrintLn("johnycash_activated");
    level notify ("johnycash_activated");
}

OriginsWatcher()
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

PapSplits()
{

}

ZoneHud()
{
    self endon("disconnect");
    level endon("end_game");

    zone_hud = newClientHudElem(self);
	zone_hud.alignx = "left";
	zone_hud.aligny = "bottom";
	zone_hud.horzalign = "user_left";
	zone_hud.vertalign = "user_bottom";
	zone_hud.x = 8;
	zone_hud.y = -111;
    zone_hud.fontscale = 1.3;
	zone_hud.alpha = 1;
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
            zone_hud.alpha = 0.75;
            wait 1;

            zone_hud fadeovertime(0.2);
            zone_hud.alpha = 0;
            wait 0.2;
        }
        wait 0.05;
    }
}

MannequinCounter()
{
    self endon("disconnect");
    level endon("end_game");

    timer_hud = createserverfontstring("hudsmall" , 1.4);
	timer_hud setPoint("TOPLEFT", "TOPLEFT", 0, 20);					
	timer_hud.alpha = 1;
	timer_hud.color = (1, 0.6, 0.2);
	timer_hud.hidewheninmenu = 1;
    hud_blocker.label = &"Remaining mannequins: ";

    while (True)
    {
	    timer_hud setValue(level.mannequin_count);
        wait 0.05;
    }
}

DisplayBlocker()
{
    self endon("disconnect");
    level endon("end_game");

    hud_blocker = createserverfontstring("hudsmall" , 1.4);
	hud_blocker setPoint("TOPLEFT", "TOPLEFT", 0, 0);					
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
