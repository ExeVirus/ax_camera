# AX Camera
MIT LICENSE, see license.txt

## Description
Provides a simple camera language, that can contain any number of
camera commands that are run in order of listing, over time, smoothly.

## Usage
This mod is not intended for server security.
It can be used by any player, with two chat commands
enabled:

- **/camera** {command,time,val,val,val} {command,time,val,val,val} {etc}
- **/camera_loop** {command,time,val,val,val} {command,time,val,val,val} {etc}

Where:
- **command**: Command name
- **time**: Time for command to last, in seconds
- **val**: Any number value

```
Example chat command:
/camera {line,1,0,9,0,2} {line_look,2,0,9,5,3,0,9,0} {line_look_line,0.5,0,9,5,3,0,10,2} {circle_look,3,0,0,3,1,0,9,0}
```

Further, other mods that depend on this, can access the camera API from lua via:

```lua
ax_camera.camera(player, params, mode)
```
Where:
- player: PlayerEntity
- params: string of "{commands}"
- mode: either "one_shot" or "loop"

## Command Listing

`{pos,time,x,y,z}` - Set Position
|  time   |      x,y,z      |
| :-----: | :-------------: |
| Seconds | Target Position |

`{look,time,x,y,z}` - Set Look Location
|  time   |        x,y,z         |
| :-----: | :------------------: |
| Seconds | Target Look Location |

`{fov,time,fov}` - Set Player FOV
|  time   |      fov       |
| :-----: | :------------: |
| Seconds | New Player FOV |

`{line,time,x,y,z,speed}` - Move player towards location at given speed
|  time   |      x,y,z      | speed            |
| :-----: | :-------------: | ---------------- |
| Seconds | Target Position | Nodes per second |

`{line_look,time,x,y,z,speed,lookx,looky,lookz}` - Same as line, and keep player looking at point
|  time   |      x,y,z      | speed            | lookx,looky,lookz    |
| :-----: | :-------------: | ---------------- | -------------------- |
| Seconds | Target Position | Nodes per second | Target Look Location |

`{line_look_line,time,x,y,z,speed,lookx,looky,lookz,look_speed}` - Same as line, Player look point also moves from last look to the target look point
|  time   |      x,y,z      | speed            | lookx,looky,lookz    | look_speed       |
| :-----: | :-------------: | ---------------- | -------------------- | ---------------- |
| Seconds | Target Position | Nodes per second | Target Look Location | Nodes per second |

`{circle,time,center_x,center_z,arc_speed,y_speed}` - Move player around center_x,center_z. Y speed controlled independently
|  time   | center_x,center_z | arc_speed        | y_speed          |
| :-----: | :---------------: | ---------------- | ---------------- |
| Seconds |  Rotation Origin  | Nodes per second | Nodes per second |

`{circle_look,time,center_x,center_z,arc_speed,y_speed,lookx,looky,lookz}` - Same as circle, and keep player looking at point
|  time   | center_x,center_z | arc_speed        | y_speed          | lookx,looky,lookz    |
| :-----: | :---------------: | ---------------- | ---------------- | -------------------- |
| Seconds |  Rotation Origin  | Nodes per second | Nodes per second | Target Look Location |

`{circle_look_line,time,center_x,center_z,arc_speed,y_speed,lookx,looky,lookz,look_speed}` - Same as circle, Player look point also moves from last look point to the target look point
|  time   | center_x,center_z | arc_speed        | y_speed          | lookx,looky,lookz    |
| :-----: | :---------------: | ---------------- | ---------------- | -------------------- |
| Seconds |  Rotation Origin  | Nodes per second | Nodes per second | Target Look Location |

### Important Notes: 
1. `line_look_line` and `circle_look_line` require this player to have received at least one previous look command in order to correctly move from a previous look location to the new one
2. `time` can be 0, for multilpe commands to be called instantly in one server step
3. Race conditions are one cause of choppiness, because set_pos, set_look, and server render are all independent
4. Latency is another cause of choppiness as there is no velocity smoothing, only direct position and look setting
