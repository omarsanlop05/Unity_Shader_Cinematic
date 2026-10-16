Shader "ACG/ToonShader"{

    Properties{
        _Color("Color", Color) = (1,1,1,1)
        _RampTex("Ramp Texture",2D) = "white" {}
        _MainTex("Main Texture",2D) = "white" {}
    }

    Subshader{
        CGPROGRAM
            #pragma surface surf ToonRamp


            float4 _Color;
            sampler2D _RampTex;
            sampler2D _MainTex;


            float4 LightingToonRamp(SurfaceOutput s, half3 lightDir, half atten){
                float diff = max(0,dot(s.Normal,lightDir));
                float h = diff * 0.5 + 0.5;

                float2 hw = h;
                float3 rampColor = tex2D(_RampTex,hw).rgb;

                float4 c;
                c.rgb = s.Albedo * _LightColor0.rgb * (rampColor);
                c.a = s.Alpha;
                return c;
            }

            struct Input{
                float2 uv_MainTex;
            };

            void surf(Input IN, inout SurfaceOutput o){
                o.Albedo = tex2D(_MainTex,IN.uv_MainTex);
            }
        ENDCG
    }
    Fallback "Diffuse"
}
