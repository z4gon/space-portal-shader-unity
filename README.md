# Space Portal Shader

Using **Stencil Buffer**, **AlphaToMask** and **Shuriken** Particle System in **Unity 2021.3.10f1**

## Screenshots

## Table of Contents

- [Implementation](#implementation)
  - [Modeling in Blender](#modeling-in-blender)
  - [Creating Textures in Affinity](#creating-textures-in-affinity)
  - [Portal Mask Shader](#portal-mask-shader)
  - [Hemisphere Shader](#hemisphere-shader)
  - [Tunnel Shader](#tunnel-shader)
  - [Glow Shader](#glow-shader)
  - [Particle System](#particle-system)
    - [Particles Shader](#particles-shader)

### References

- [Space Portal Shader tutorial by Jettelly](https://www.youtube.com/watch?v=toQIuCtk2pI)
- [Space Texture](https://unsplash.com/photos/qtRF_RxCAo0)

## Implementation

### Modeling in Blender

- Model a Hemisphere and a Tunnel.
- Make sure the UVs are mapped in a cylindrical mapping for the tube, so the vortex effect can be animated across the UV.y coordinates.

![Picture](./docs/1.jpg)
![Picture](./docs/2.jpg)

### Creating Textures in Affinity

- Black circle for masking the entrance to the portal.
- Gradient to make the glow inside the portal entrance.
- Stripes slightly inclined, matching in the sides, to make a helicoidal tunnel.

![Picture](./docs/3.jpg)

### Hemisphere Shader

### Tunnel Shader

### Glow Shader

### Particle Shader

#### Particles Shader
