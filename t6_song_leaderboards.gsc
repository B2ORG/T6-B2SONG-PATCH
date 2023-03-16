/*
To update records, go to the function representing song that's to be updated
Function naming scheme is "wr_" plus name of the song separated with underscores
Inside of a function, there is a "switch" statement, inside of which you'll find cases
Each case represents number of players, so "case 2:" representing 2 players for example
Update values in correct case, update wr with the amount of second (for example 107.5 is 1:47.5)
Update player with name of the player
Make sure value in "player" is enclosed in double quotes, and value in "wr" isn't
Both lines have to end with semicollon
After updating, please go to get_song_leaderboard() function definition, find lines that say lb["date"] and lb["update_by"] and change values inside of double quotes accordingly
Help in official song sr discord https://discord.gg/8ugeuytEAm or Zi0#1063
*/

main()
{
    thread safe_init();
}

safe_init()
{
    level.SONG_LEADERBOARD = get_song_leaderboard();
}

print(stub)
{}

get_song_leaderboard()
{
    lb = array();
    lb["date"] = "March 17th 2023";
    lb["update_by"] = "Zi0";

    for (i = 1; i < 5; i++)
    {
        lb["carrion"]["" + i] = wr_carrion(i);
        lb["lullaby"]["" + i] = wr_samanthas_lullaby(i);
        lb["cominghome"]["" + i] = wr_coming_home(i);
        lb["damned"]["" + i] = wr_re_damned(i);
        lb["fall"]["" + i] = wr_we_all_fall_down(i);
        lb["wawg"]["" + i] = wr_where_are_we_going(i);
        lb["rusty"]["" + i] = wr_rusty_cage(i);
        lb["alwaysrunning"]["" + i] = wr_always_running(i);
        lb["archangel"]["" + i] = wr_archangel(i);
        lb["aether"]["" + i] = wr_aether(i);
        lb["shepherd"]["" + i] = wr_shepherd(i);
    }

    return lb;
}

return_data(wr, player)
{
    if (!isDefined(wr) || !isDefined(player))
        return undefined;

    a = array();
    a["wr"] = wr;
    a["player"] = player;

    return a;
}

wr_carrion(num_of_players)
{
    switch (num_of_players)
    {
        case 1:
            wr = 119.2;
            player = "Vistek";
            break;
        case 2:
            wr = 69.2;
            player = "Okla & D4niel";
            break;
        case 3:
            wr = 76.8;
            player = "Skimpy, Tonestone & Zi0";
            break;
        case 4:
            wr = 73.6;
            player = "Skimpy, Excosis, TheOne53 & Droxzz";
            break;
        default:
            print("Failed to define WR");
            wr = undefined;
            player = undefined;
    }

    return return_data(wr, player);
}

wr_samanthas_lullaby(num_of_players)
{
    switch (num_of_players)
    {
        case 1:
            wr = 114.3;
            player = "Skimpy";
            break;
        case 2:
            wr = 76.2;
            player = "Okla & D4niel";
            break;
        case 3:
            wr = 47.7;
            player = "Zi0, Skimpy & Tonestone";
            break;
        case 4:
            wr = 0;
            player = "Nobody has this record yet!";
            break;
        default:
            print("Failed to define WR");
            wr = undefined;
            player = undefined;
    }

    return return_data(wr, player);
}

wr_coming_home(num_of_players)
{
    switch (num_of_players)
    {
        case 1:
            wr = 0;
            player = "Nobody has this record yet!";
            break;
        case 2:
            wr = 0;
            player = "Nobody has this record yet!";
            break;
        case 3:
            wr = 0;
            player = "Nobody has this record yet!";
            break;
        case 4:
            wr = 0;
            player = "Nobody has this record yet!";
            break;
        default:
            print("Failed to define WR");
            wr = undefined;
            player = undefined;
    }

    return return_data(wr, player);
}

wr_re_damned(num_of_players)
{
    switch (num_of_players)
    {
        case 1:
            wr = 335.8;
            player = "Zi0";
            break;
        case 2:
            wr = 278.6;
            player = "Zi0 & MrMoonie";
            break;
        case 3:
            wr = 249.9;
            player = "Zi0, Tonestone & MrMoonie";
            break;
        case 4:
            wr = 270.1;
            player = "Skimpy, Excosis, TheOne53 & Droxzz";
            break;
        default:
            print("Failed to define WR");
            wr = undefined;
            player = undefined;
    }

    return return_data(wr, player);
}

