**With this patch, forget about having to manually time Black Ops II Zombies Song Speedruns.**

![Patch example screenshot](https://i.imgur.com/9yKBTUV.jpeg)

# Timing rules

- Start position: As soon as player is given control over his character
- Finish position: As soon as trigger for the song in quesion is hit

# Installation

Installation methodology differs between launchers.

## New Plutonium (Online)

- Get most recent version of the patch from [releases](https://github.com/Zi0MIX/T6-SONG-TIMER-PATCH/releases) section
- Put that file in:

```C:\Users\{your username here}\AppData\Local\Plutonium\storage\t6\scripts\zm```

Video installation guide: [YouTube](https://youtu.be/1gUZCMJ3Sjk) by SkimpyChooch (this has been made for older versions of the patch but it's pretty much the same thing)

## Redacted (LAN)

- Download [raw script](https://github.com/Zi0MIX/T6-SONG-TIMER-PATCH/blob/main/t6_song_patch.gsc) (make sure to do it from `main` branch, you can do it by clicking on the hyperlink)
- Put that file in:

```{path to your redacted folder}\data\scripts```

## Additional info

The reason why compiled script is not going to work with Redacted, is the fact that it's compiled using [xensik's compiler](https://github.com/xensik/gsc-tool), which is superior to old compiler but not supported by either Redacted or Ancient Plutonium (Offline)

Please note, script is not rated or tested for Redacted, use it there at your own risk. I recommend either using most recent version of Plutonium or version [r2905](https://youtu.be/tb2gsL12wwI)

# Changes

Patch is doing the following things:
- Fix strafe and back speed to values 1.0 and 0.9 respectivelly
- Moves the box on Nuketown to always be behind Yellow House
- Tracks `music lock` which is used by the game as sort of a global lock. While this is active, no other music can be triggered (biggest impact for Origins)
- Gives optional first box capabilites (look below for details)
- Displays current player velocity and zone he's in (due to gsc patches being server sided, off-host players will notice slight desync on their velocity meters)
- Awards perma perks on connect for all players on maps that use them (note game will force fast restart upon doing so)
- Fills up all players bank accounts (only in game tho)
- Displays current progress for each song (if possible)
- Displays current amount of attempts (Counter will reset if players keep playing the same song but change host at some point. To reset attempt tracker, host should load on a different map once)
- Tracks triggers for songs and splits for songs (look below for details)

# Song Timing

Patch tracks every song that is in game, and each song has dedicated splits. Splits will be printed upon completing them for few seconds, and then permanently upon activating the song.

# Splits

List of splits for each of the songs

## Carrion (Tranzit)
1. As soon as depot is open
2. 2nd teddy bear

## Samantha's Lullaby (Nuketown)
1. Entering 2nd floor of yellow house
2. Entering green house

## Coming Home (Nuketown)
Split into 3 main zones, time 2 first zones as splits, splits are hidden until song is active

## Re-Damned (Nuketown)
1. End of round 2
2. End of round 4

## We All Fall Down (Die Rise)
1. 1st teddy bear
2. 2nd teddy bear

## Rusty Cage (MOTD)
1. 2nd bottle
2. Gondola activation

## Where Are We Going (MOTD)
1. Opening laundry zone
2. Last doors open

## Always Running (Buried)
1. Reaching floor level of bank area
2. 2nd teddy bear

## Archangel (Origins)
1. 1st door
2. 2nd door
3. Entering NML

## Aether (Origins)
1. 1st door
2. 2nd door
3. Last door

## Shepherd of Fire (Origins)
1. Entering NML
2. 1st radio
3. 2nd radio

# First Box

In order to use First Box, player has to set following command in the game console (press `~`)

```fb <key>```

Key being a short text representing each of the weapons. This will force selected weapon from the box next time the box is hit. Note, you can only select weapon that's available on the map you're playing and it otherwise obtainable

If you are playing on New Plutonium, you can also just send a chat message following the same pattern at the command above, it'll work the same way.

## Weapon keys

| Weapon | Key |
| --- | --- |
| Ballistic Knife | bk |
| Blundergat | blunder |
| EMP | emp |
| Monkeys | monk |
| Paralyzer | paralyzer |
| RayGun | mk1 |
| RayGun MK2 | mk2 |
| Sliquifier | sliq |
| Time Bomb | time |
| AK47 | ak47 |
| B23R | b23re |
| Chicom CQB | chic |
| Death Machine | dm |
| DSR50 | dsr |
| Executioner | exe |
| Fal | fal |
| Five-Seven | 57 |
| Five-Seven DW | 257 |
| Galil | galil |
| HAMR | hamr |
| KAP-40 | kap |
| KSG | ksg |
| LSAT | lsat |
| M1216 | m1216 |
| M1927 | tommy |
| M27 | m27 |
| M82A1 Barret | barret |
| M8A1 | m8 |
| MG08 | mg |
| MP40 | mp40 |
| MTAR | mtar |
| PDW57 | pdw |
| Python | pyt |
| RNMA | rnma |
| RPD | rpd |
| RPG | rpg |
| Saiga | s12 |
| Scar | scar |
| Skorpion EVO | evo |
| Type 25 | type |
| War Machine | wm |

# Any% category

In order to play on built-in any% mode, download additional file `T6-SONG-ANYPERCENT.gsc` and put it in your patch folder alongside the normal patch. If you wish to restore normal behavior, just remove (or move) the file out of the patch folder and restart the game / perform `map_restart`.

## Any% changes

- Powerups
    * First zombie is guaranteed to give double points
    * Nuke is guaranteed to be a 2nd drop in the cycle
    * Above changes do not affect Origins dig spots
- Removed sound lock (when song items cannot be pressed on Origins)
- Removed OOB safety, players can now go out of bounds

# Leaderboards

New in version 7 is a leaderboard module. If file storing leaderboard data is present in your patch folder, Song patch will display current records for the map you're playing. For that to show, you need to download 2nd file that you can find in releases( installation process looks exactly the same as main patch file), this file will be updated every time a record is beaten, but it's up to the player to download the updated file from the releases section.

# Updates

- To see details about updates, visit [changelog](https://github.com/Zi0MIX/T6-SONG-TIMER-PATCH/blob/main/CHANGELOG.md) file.
- To track development, join [my Discord server](https://discord.gg/fDY4VR6rNE), where details about my current projects are being posted
- To track releases (for both main updates and leaderboard file updates) join [Official Song Speedrunning Discord Server](https://discord.gg/8ugeuytEAm). Info about releases will also appear on my server, but if you gonna play song speedruns, i recommend being on the dedicated discord server regardless.

# Contribution

You can contribute to this project either passively, by reporting bugs, feature requests, new records (for leaderboard), or actively, by forking this repository to your own GitHub and opening a pull request with changes. Please do note, changes you add must align with Song Speedrunning ruleset, and also not break current features.
