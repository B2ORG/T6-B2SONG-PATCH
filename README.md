# A patch with automated timers for accurate timing of song speedruns.

### Timing rules
- Start position: When screen fades in </br>
- Finish position: Immidiately after all conditions required for playing the music are met </br>

### Details
- Patch should support every version of BO2, no Plutonium exclusive features are being used </br>
- Patch supports all Easter Egg songs in BO2 </br>
- Patch does not change any game rules besides setting Strafe & Backspeed to proper values (which is being done by both Redacted and Plutonium anyways) </br>
- If you want to report a problem or request a feature, you may use the Issues section. </br>

### Access levels
##### `0` - Only basic features
- Timer</br>
- Splits</br>
- Perma perks</br>
- Attempt counter</br>
- Backspeed</br>

##### `1` - Some extras
- Progress meter</br>

##### `2` - All features
- Song lock meter</br>

# Changelog
### V3
- Seconds decimals (ms) have been reduced to one, due to 2nd decimal being inaccurate at times. </br>Eg: `.8 == 800ms`</br>
- Mob song names have been fixed
- Patch prints have been improved

### V4
- Attempt counter has been added. It will reset between maps and game restarts.
- All perma perks are now awarded at the beginning of each game on maps supporting them.
- Progress counter has been added for Access Level 1 & 2.