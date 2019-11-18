// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/My First Shader" 
{

	Properties 
	{
		_Tint ("Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Texture", 2D) = "white" {}
	}

	SubShader 
	{

		Pass 
		{
			CGPROGRAM

			#pragma vertex MyVertexProgram
			#pragma fragment MyFragmentProgram

			#include "UnityCG.cginc"

			float4 _Tint;
			sampler2D _MainTex;
			float4 _MainTex_ST;

			struct VertexData
			{
				float4 position : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct Interpolators
			{
				float4 position : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			Interpolators MyVertexProgram (VertexData v) 
			{
				Interpolators i;
				i.position = UnityObjectToClipPos(v.position);
				i.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return i;
			}

			UnityLight CreateLight (Interpolators i)
			{
				UnityLight light;
				light.dir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);
				//float3 lightVec = _WorldSpaceLightPos0.xyz - i.worldPos;
				//float atteunation = 1 / (1 + (dot(lightVec, lightVec));
				UNITY_LIGHT_ATTENUATION(attenuation, 0, i.worldPos);
				light.color = _LightColor0.rgb * attenuation;
				light.ndotl = DotClamped(i.normal, light.dir);
				return light;
				
			}

		float4 MyFragmentProgram (Interpolators i) : SV_TARGET 
		{
			i.normal = normalize(i.normal);
			float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);

			float3 albedo = tex2D(_MainTex, i.uv).rgb * _Tint.rgb;

			float3 specularTint;
			float oneMinusReflectivity;
			albedo = DiffuseAndSpecularFromMetallic(albedo, _Metallic, specularTint, oneMinusReflectivity);

			UnityIndirect indirectLight;
			indirectLight.diffuse = 0;
			indirectLight.specular = 0;

			return UNITY_BRDF_PBS(albedo, specularTint, oneMinusReflectivity, _Smoothness, i.normal, viewDir, CreateLight(i), indirectLight);
		}			
		
		ENDCG
		}
	}
}