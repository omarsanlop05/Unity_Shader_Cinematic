Shader "ACG/Standard_PBR"{
	
	Properties{
		_mainColor("Main color", Color) = (1,1,1,1)
		_metallicTex("Metallic (R)", 2D) = "white" {}
        _metallic("Metallicity", Range(0,1)) = 0.0
	}

	SubShader{
		CGPROGRAM
			#pragma surface surf Standard

            float4 _mainColor;
			sampler2D _metallicTex;
			half _metallic;

			struct Input{
				float2 uv_metallicTex;
			};

			void surf(Input IN, inout SurfaceOutputStandard o){
				o.Albedo = _mainColor;
				o.Smoothness = tex2D(_metallicTex, IN.uv_metallicTex).r;
                o.Metallic = _metallic;
			}

		ENDCG
	}
	Fallback "Diffuse"
}