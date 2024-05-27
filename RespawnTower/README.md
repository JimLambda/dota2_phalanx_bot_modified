This script is insprired by Fretbots and Buff. It runs in conjuction with the bot script. It make sure that the tier 4 tower will always auto-respawn, until a certain moment (for example after 60 minutes of the game), to ensure the game can go into late games.

I am also looking forward to add the function of using console commands to respawn towers.

# To Use (for anyone randomly finding this)
0. This script should be inside `steamapps\common\dota 2 beta\game\dota\scripts\vscripts\bots\` folder.
1. Launch DotA 2 with console enabled.
2. For local host only, so Create a Lobby. Make sure that `Enable Cheats` is checked.
3. After the map finished loading, open the console, and type: `sv_cheats 1; script_reload_code bots/RespawnTower/RespawnTower`.
4. The script is now running (The last command should only be run once).

It can be used with other bot scripts, just change some stuff accordingly, to suit whichever script.

It would've been nice to call this within the bot script, but I don't think it is possible.