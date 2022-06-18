#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/animscripts/zm_utility;
#include maps/mp/zm_transit;
#include maps/mp/zm_nuked_amb;
#include maps/mp/zm_highrise_amb;
#include maps/mp/zm_alcatraz_amb;
#include maps/mp/zm_alcatraz_sq_nixie;
#include maps/mp/zm_buried_amb;
#include maps/mp/zm_tomb_amb;
#include maps/mp/zm_tomb_ee_side;
#include maps/mp/gametypes_zm/_globallogic_score;

init()
{
    level thread OnPlayerConnect();
    level.TESTING = false;
}

OnPlayerConnect()
{
    level thread OnPlayerJoined();

	level waittill("initial_players_connected");
    iPrintLn("Joke v1");
    SetDvars();

    flag_wait("initial_blackscreen_passed");
    level thread TimerMain();
    level thread SongSplits();
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
        {
            player thread ZoneHud();
        }
    }
}

SetDvars()
{
    setdvar("player_strafespeedscale", 1);
    setdvar("player_backspeedscale", 0.9);
}

GetTimeDetailed(game_start)
{
    current_time = int(gettime());
    miliseconds = current_time - game_start;

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

    minutes = int( minutes );
    if (minutes == 0)
        minutes = "00";
	else if( minutes < 10 )
		minutes = "0" + minutes; 

	seconds = Int( seconds ); 
	if( seconds < 10 )
		seconds = "0" + seconds; 

	return "" + minutes + ":" + seconds + "." + miliseconds; 
}

TimerMain()
{
    self endon("disconnect");
    level endon("end_game");

    timer_hud = createserverfontstring("hudsmall" , 1.6);
	timer_hud setPoint("TOPRIGHT", "TOPRIGHT", 0, 0);					
	timer_hud.alpha = 1;
	timer_hud.color = (1, 0.8, 1);
	timer_hud.hidewheninmenu = 1;

	timer_hud setTimerUp(0);
}

SongSplit1(a_label, trigger, beginning)
{
    self endon("disconnect");
    level endon("end_game");

    split_time1 = createserverfontstring("hudsmall" , 1.3);
	split_time1 setPoint("TOPRIGHT", "TOPRIGHT", 0, 150);					
	split_time1.alpha = 0;
	split_time1.color = (0.6, 0.8, 1);
	split_time1.hidewheninmenu = 1;
    // split_time1.label = &"" + a_label;

    level waittill (trigger);
    split_time1 setText("" + a_label + GetTimeDetailed(beginning));
	split_time1.alpha = 1;
}

SongSplit2(a_label, trigger, beginning)
{
    self endon("disconnect");
    level endon("end_game");

    split_time2 = createserverfontstring("hudsmall" , 1.3);
	split_time2 setPoint("TOPRIGHT", "TOPRIGHT", 0, 175);					
	split_time2.alpha = 0;
	split_time2.color = (0.6, 0.8, 1);
	split_time2.hidewheninmenu = 1;
    // split_time2.label = &"" + a_label;

    level waittill (trigger);
    split_time2 setText("" + a_label + GetTimeDetailed(beginning));
	split_time2.alpha = 1;
}

SongSplit3(a_label, trigger, beginning)
{
    self endon("disconnect");
    level endon("end_game");

    split_time3 = createserverfontstring("hudsmall" , 1.3);
	split_time3 setPoint("TOPRIGHT", "TOPRIGHT", 0, 200);					
	split_time3.alpha = 0;
	split_time3.color = (0.6, 0.8, 1);
	split_time3.hidewheninmenu = 1;
    // split_time3.label = &"" + a_label;

    level waittill (trigger);
    split_time3 setText("" + a_label + GetTimeDetailed(beginning));
	split_time3.alpha = 1;
}

SongSplits()
{
    timestamp_init = int(gettime());
    level thread SongWatcher();

    if (level.script == "zm_transit")
        level thread SongSplit1("Carrion: ", "meteor_activated", timestamp_init);
    else if (level.script == "zm_nuked")
    {
        level thread SongSplit1("Samantha's Lullaby: ", "meteor_activated", timestamp_init);
        level thread SongSplit2("Coming Home: ", "cominghome_activated", timestamp_init);
        level thread SongSplit3("Re-Damned: ", "redamned_activated", timestamp_init);
    }
    else if (level.script == "zm_highrise")
        level thread SongSplit1("We All Fall Down: ", "meteor_activated", timestamp_init);
    else if (level.script == "zm_prison")
    {
        level thread SongSplit1("Where Are We Going: ", "meteor_activated", timestamp_init);
        level thread SongSplit2("Rusty Cage: ", "johnycash_activated", timestamp_init);
    }
    else if (level.script == "zm_buried")
        level thread SongSplit1("Always Running: ", "meteor_activated");
    else if (level.script == "zm_tomb")
    {
        level thread SongSplit1("Archangel: ", "archengel_activated", timestamp_init);
        level thread SongSplit2("Aether: ", "aether_activated", timestamp_init);
        level thread SongSplit3("Shepherd of Fire: ", "shepards_activated", timestamp_init);
    }
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
    iPrintLn("johnycash_activated");
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
