# Changelog B2SONG

## Version 1

- Integration with B2 ecosystem (that includes extensions)
- Added reminder about multi-pov requirement to coop games
- Game automatically ends on maps without songs
- Addressed a compile error that prevented the patch from compiling on newer versions of gsc-tool

# Changelog Song Timing Patch

These are all the changes from before rebranding, B2SONG version 1 would be either Version 8 or 7.4 if the name hasn't change

## Version 7.3

- Set max bank value to be aligned with the actual value in game (thanks [Huth](https://github.com/HuthTV))
- .05 accuracy for timing songs and splits has been restored (from .1 accuracy)
- Created optional `any%` gsc addon, which can be used to alter rules of the game (check README for details)
- Applied improvements to First Box and Permaperks functions from B2OP

## Version 7.2

- Fixed error that prevented bank from working

## Version 7.1

- Patch now prevents false Nuketown's Coming Home complition
This bug is caused by the game only generating 27 mannequins on the map. When that happens, patch gives players an option to restart without losing an attempt, it also disables Coming Home tracking for that round.

## Version 7

- Changed tech from `irony.dll` to `gsc-tool`
- Applied more proper gsc style to the codebase
- Scrapped old timing system and created it from scratch
- Songs now have splits
- HUD has been completely reworked
- Added optional built-in leaderboard system
- First box functionality moved to the main file and made optional (based on FR FIX)
- Box is now forcebly moved to Yellow House backyard on Nuketown
- Scrapped old permaperk system and applied one from FRFIX

## Version 6

- Added point drops tracker.
- Added First Box detector.
- Made zone hud less visible.
- Made optional First Box module (separate file).

## Version 5.1

- Fixed Z axis movement speed values counting towards velocity meter

## Version 5

- Removed access levels, players agree to have all the functionalities in competitive runs
- Added Velocity meter and Gspeed display
- Improved zone HUD handling

## Version 4.1

- Fixed an issue where permaperk would not be lost and would remain active for the entire game if player would break permaperk conditions within first few seconds of the game


## Version 4

- Attempt counter has been added. It will reset between maps and game restarts.
- All perma perks are now awarded at the beginning of each game on maps supporting them.
- Progress counter has been added for Access Level 1 & 2.

## Version 3

- Seconds decimals (ms) have been reduced to one, due to 2nd decimal being inaccurate at times. Eg: `.8 == 800ms`
- Mob song names have been fixed.
- Patch prints have been improved.


# History of broken versions

- 4.0 - Broken perma perks -> Fixed in 4.1. </br>
- 5.0 - Inaccurate velocity meter -> Fixed in 5.1. </br>
