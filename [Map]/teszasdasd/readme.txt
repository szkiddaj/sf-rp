Resource: Shader_ped_wall v0.1.0
Author: Ren712
contact: knoblauch700@o2.pl
update 0.1.0
-Set AlphaTestEnable back to true
-post_edge.fx is drawn only when effect is on
update 0.0.9
-Set AlphaTestEnable to false
update 0.0.8
-Minor optimization for the MRT effect.
update 0.0.7
-Disabling ZBuffer for the peds instead of multiplying the Z dimension.
update 0.0.6
-Added render to texture glow variant. If hardware doesn't support MRT in shaders then
the effect will fallback to the basic glow effect.
update 0.0.5
-Cleaned up shader code a bit
-Reconfigured the effect
update 0.0.4
-Exported the 'clear range fix' code into shader. 
It should work and react faster.
update 0.0.3
-Made sure that all the shader elements are destroyed and the timer is
 killed when effect is switched off
update 0.0.2
-added switching event, enable the effect by /sPedWall
-hold a key to see the effect ('o' is default)
-the effect is visible on closer range
-using a timer instead of onClientRender (FPS friendly)

This effect lets you see silhouettes of players
hidden behind walls. Sort of wallh&^% i mean an effect
often seen in zombe survival games. I mean close to it.
Images give enough description.

You can modify the files as you wish. Just leave this readme.

