# KrunchLoader
by Krunch

A Custom Loader for Trailmappers designed to make life a little bit easier for TrailMakers mappers.

---
**FEATURES:**

* Physics Materials!
  - a physics material (eg Grass, Mud, etc.) defines how the surface of an object reacts to objects that touch it 
  - more info below about how to add them to your map 

* Multiple SpawnPoints
  - add as many extra SpawnPoints as you'd like
  - your SpawnPoints can be displayed on the Fast Travel list in any order you choose 

* Per Player Home SpawnPoints
  - setup individual home spawnpoints for each player that joins in multiplayer
  - helps prevent server-ending-blueprint-merging-nuclear-explosions

* Personal Spawn Point
  - allows players to set a personal spawn point at their current position

* SpawnPoint Protection
  - system to stop anyone spawning at a spawnpoint if it is already occupied by a player or structure
  - helps prevent server-ending-blueprint-merging-nuclear-explosions

* Tab for Map View (Test Zone)
  - if a map image has been added press Tab to show a full screen map view of the ... er map
  - press Tab again to exit the map view

* Aerial Views
  - press numpad 0 to see an aerial view from high above the map origin point
  - press numpad 0 again to see an aerial view from high above your player's position
  - press numpad 0 a 3rd time to exit the aerial view

* More Host Options
  - block & unblock any player from using the builder
  - server performance: globally delete any unoccupied structures ie >50 metres from owner
  - server performance: globally delete ALL structures on the server

* Area Name Zones
  - add a zone with a name that shows up when players move into that area
  
* No-Builder zones
  - add areas where players are blocked from opening the builder 
  
* SoundFX Triggers
  - Coming soon! add triggers to cause sound effects to play 

---
**HOW TO INSTALL KRUNCHLOADER**

1. Extract the zip file to a folder on your computer

2. Open that folder to view it's contents:

  - [Example Mod Map] << this is a simple example map that you can play in Trailmakers to see how the special features work

  - [Files for Trailmappers] << contains the models and textures that you can use to add special features to your map

  - [Files for Exported Maps] << contains the files that activate the special features in your map
    *Explanation of files in [data_static]:*
     - ``KrunchLoader.lua`` << the actual replacement loader script
     - ``main.lua`` << special pointer file which needs to be copied over the one in the root map folder **after every Trailmappers export** (always leave a copy of it here)
     - ``map_icon.png`` << custom icon for messages in your map (you can replace this with your own if you like but there must be a file with that name in here)
     - ``tabMapMesh.obj`` << special object for the Tab key map view. It only activates if you have a file called tabMapTex.jpg in this folder (you can make your own map view image)

3. Open [Files for Exported Maps] and copy the [data_static] folder into your map's [data_static] folder

4. Also copy the ``main.lua`` file into your map's base folder overwriting the existing ``main.lua`` file there

5. Repeat step 4 each time you re-export your map from Trailmappers (as the Trailmappers export overwrites the main.lua file)
*Note: You'll find a copy of the special main.lua file in your map's [data_static] folder

6. You can now load up your map in Trailmakers and see the extra features

---
**HOW TO ADD THE KRUNCHLOADER FEATURES TO YOUR MAP**

 
**SoundFX Triggers**
Coming soon!
You can add triggers to cause sound effects to play 

