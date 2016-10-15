Shader "Custom/Toon" {
	Properties {
		_MainTint ("Diffuse Tint", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_NormalTex("Normal Map", 2D) = "white" {}

		_SpecularColor ("Specular Color", Color) = (1,1,1,1)
		_SpecPower ("Specular Power", Range(0,100)) = 1

		_ReflectionCoefficient ("Reflection Coefficient", Range(0,1)) = 0.3
		_ToonLevels ("Toon Levels", Range(1, 10)) = 4

		_OutlineColor ("Outline Color", Color) = (0,0,0,1)
		_Outline("Outline width", Range(.002, 0.03)) =.005
	}
	SubShader {
		//Tags { "RenderType"="Opaque" }
				
		CGPROGRAM
		#pragma surface surf Phong

		sampler2D _MainTex;
		sampler2D _NormalTex;

		float4 _MainTint;

		float4 _SpecularColor;
		float _SpecPower;

		float _ReflectionCoefficient;
		float _ToonLevels;

		inline half4 LightingPhong(SurfaceOutput a, fixed3 lightDir, half3 viewDir, fixed atten) {

			float NdotL = max(dot(a.Normal, lightDir), 0);
			float3 reflectance = 2.0f * NdotL * a.Normal - lightDir;
			float3 c_l = _LightColor0.rgb * NdotL;
			fixed4 c_r = _MainTint / 3.14f;
			float c_p = _ReflectionCoefficient * (_SpecPower + 2) / (2 * 3.14f);
			
			_ToonLevels = floor(_ToonLevels);
			float scaleFactor = 1.0f / _ToonLevels;
			
			float3 ambient = c_r * floor(max(NdotL, 0) * _ToonLevels) * _LightColor0.rgb * scaleFactor;
			float3 diffuse = c_r * floor(max(NdotL, 1) * _ToonLevels) * _LightColor0.rgb * NdotL * scaleFactor;

			float specMask;
			if(pow(dot(normalize(reflectance), normalize(viewDir)), _SpecPower) > 0.5) specMask = 1.0f;
			else specMask = 0.0f;

			float3 spec = max(c_p * c_l * max(pow(dot(normalize(reflectance), normalize(viewDir)), _SpecPower), 0) * _SpecularColor * specMask, 0);

			fixed4 c;
			c.rgb = spec + ambient + diffuse;
			c.a = 1.0;

			return c;
		}

		struct Input {
			float2 uv_MainTex;
		};

		void surf (Input IN, inout SurfaceOutput o) {
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _MainTint;
            o.Albedo = c.rgb;
			o.Normal = UnpackNormal( tex2D (_NormalTex, IN.uv_MainTex));
			//o.Normal = tex2D(_NormalTex, IN.uv_MainTex);
			o.Alpha = c.a;
        }

		ENDCG
		UsePass "Outlined/Silhouette Only/BASE"
		UsePass "Outlined/Silhouette Only/OUTLINE"
	}
	FallBack "Diffuse"
}