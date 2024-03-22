# LAZE-3D
LAZE-3D is a cross-platform Pascal (Lazarus) rewrite project of MASMZE-3D (v1.1), a half-game, half-(tech)demo made on MASM32 and WinAPI. It uses the LCL for the Windows-specific procedures from the original MASMZE-3D code. LAZE-3D is shared as a Lazarus project, to import it fully, the .lpi (Lazarus project info) file is needed (contains DEBUG symbol definition in Debug building mode, which enables debug features through preprocessor).

The repository does not include the libraries **stb_vorbis** and **OpenAL Soft**, you can download (and build) them from: https://github.com/nothings/stb and https://openal-soft.org/ . You can also use the installable OpenAL library by changing **OpenALPath** in **audio.inc** to a valid path to OpenAL.dll.
The repository also does not include any game assets, the use of which, together with the game logic, are hard-coded. To get the resources, you can download the game.

***

The game's code, not including the external libraries, is licensed under the GNU General Public License v3.0. The game's assets are licensed under a Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.

© Yevhenii Ionenko (aka GreatCorn), 2023-2024

https://github.com/GreatCorn/MASMZE-3D/
https://greatcorn.github.io/me/
