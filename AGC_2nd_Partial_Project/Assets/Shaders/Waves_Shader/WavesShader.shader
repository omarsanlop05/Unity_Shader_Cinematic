Shader "ACG/WavesShader"
{
    Properties{
        _MainTex("Main texture", 2D) = "white" {}
        _Freq("Wave Frequenct", Range(0,5)) = 3
        _Speed("Wave Speed", Range(0,100)) = 10
        _TexSpeed("Texture Speed", Range(0,1)) = 0.1
        _Apmlitude("Wave Amplitude", Range(0,1)) = 0.5
    }

    SubShader
    {
        CGPROGRAM

            #pragma surface surf Lambert vertex:vert
            
            struct Input{
                float2 uv_MainTex;
            };

            struct appdata{
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
                float4 texcoord1 : TEXCOORD1;
                float4 texcoord2 : TEXCOORD2;
            };

            sampler2D _MainTex;
            float _Freq;
            float _Speed;
            float _Apmlitude;
            float _TexSpeed;

            void vert(inout appdata v){
                float t = _Time * _Speed;
                float waveHeight = sin(t + v.vertex.x * _Freq) * _Apmlitude + 
                                   sin(t + v.vertex.z * _Freq) * _Apmlitude;
                v.vertex.y += waveHeight;
                v.normal = normalize(float3(v.normal.x + waveHeight, v.normal.y, v.normal.z));
                v.texcoord.xy += _TexSpeed * _Time.y;
            }

            void surf(Input IN, inout SurfaceOutput o){
                o.Albedo.rgb = tex2D(_MainTex, IN.uv_MainTex);
            }

        ENDCG
    }
    FallBack "Diffuse"
}