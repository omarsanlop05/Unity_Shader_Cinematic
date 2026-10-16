Shader "ACG/StandardSpecular_PBR"{
	
	Properties{
		_mainColor("Main color", Color) = (1,1,1,1)
		_metallicTex("Metallic (R)", 2D) = "white" {}
        _SpecColor("Specular Color", Color) = (1,1,1,1)
	}

	SubShader{
		CGPROGRAM
			#pragma surface surf StandardSpecular

            float4 _mainColor;
			sampler2D _metallicTex;

			struct Input{
				float2 uv_metallicTex;
			};

			void surf(Input IN, inout SurfaceOutputStandardSpecular o){
				o.Albedo = _mainColor;
				o.Smoothness = tex2D(_metallicTex, IN.uv_metallicTex).r;
                o.Specular = _SpecColor;
			}

		ENDCG
	}
	Fallback "Difuse"
}