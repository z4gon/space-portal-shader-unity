Shader "Portal/PortalHemisphere"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Velocity ("Velocity", Float) = 1
        _Color ("Color", Color) = (0,0,0,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent+1" }

        Cull Front

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
            float _Velocity;
            fixed4 _Color;

            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = UnityObjectToClipPos(IN.positionOS);
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                return OUT;
            }

            fixed4 frag (Varyings IN) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, IN.uv + (_Time.y * _Velocity));
                return col * _Color;
            }
            ENDCG
        }
    }
}
