# This is a work in progress

Prp-drone is an FPV drone simulator based on Xinerki's [kgv-drone](https://github.com/Xinerki/kgv-drone) script. We've added a custom animations, props, and effects for the operator and so that other drone operators can single out enemy operators! 


Additionally, we've modified the emp drone into a "C4 Drone" and provided a shockwave non-lethal attack for the LSPD variant!


**Features:**
- Reskinned EMP Drone
- Explodes on contact (WIP)
- Animation with custom props for operator while in use (WIP)
- Realistic Static and Screen animations

**Dependencies:**
- ox_lib
- ox_inventory (for item use)

**Ox Inventory Items:**

```
['policedrone'] = {
    label = 'Police FPV Drone',
    weight = 15000,
    stack = false,
    close = true,
    client = {
        export = 'prpdrone.usePoliceDrone'
    },
},

['bombdrone'] = {
    label = 'C4 FPV Drone',
    weight = 20000,
    stack = false,
    close = true,
    client = {
        export = 'prpdrone.useDrone'
    },
},

```

---
**Credits**
- Xinerki for creating the base resource
- [FalsehopeDesigns](https://falsehopedesigns.tebex.io/) for converting the headset to work with FiveM, [original model by Vitamin](https://sketchfab.com/3d-models/vr-headset-free-model-51b8dbff65e247979f068914f6197909) - Please note the headset model is used under a [CC BY 4.0 license](https://creativecommons.org/licenses/by/4.0/)
- [Popcorn Roleplay](https://discord.gg/popcornroleplay) for Testing, come try out our Roleplay community
- [Dark Animations](https://www.gta5-mods.com/users/Darks%20Animations) for the controller/base animation
- Drone retextured by PrinceAlbert (replace texture for the Arena EMP drone)
