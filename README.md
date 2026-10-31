# Project07_FreePause

Free pause menu for Qbox. ESC opens a clean text list on the left with your name, job, money and server id. No admin panel, buttons are in `config.lua`.

## Features
- Resume, Map, Settings (the GTA menus), Quit (asks twice).
- Background blur, players online, clock.
- Discord log when someone quits from the menu.

## Requirements
- [qbx_core](https://github.com/Qbox-project/qbx_core)
- [ox_lib](https://github.com/overextended/ox_lib)
- Project7H_Lib

## Installation
1. Put `Project07_FreePause` in your `resources` folder.
2. Add to `server.cfg` after the requirements:
   ```
   ensure Project07_FreePause
   ```
3. Change the server name, blur and buttons in `config.lua`.
4. Optional: Discord webhook in `sv_config.lua`.

Do not run it together with another pause menu script.

## Building the UI (only if you change it)
```
cd web
npm install
npx vite build --mode pause
```
Copy `build/pause` to `web/build`.