wr_we_all_fall_down(num_of_players)
{
    switch (num_of_players)
    {
        case 1:
            wr = 66.7;
            player = "D4niel";
            break;
        case 2:
            wr = 34.2;
            player = "D4niel & OkLa";
            break;
        case 3:
            wr = 33.0;
            player = "D4niel, OkLa & MandingaMagica";
            break;
        case 4:
            wr = 33.6;
            player = "Excosis, PizzaHydra, TheOne53 & D4niel";
            break;
        default:
            print("Failed to define WR");
            wr = undefined;
            player = undefined;
    }

    return return_data(wr, player);
}

wr_where_are_we_going(num_of_players)
{
    switch (num_of_players)
    {
        case 1:
            wr = 74.0;
            player = "Vistek";
            break;
        case 2:
            wr = 54.0;
            player = "Vistek & Jayemce";
            break;
        case 3:
            wr = 46.0;
            player = "D4niel, TheOne53 & Tonestone";
            break;
        case 4:
            wr = 52.0;
            player = "Skimpy, Excosis, TheOne53 & Droxzz";
            break;
        default:
            print("Failed to define WR");
            wr = undefined;
            player = undefined;
    }

    return return_data(wr, player);
}

wr_rusty_cage(num_of_players)
{
    switch (num_of_players)
    {
        case 1:
            wr = 74.9;
            player = "Excosis";
            break;
        case 2:
            wr = 42.5;
            player = "D4niel & OkLa";
            break;
        case 3:
            wr = 39.0;
            player = "D4niel, OkLa & Piripipu";
            break;
        case 4:
            wr = 38.4;
            player = "Skimpy, Excosis, Plant & Tonestone";
            break;
        default:
            print("Failed to define WR");
            wr = undefined;
            player = undefined;
    }

    return return_data(wr, player);
}

wr_always_running(num_of_players)
{
    switch (num_of_players)
    {
        case 1:
            wr = 39.2;
            player = "Vistek";
            break;
        case 2:
            wr = 37.4;
            player = "Vistek & Jayemce";
            break;
        case 3:
            wr = 40.8;
            player = "Excosis, Jayemce & Vistek";
            break;
        case 4:
            wr = 40.5;
            player = "D4niel, Skimpy, Excosis & TheOne53";
            break;
        default:
            print("Failed to define WR");
            wr = undefined;
            player = undefined;
    }

    return return_data(wr, player);
}

wr_archangel(num_of_players)
{
    switch (num_of_players)
    {
        case 1:
            wr = 180.4;
            player = "rac seven";
            break;
        case 2:
            wr = 107.0;
            player = "Zi0 & MrMoonie";
            break;
        case 3:
            wr = 107.7;
            player = "Skimpy, Tonestone & Zi0";
            break;
        case 4:
            wr = 109.7;
            player = "Excosis, TheOne53, Jayemce & JDubs";
            break;
        default:
            print("Failed to define WR");
            wr = undefined;
            player = undefined;
    }

    return return_data(wr, player);
}

wr_aether(num_of_players)
{
    switch (num_of_players)
    {
        case 1:
            wr = 0;
            player = "Nobody has this record yet!";
            break;
        case 2:
            wr = 0;
            player = "Nobody has this record yet!";
            break;
        case 3:
            wr = 0;
            player = "Nobody has this record yet!";
            break;
        case 4:
            wr = 0;
            player = "Nobody has this record yet!";
            break;
        default:
            print("Failed to define WR");
            wr = undefined;
            player = undefined;
    }

    return return_data(wr, player);
}

wr_shepherd(num_of_players)
{
    switch (num_of_players)
    {
        case 1:
            wr = 407.1;
            player = "Lilleman";
            break;
        case 2:
            wr = 0;
            player = "Nobody has this record yet!";
            break;
        case 3:
            wr = 0;
            player = "Nobody has this record yet!";
            break;
        case 4:
            wr = 0;
            player = "Nobody has this record yet!";
            break;
        default:
            print("Failed to define WR");
            wr = undefined;
            player = undefined;
    }

    return return_data(wr, player);
}
