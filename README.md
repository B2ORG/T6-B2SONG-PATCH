# A patch with automated timers for accurate timing of song speedruns.

### Timing rules
- Start position: When screen fades in </br>
- Finish position: Immidiately after all conditions required for playing the music are met </br>

### Details
- Patch should support every version of BO2, no Plutonium exclusive features are being used </br>
- Patch supports all Easter Egg songs in BO2 </br>
- Patch does not change any game rules besides setting Strafe & Backspeed to proper values (which is being done by both Redacted and Plutonium anyways) </br>
- If you want to report a problem or request a feature, you may use the Issues section. </br>

### First Box module
- First Box module will not work if Song Patch is not in the game, so it can be stored in scripts folder at all times. </br>
- First Box module only works on Nuketown and Buried. </br>
- First Box is only applied to first hit in the game (no matter which player). </br>
- First Box on Nuketown gives MK2, and on Buried Paralyzer. </br>
- First Box location on Nuketown is always going to be Yellow House. </br>

### Broken versions history
- 4.0 - Broken perma perks -> Fixed in 4.1. </br>
- 5.0 - Inaccurate velocity meter -> Fixed in 5.1. </br>

# Changelog
### V3
- Seconds decimals (ms) have been reduced to one, due to 2nd decimal being inaccurate at times. Eg: `.8 == 800ms`
- Mob song names have been fixed.
- Patch prints have been improved.

### V4
- Attempt counter has been added. It will reset between maps and game restarts.
- All perma perks are now awarded at the beginning of each game on maps supporting them.
- Progress counter has been added for Access Level 1 & 2.

### V4.1
- Fixed an issue where permaperk would not be lost and would remain active for the entire game if player would break permaperk conditions within first few seconds of the game

### V5
- Removed access levels, players agree to have all the functionalities in competitive runs
- Added Velocity meter and Gspeed display
- Improved zone HUD handling

### V5.1
- Fixed Z axis movement speed values counting towards velocity meter

### V6
- Added point drops tracker.
- Added First Box detector.
- Made zone hud less visible.
- Made optional First Box module (separate file).