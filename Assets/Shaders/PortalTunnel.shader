Shader "Portal/PortalTunnel"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (0,0,0,1)
        _Velocity ("Velocity", Float) = 1
        _Intensity ("Intensity", Float) = 1
        _FadePosition ("Fade Position", Range(0.0, 1.0)) = 0.5
        _FadeThickness ("Fade Thickness", Range(0.0, 1.0)) = 0.2
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent+2" }

        Cull Front

        ZWrite Off

        Blend SrcAlpha One

        Stencil
        {
            Ref 2
            Comp Equal
        }

        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct Attributes
            {
                float4 positionOS   : POSITION;
                float2 uv           : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS  : SV_POSITION;
                float2 uv           : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            fixed4 _Color;
            float _Velocity;
            float _Intensity;
            float _FadePosition;
            float _FadeThickness;

            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = UnityObjectToClipPos(IN.positionOS);
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                return OUT;
            }

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
            ENDCG
        }
    }
}
