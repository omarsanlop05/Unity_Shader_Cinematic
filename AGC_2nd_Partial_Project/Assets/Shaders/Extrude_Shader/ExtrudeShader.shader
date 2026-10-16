Shader "ACG/ExtrudeShader"
{
    Properties
    {
        _MainTex("Textura", 2D) = "white" {}
        _ExtrudeAmmount("Extrude", Range(-1,1)) = 0.01
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
            };

            float _ExtrudeAmmount;
            sampler2D _MainTex;

            void vert(inout appdata v){
                float3 wave = (sin(_Time.y * 2) + 1) * 0.5;
                v.vertex.xyz += v.normal * _ExtrudeAmmount * wave;
            }

            void surf(Input IN, inout SurfaceOutput o){
                o.Albedo = tex2D(_MainTex, IN.uv_MainTex);
            }

        ENDCG
    }
    Fallback "Diffuse"
}
