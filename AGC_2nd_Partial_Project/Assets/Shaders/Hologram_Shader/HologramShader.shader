Shader "ACG/HologramShader"
{
    Properties
    {
        _rimColor("Rim Color", Color) = (1,1,1,1)
        _rimPower("Rim intensity", Range(0,5)) = 1
    }

    SubShader{

        Tags{
            "Queue" = "Transparent"
        }

        Pass{
            ZWrite On
            ColorMask 0
        }

        CGPROGRAM
            #pragma surface surf Lambert alpha:fade

            float4 _rimColor;
            half _rimPower;

            struct Input{
                float3 viewDir;
            };

            void surf(Input IN, inout SurfaceOutput o){
                half rim = 1- dot(normalize(IN.viewDir), o.Normal); //-1 a 1
                //o.Emission = _rimColor.rgb - (rim*_rimPower);
                o.Emission = _rimColor.rgb * (pow(rim, _rimPower));
                o.Alpha = (pow(rim, _rimPower));
            }
        ENDCG
    }
    Fallback "Difuse"
}