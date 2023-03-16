main()
{
    thread safe_init();
}

safe_init()
{
    level.SONG_LEADERBOARD = get_song_leaderboard();
}

get_song_leaderboard()
{
    lb = array();
    lb["date"] = "March 17th 2023";
    lb["update_by"] = "Zi0";
    lb["carrion"] = wr_carrion(1);
    lb["carrion"] = wr_carrion(2);
    lb["carrion"] = wr_carrion(3);
    lb["carrion"] = wr_carrion(4);
    lb["lullaby"] = wr_samanthas_lullaby(1);
    lb["lullaby"] = wr_samanthas_lullaby(2);
    lb["lullaby"] = wr_samanthas_lullaby(3);
    lb["lullaby"] = wr_samanthas_lullaby(4);
    lb["cominghome"] = wr_coming_home(1);
    lb["cominghome"] = wr_coming_home(2);
    lb["cominghome"] = wr_coming_home(3);
    lb["cominghome"] = wr_coming_home(4);
    lb["damned"] = wr_re_damned(1);
    lb["damned"] = wr_re_damned(2);
    lb["damned"] = wr_re_damned(3);
    lb["damned"] = wr_re_damned(4);
    lb["fall"] = wr_we_all_fall_down(1);
    lb["fall"] = wr_we_all_fall_down(2);
    lb["fall"] = wr_we_all_fall_down(3);
    lb["fall"] = wr_we_all_fall_down(4);
    lb["wawg"] = wr_where_are_we_going(1);
    lb["wawg"] = wr_where_are_we_going(2);
    lb["wawg"] = wr_where_are_we_going(3);
    lb["wawg"] = wr_where_are_we_going(4);
    lb["rusty"] = wr_rusty_cage(1);
    lb["rusty"] = wr_rusty_cage(2);
    lb["rusty"] = wr_rusty_cage(3);
    lb["rusty"] = wr_rusty_cage(4);
    lb["alwaysrunning"] = wr_always_running(1);
    lb["alwaysrunning"] = wr_always_running(2);
    lb["alwaysrunning"] = wr_always_running(3);
    lb["alwaysrunning"] = wr_always_running(4);
    lb["arachangel"] = wr_archangel(1);
    lb["arachangel"] = wr_archangel(2);
    lb["arachangel"] = wr_archangel(3);
    lb["arachangel"] = wr_archangel(4);
    lb["aether"] = wr_aether(1);
    lb["aether"] = wr_aether(2);
    lb["aether"] = wr_aether(3);
    lb["aether"] = wr_aether(4);
    lb["shepherd"] = wr_shepherd(1);
    lb["shepherd"] = wr_shepherd(2);
    lb["shepherd"] = wr_shepherd(3);
    lb["shepherd"] = wr_shepherd(4);

    return lb;
}

return_data(num, wr, player)
{
    if (!isDefined(wr) || !isDefined(player))
        return undefined;

    a = array();
    a["" + num] = array();
    a["" + num]["wr"] = wr;
    a["" + num]["player"] = player;
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

    return return_data(num_of_players, wr, player);
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

    return return_data(num_of_players, wr, player);
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

    return return_data(num_of_players, wr, player);
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

    return return_data(num_of_players, wr, player);
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

    return return_data(num_of_players, wr, player);
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

    return return_data(num_of_players, wr, player);
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

    return return_data(num_of_players, wr, player);
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

    return return_data(num_of_players, wr, player);
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

    return return_data(num_of_players, wr, player);
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

    return return_data(num_of_players, wr, player);
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

    return return_data(num_of_players, wr, player);
}

print(stub)
{}