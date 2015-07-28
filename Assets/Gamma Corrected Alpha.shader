Shader "Unlit/Gamma Corrected Alpha"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        [KeywordEnum(None, GammaToLinear, LinearToGamma)]
        _alphaMode ("Alpha Conversion Mode", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM

            #pragma shader_feature _ _ALPHAMODE_GAMMATOLINEAR _ALPHAMODE_LINEARTOGAMMA

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            half gamma_to_linear(half c)
            {
                return c * (c * (c * 0.305306011 + 0.682171111) + 0.012522878);
            }

            half linear_to_gamma(half c)
            {
                return max(1.055 * pow(c, 0.416666667) - 0.055, 0.0);
            }

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
#if _ALPHAMODE_GAMMATOLINEAR
                col.a = gamma_to_linear(col.a);
#elif _ALPHAMODE_LINEARTOGAMMA
                col.a = linear_to_gamma(col.a);
#endif
                return col;
            }

            ENDCG
        }
    }
}
