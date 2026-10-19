Shader "ACG/OutlineShader"
{
    Properties{
        _MainTex("Texture", 2D) = "white" {}
        _Outline("Outline Width", Range(0.002, 1)) = 0.05
        _OutlineColor("Outline Color", Color) = (1,1,1,1)
    }

    SubShader{

        Tags{"Queue" = "Transparent"}

        ZWrite Off
        CGPROGRAM

            #pragma surface surf Lambert vertex:vert

            struct Input{
                float2 uv_MainTex;
            };

            struct appdata{
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };

            float _Outline;
            float4 _OutlineColor;

            void vert(inout appdata v){
                float3 dirFromCenter = normalize(v.vertex.xyz);
                v.vertex.xyz += dirFromCenter * _Outline;
            }

            void surf(Input IN, inout SurfaceOutput o){
                o.Emission = _OutlineColor.rgb;
            }

        ENDCG
        
        ZWrite On
        CGPROGRAM

            #pragma surface surf Lambert

            struct Input{
                float2 uv_MainTex;
            };

            sampler2D _MainTex;

            void surf(Input IN, inout SurfaceOutput o){
                o.Albedo = tex2D(_MainTex, IN.uv_MainTex);
            }

        ENDCG
    }

    FallBack "Diffuse"
}
