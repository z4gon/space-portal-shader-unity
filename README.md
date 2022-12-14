# Space Portal Shader

Using **Stencil Buffer**, **AlphaToMask** and **Shuriken** Particle System in **Unity 2021.3.10f1**

## Screenshots

![Picture](./docs/9.jpg)


https://user-images.githubusercontent.com/4588601/202121232-e5eef7d5-0c2f-414a-8a9e-f9ec9e97899b.mp4


## Table of Contents

- [Implementation](#implementation)
  - [Modeling in Blender](#modeling-in-blender)
  - [Creating Textures in Affinity](#creating-textures-in-affinity)
  - [Portal Mask Shader](#portal-mask-shader)
  - [Tunnel Shader](#tunnel-shader)
  - [Hemisphere Shader](#hemisphere-shader)
  - [Glow Shader](#glow-shader)
  - [Particle System](#particle-system)
    - [Particles Shader](#particles-shader)
      - [Color Over Time](#color-over-time)

### References

- [Space Portal Shader tutorial by Jettelly](https://www.youtube.com/watch?v=toQIuCtk2pI)
- [Space Texture](https://unsplash.com/photos/qtRF_RxCAo0)
- [AlphaTest before writing to the Stencil Buffer](https://answers.unity.com/questions/759345/is-it-possible-to-alphatest-prior-to-writing-to-th.html)

## Implementation

### Modeling in Blender

- Model a Hemisphere and a Tunnel.
- Make sure the UVs are mapped in a cylindrical mapping for the tube, so the vortex effect can be animated across the UV.y coordinates.

![Picture](./docs/1.jpg)
![Picture](./docs/2.jpg)

### Creating Textures in Affinity

- Circle for masking the entrance to the portal.
- Gradient to make the glow inside the portal entrance.
- Stripes slightly inclined, matching in the sides, to make a helicoidal Tunnel.

![Picture](./docs/3.jpg)

### Portal Mask Shader

- Use `RenderType` `Transparent` and `Queue` `Transparent`, to be able to use the transparency in the alpha channel.
- Use `ZWrite Off` to make this truly transparent, and not write to the depth buffer, affecting other shaders.
- Use `Blend SrcAlpha OneMinusSrcAlpha` for traditional transparency.
- Make all the pixels in the shader write a custom value to the **Stencil Buffer**.
- `discard` pixels that with alpha close to zero, to prevent transparent pixels from writing to the stencil buffer.
- The **Stencil Buffer** is preferable over doing a `ZTest` approach, so other objects can get rendered in front of the portal correctly.

```c
Tags { "RenderType"="Transparent" "Queue"="Transparent" }

ZWrite Off

Blend SrcAlpha OneMinusSrcAlpha

Stencil
{
    Ref 2
    Comp Always
    Pass Replace
}
```

```c
fixed4 frag (Varyings IN) : SV_Target
{
    // sample the texture
    fixed4 col = tex2D(_MainTex, IN.uv);

    if (col.a < 0.1) discard;

    return fixed4(0, 0, 0, col.a);
}
```

![Picture](./docs/4.jpg)

### Tunnel Shader

- Parametrize the Color, Intensity, Fade Start, Fade Thickness and Velocity.

```c
_MainTex ("Texture", 2D) = "white" {}
_Color ("Color", Color) = (0,0,0,1)
_Velocity ("Velocity", Float) = 1
_Intensity ("Intensity", Float) = 1
_FadePosition ("Fade Position", Range(0.0, 1.0)) = 0.5
_FadeThickness ("Fade Thickness", Range(0.0, 1.0)) = 0.2
```

- Use `RenderType` `Transparent` to be able to use the transparency in the alpha channel.
- Use `Queue` `Transparent+2` to make it render in front of the mask by two levels.
- `Cull Front` to only render the inner faces of the tunnel.
- Use `ZWrite Off` to make this truly transparent, and not write to the depth buffer, affecting other shaders.
- Use `Blend SrcAlpha One` for additive transparency.
- Do a `Stencil Test` against the **Stencil Buffer**, check if the value is equals to 2, which is the value set by the shader that does the mask.

```c
Tags { "RenderType"="Transparent" "Queue"="Transparent+2" }

Cull Front

ZWrite Off

Blend SrcAlpha One

Stencil
{
    Ref 2
    Comp Equal
}
```

- Animate the tunnel across the **UV.y** coordinate.
- Use **\_Time** to displace the UV coordinates.
- **smoothstep()** to determine the fade out of the tunnel.
- Use the parametrized **Velocity**, **Color** and **Intensity**.

```c
fixed4 frag (Varyings IN) : SV_Target
{
    // offset across y coordinate in uvs to animate the helicoidal tunnel
    float2 uv = float2(IN.uv.x, IN.uv.y + (_Time.y * _Velocity));

    // sample the texture
    fixed4 col = tex2D(_MainTex, uv);
    col = col * _Color * _Intensity;

    // fade out towards the higher UV.y values
    float alpha = col.a * smoothstep(_FadePosition, _FadePosition + _FadeThickness, IN.uv.y);

    return fixed4(col.rgb, alpha);
}
```

![Picture](./docs/5.jpg)

### Hemisphere Shader

- Use `RenderType` `Opaque`.
- Use `Queue` `Transparent+1` to make it render in between the mask and the tunnel.
- `Cull Front` to only render the inner faces of the hemisphere.
- Do a `Stencil Test` against the **Stencil Buffer**, check if the value is equals to 2, which is the value set by the shader that does the mask.

```c
Tags { "RenderType"="Opaque" "Queue"="Transparent+1" }

Cull Front

Stencil
{
    Ref 2
    Comp Equal
}
```

- Use the parametrized **Velocity** and **Color**.

```c
fixed4 frag (Varyings IN) : SV_Target
{
    // sample the texture
    fixed4 col = tex2D(_MainTex, IN.uv + (_Time.y * _Velocity));
    return col * _Color;
}
```

![Picture](./docs/6.jpg)

### Glow Shader

- Use `RenderType` `Transparent` to be able to use the transparency in the alpha channel.
- Use `Queue` `Transparent+3` to render it on top of everything.
- Use `ZWrite Off` to make this truly transparent, and not write to the depth buffer, affecting other shaders.
- Use `Blend SrcAlpha One` for additive transparency.

```c
Tags { "RenderType"="Transparent" "Queue"="Transparent+3" }

ZWrite Off

Blend SrcAlpha One
```

![Picture](./docs/7.jpg)

### Particle System

- Add a particle system that spawns particles inside the tunnel.
- Adjust velocity, force over time, color over time.

#### Particles Shader

- Use `RenderType` `Transparent` to be able to use the transparency in the alpha channel.
- Use `Queue` `Transparent+3` to render it on top of everything.
- Use `ZWrite Off` to make this truly transparent, and not write to the depth buffer, affecting other shaders.
- Use `Blend SrcAlpha One` for additive transparency.
- Do a `Stencil Test` against the **Stencil Buffer**, check if the value is equals to 2, which is the value set by the shader that does the mask.

```c
Tags { "RenderType"="Opaque" "Queue"="Transparent+1" }

Cull Front

Stencil
{
    Ref 2
    Comp Equal
}
```

##### Color Over Time

- The Particle System needs a defined property in the vertex for the color.
- That way the `Color Over Time` value gets passed down to the vertex and fragment shaders.
- It then can be multiplied by our frag calculated color.

```c
struct Attributes
{
    ...
    fixed4 color        : COLOR;
};

struct Varyings
{
    ...
    fixed4 color        : COLOR;
};


Varyings vert (Attributes IN)
{
    ...
    OUT.color = IN.color;
    ...
}

fixed4 frag (Varyings IN) : SV_Target
{
    ...
    // sample the texture
    fixed4 texel = tex2D(_MainTex, IN.uv);
    return texel * IN.color * _Color * _Intensity;
}
```

![Picture](./docs/8.jpg)
