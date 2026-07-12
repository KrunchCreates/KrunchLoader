# KrunchLoader
by Krunch
A Custom Loader for Trailmappers designed to make life a little bit easier for TrailMakers mappers.

Features:

* Physics Materials!
  - a physics material (eg Grass, Mud, etc.) defines how the surface of an object reacts to objects that touch it 
  - more info below about how to add them to your map 

* Multiple SpawnPoints
  - add as many extra SpawnPoints as you'd like
  - Your SpawnPoints can be displayed on the Fast Travel list in any order you choose 

* Per Player Home SpawnPoints
  - setup individual home spawnpoints for each player that joins in multiplayer
  - helps prevent server-ending-blueprint-merging-nuclear-explosions

* Personal Spawn Point
  - allows players to set a personal spawn point at their current position

* SpawnPoint Protection
  - system to stop anyone spawning at a spawnpoint if it is already occupied by a player or structure
  - helps prevent server-ending-blueprint-merging-nuclear-explosions

* Tab for Map View (Test Zone)
  - If a map image has been added press Tab to show a full screen map view of the ... er map
  - press Tab again to exit the map view

* Aerial Views
  - press numpad 0 to see an aerial view from high above the map origin point
  - press numpad 0 again to see an aerial view from high above your player's position
  - press numpad 0 a 3rd time to exit the aerial view

* More Host Options
  - block & unblock any player from using the builder
  - server performance: globally delete any unoccupied structures ie >50 metres from owner
  - server performance: globally delete ALL structures on the server

* Area Name Triggers
  - add an area with a name that shows up when players move into that area
  
* No-Builder zones
  - add areas where players are blocked from opening the builder 


**How to install the KrunchLoader Kit**

1. Extract the zip file to a folder on your computer

2. Navigate into the "KrunchLoaderKit" folder:

  - [Example Mod Map]
    - [KrunchLoaderMap] << copy this folder to Trailmakers [mods] folder

  - [Files for Trailmappers]
    - [Custom Models] << copy this folder to the TrailMappers [Custom Models] folder
	- [Saves] << copy this folder to the TrailMappers [Saves] folder

  - [Files for Exported Maps]
    - data_static  << copy this folder to your exported map folder in the Trailmakers [mods] folder

* KrunchLoaderMap is a simple example map that you can play in Trailmakers to see how the special features work
* the [Files for Trailmappers/Custom Models] contains the models and textures that you can use to add special features to your map
* the [Files for Trailmappers/Saves] contains an example map that you can open in Trailmappers to see how the special features are placed


**Adding The KrunchLoader Kit To An Existing or New Exported Map**

KrunchLoader works by replacing the original Trailmappers loader script with a new custom one (KrunchLoader.lua).

To make this work for your map do the following:

copy the following files from the data_static folder in the kit into your map's data_static folder:

- KrunchLoader.lua << the actual replacement loader script
- main.lua << special pointer file. This needs to be copied over the one in the root map folder after every Trailmappers export. Good idea to leave a copy of it here
- map_icon.png << custom icon for messages in your map. You can replace this with your own if you like but there must be a file with that name in here,
- tabMapMesh.obj << special object for the Tab key map view. It only activates if you have a file called tabMapTex.jpg in this folder (you can make your own map view image),

Now that you've copied those files into your map's data_static folder you are ready to activate the KrunchLoader for your map.

Copy the main.lua file from the data_static folder into your map's folder, overwriting the existing main.lua file that Trailmappers created (this step needs to be done EVERY TIME YOU RE-EXPORT YOUR MAP from Trailmappers as the export overwrites the main.lua file). This will now 'point' to the new KrunchLoader script in the data_static folder.,

Load up your map in Trailmakers and you should see the extra features in your map.


**How to use Physics Materials**

You can add a physics material to a custom object by naming a texture in a special way and then applying that texture to the object in TrailMappers. Use the following naming format for your Physics Material textures:

mtl_MaterialName_texturename.png (or .jpg)

"mtl" = Material prefix  << allows the code to find objects with special physics materials
"_MaterialName_" = physics material name  << the script will extract the physics material name from between the underscores

*Note: The name between the underscores must EXACTLY match one of the materials in the Physics Material Names list below (Case Sensitive!)

Texture Naming Examples:
mtl_Grass_mainterrain.png  << renamed a texture called "mainterrain.png"
mtl_Sand_sandyzones.png  << renamed a texture called "sandyzones.png"
mtl_IceSlippery_shinysmooth.jpg  << renamed a texture called "shinysmooth.jpg"

Physics Material Names (Case Sensitive!)
```
Metal
Sand
Stone
Gravel
Grass
Mud
Lava
Asphalt 
Snow
Wood
YellowSand
WitheredGrass
IceSlippery
Tundra
SnowHard
GrassYellow
```

*Note: Any texture name without a Physics Material name will simply use the Asphalt physics material


**Adding Extra SpawnPoints in Trailmappers**

The original Trailmappers SpawnPoint will always be the "Home" SpawnPoint. You can add additional ones by following the method below.

* Your custom SpawnPoints can be displayed on the Fast Travel list in any order you choose (note that "Home" is always at the top of the list)

Method:

1. Decide what names you'd like to use for your additional SpawnPoints

2. Make a copy of one of the SpawnPoint textures (eg. ``SpawnPoint_01_Area51.png``) and make sure it is in the **Custom Models** folder in Trailmappers

3. CAREFULLY rename only the part of the name that is after "SpawnPoint_" in the following way:
    Eg For a SpawnPoint called "Black Tower" that is to be the first button after "Home", you copy and rename ``SpawnPoint_01_Area51.png`` >> to >> ``SpawnPoint_01_Black Tower.png``
	For another SpawnPoint called "White Tower" that is to be the second button after "Home", you copy and rename ``SpawnPoint_01_Area51.png`` >> to >> ``SpawnPoint_02_White Tower.png``

4. Load your map in Trailmappers and find the ``SpawnPoint.obj`` model in the **Custom Models** tab and place it into your map somewhere (also rotate it if needed)

5. Add the texture that you renamed earlier to that object

6. Repeat for each extra SpawnPoint that you want to add

Note: These objects and textures will not be loaded into your actual map when loaded into Trailmakers - they are filtered out and only used for the locations, rotation and names of your SpawnPoints.


**Multiplayer Special Home SpawnPoints**

If you would like separate multiplayer Home SpawnPoints for each player do the following (the host always uses the base home SpawnPoint, only other players can have different home spawn points). This process is very similar to the above process however the textures are already named and ready to go:

1. As before place and rotate a new SpawnPoint object where you would like the first joining player to spawn.

2. Use the texture called ``SpawnPoint_ID_1`` on that object and that will become that player's home spawnpoint

3. Repeat for any other ones you want to add (up to ID_7)

---
KrunchLoader
by Krunch
Includes code from the Trailmappers Loader by Ridicolas & Jess2005
This mod is a work in progress (WIP) and may contain bugs
Use of this mod is entirely at your OWN RISK
Read the "ReadMe.txt" file that accompanies this mod for more information
Find help & report bugs in the TM Discord modding channel: https://discord.gg/trailmakers

Buy me a cup of coffee or just send feedback by visiting: https://ko-fi.com/krunchcreates
---
