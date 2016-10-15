Shader "Custom/Water Effect" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		
		_Color ("Color", Color) = (1,1,1,1)

		_Scale("Scale", float) = 1
		_Speed("Speed", float) = 1
		_Frequency("Frequency", float) = 1
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Lambert vertex:vert

		#pragma target 3.0

		sampler2D _MainTex;
		half4 _Color;
		float _Scale;
		float _Speed;
		float _Frequency;

		struct Input {
			float2 uv_MainTex;
			float3 customValue;
		};

		void vert(inout appdata_full v, out Input o) {
			UNITY_INITIALIZE_OUTPUT(Input, o);
			half offsetvert = ((v.vertex.x * v.vertex.x) + (v.vertex.z * v.vertex.z));
			half value = _Scale * sin(_Time.w * _Speed - offsetvert / _Frequency);
			v.vertex.y += value;
			o.customValue = value;
			
		}

		void surf (in Input IN, inout SurfaceOutput o) {
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Normal = IN.customValue;
		}
		ENDCG
	}
	FallBack "Diffuse"
}