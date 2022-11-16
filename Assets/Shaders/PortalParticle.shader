Shader "Portal/PortalParticle"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (0,0,0,1)
        _Intensity ("Intensity", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent+3" }

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
                fixed4 color        : COLOR;
            };

            struct Varyings
            {
                float4 positionHCS  : SV_POSITION;
                float2 uv           : TEXCOORD0;
                fixed4 color        : COLOR;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            fixed4 _Color;
            float _Intensity;

            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = UnityObjectToClipPos(IN.positionOS);
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                OUT.color = IN.color;
                return OUT;
            }

            fixed4 frag (Varyings IN) : SV_Target
            {
                // sample the texture
                fixed4 texel = tex2D(_MainTex, IN.uv);
                return texel * IN.color * _Color * _Intensity;
            }
            ENDCG
        }
    }
}