`
**Physics Materials**

You can add a physics material to a custom object by naming a texture in a special way and then applying that texture to the object in TrailMappers.
Use the following naming format for your Physics Material textures:

``{mtl}{_MaterialName_}{texturename}{.extension}``

  - ``{mtl}`` = material prefix  << allows the code to find objects with special physics materials
  - ``{_MaterialName_}`` = physics material name (case sensitive)  << the script will extract the physics material name from between the underscores
    *Note: The MaterialName between the underscores must EXACTLY match one of the materials in the Physics Material Names list below (Case Sensitive!)*
  - ``{texturename}`` = texture name << your name for the texture but must be no more than 12 characters long
  - ``{.extension}`` = existing file extension << usually png or jpg

Texture Naming Examples:
``mtl_Grass_mainterrain.png``  << renamed a texture called "mainterrain.png"
``mtl_Sand_sandyzones.png``  << renamed a texture called "sandyzones.png"
``mtl_IceSlippery_shinysmooth.jpg``  << renamed a texture called "shinysmooth.jpg"

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
*Note: Objects using a texture without a Physics Material simply use the Asphalt physics material*

.
**Extra SpawnPoints**

The original Trailmappers SpawnPoint will always be the "Home" SpawnPoint. You can add additional ones in Trailmappers by following the method below:
*Note: Your custom SpawnPoints can be displayed on the Fast Travel list in any order you choose ("Home" is always at the top of the list)

1. Decid what name you'd like to use for your additional SpawnPoint

2. Make a copy of one of the SpawnPoint textures (eg. ``SpawnPoint_01_Area51.png``) and make sure it is in the ***[Custom Models]*** folder in Trailmappers

3. Carefully rename only the part of the name that is after "SpawnPoint_" by following this example:
  - For a SpawnPoint called "Black Tower" that is to be the first button after "Home", you copy and rename ``SpawnPoint_01_Area51.png`` >> to >> ``SpawnPoint_01_Black Tower.png``
  - For another SpawnPoint called "White Tower" that is to be the second button after "Home", you copy and rename ``SpawnPoint_01_Area51.png`` >> to >> ``SpawnPoint_02_White Tower.png``

4. Load your map in Trailmappers, find the ``SpawnPoint.obj`` model in the **Custom Models** tab and place it into your map somewhere

5. Add the texture that you renamed earlier to that object

6. Reposition and rotate it as needed

7. Repeat for each extra SpawnPoint that you want to add

8. Export your map

9. Re-copy ``main.lua`` from your map's [data_static] folder into your map's base folder

10. Load your map in Trailmakers

'
**Multiplayer Special Home SpawnPoints**

If you would like separate multiplayer Home SpawnPoints for each player do the following (the host always uses the base home SpawnPoint, only other players can have different home spawn points). This process is very similar to the above process however the textures are already named and ready to go:

1. As before place and rotate a new SpawnPoint object where you would like the first joining player to spawn

2. Use the texture called ``SpawnPoint_ID_1`` on that object and that will become that player's home spawnpoint

3. Repeat for any other ones you want to add (up to ID_7)

4. Export your map

5. Re-copy ``main.lua`` from your map's [data_static] folder into your map's base folder

6. Load your map in Trailmakers

~
**Area Name Zones**

Add trigger boxes to create zones that will display an area name when a player enters that zone:

1. Decide what name you'd like to use for a new named zone

2. Make a copy of one of the NameBox textures (eg. ``NameBox_Area51.png``) and make sure it is in the ***[Custom Models]*** folder in Trailmappers

3. Carefully rename only the part of the name that is after "NameBox_" by following this example:
  - For a NameBox called "Black Tower" you copy and rename ``NameBox_Area51.png`` >> to >> ``NameBox_Black Tower.png``
  - For another NameBox called "White Tower" you copy and rename ``NameBox_01_Area51.png`` >> to >> ``NameBox_White Tower.png``

4. Load your map in Trailmappers, find the ``NameBox.obj`` model in the **Custom Models** tab and place it into your map somewhere

5. Position, scale and rotate it as needed

6. Add the texture that you renamed earlier to that object

7. Repeat for each extra NameBox that you want to add

8. Export your map

9. Re-copy ``main.lua`` from your map's [data_static] folder into your map's base folder

10. Load your map in Trailmakers

|
**No-builder Zones**

Add trigger boxes to create zones that will prevent all players from opening the builder:

1. Load your map in Trailmappers, find the ``BuilderBox.obj`` model in the **Custom Models** tab and place it into your map somewhere

2. Add the ``BuilderBox.png`` texture to that object

3. Position, scale and rotate it as needed

4. Repeat for each extra BuilderBox that you want to add

5. Export your map

6. Re-copy ``main.lua`` from your map's [data_static] folder into your map's base folder

7. Load your map in Trailmakers

---

KrunchLoader
by Krunch

Includes code from the Trailmappers Loader by Ridicolas & Jess2005

This mod is a work in progress (WIP) and may contain bugs

Use of this mod is entirely at your OWN RISK

Read the "ReadMe.txt" file that accompanies this mod for more information

Find help & report bugs in the TM Discord modding channel: https://discord.gg/trailmakers

Buy me a cup of coffee or just send feedback by visiting: https://ko-fi.com/krunchcreates
