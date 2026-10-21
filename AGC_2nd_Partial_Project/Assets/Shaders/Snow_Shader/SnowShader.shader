Shader "ACG/SnowShader"
{
    Properties{
        _MainTex("Texture", 2D) = "white" {}
        _Snow("Snow Level", Range(-1,1)) = 0.5
        _SnowColor("Snow Color", Color) = (1,1,1,1)
        _SnowDirection("Snow Direction", Vector) = (0,1,0,0)
        _SnowDepth("Snow Depth", Range(0, 0.5)) = 0.05
    }

    SubShader{
        Tags { "RenderType"="Opaque" }

        CGPROGRAM
            #pragma surface surf Lambert

            struct Input{
                float2 uv_MainTex;
            };

            sampler2D _MainTex;

            void surf(Input IN, inout SurfaceOutput o){
                o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
            }
        ENDCG

        CGPROGRAM
            #pragma surface surf Lambert vertex:vert

            struct Input{
                float facing;
            };

            float _Snow;
            float4 _SnowColor;
            float4 _SnowDirection;
            float _SnowDepth;

            void vert(inout appdata_full v, out Input o){
                UNITY_INITIALIZE_OUTPUT(Input, o);

                float3 snowDir = normalize(_SnowDirection.xyz);

                o.facing = dot(snowDir, UnityObjectToWorldNormal(v.normal));

                if(o.facing >= _Snow){
                    v.vertex.xyz += v.normal * _SnowDepth;
                }
            }

            void surf(Input IN, inout SurfaceOutput o){
                clip(IN.facing - _Snow);
                o.Albedo = _SnowColor.rgb;
            }
        ENDCG
    }
    Fallback "Diffuse"
}