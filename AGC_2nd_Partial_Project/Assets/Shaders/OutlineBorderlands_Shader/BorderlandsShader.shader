Shader "ACG/BorderlandsShader"
{

    Properties{
        _MainTex("Texture", 2D) = "white" {}
        _Outline("Outline Width", Range(0.002, 1)) = 0.05
        _OutlineColor("Outline Color", Color) = (1,1,1,1)
    }

    SubShader{
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

        Pass{
            Cull Front
            CGPROGRAM

                #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"

                struct appdata{
                    float4 vertex : POSITION;
                    float3 normal : NORMAL;

                };

                struct v2f{
                    float4 pos : SV_POSITION;
                    fixed4 color : COLOR;
                };

                float _Outline;
                float4 _OutlineColor;

                v2f vert(appdata v){
                    v2f o;

                    float3 dirFromCenter = normalize(v.vertex.xyz);
                    float3 extrudedPos = v.vertex.xyz + dirFromCenter * _Outline;

                    o.pos = UnityObjectToClipPos(float4(extrudedPos, 1.0));
                    o.color = _OutlineColor;
                    return o;
                }

                fixed4 frag(v2f i) : SV_Target{
                    return i.color;
                }
                
            ENDCG
        }
    }
    FallBack "Diffuse"
}