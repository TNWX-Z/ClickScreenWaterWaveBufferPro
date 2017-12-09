Shader "TNWX/CG/WaterWave_NormalCalculate_CG"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "black" {}
		_Tex ("Tex", 2D) = "black" {}
		_BufferA ("BufferA", 2D) = "black" {}
	}
	CGINCLUDE
		#include "UnityCG.cginc"
		uniform float4 iMouse;
		uniform float time;
		//uniform float iFrame;
		uniform float4 iScreenSize;

		struct v2f
		{
			float2 uv : TEXCOORD0;
			float4 vertex : SV_POSITION;
		};

		v2f vert (float4 vertex:POSITION,float2 coord:TEXCOORD0)
		{
			v2f o;
				o.vertex = UnityObjectToClipPos(vertex);
				o.uv = coord;
			return o;
		}
	ENDCG
	SubShader
	{
		Pass
		{
			Blend Off
			Cull Off ZWrite Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			uniform sampler2D _MainTex;
			uniform sampler2D _BufferA;
			uniform sampler2D _Tex;
			
			fixed4 frag (v2f i) : SV_Target
			{
				float2 uv = i.uv;
				
				float2 q = i.uv;
				float3 e = float3(_ScreenParams.zw-1.0,0.0);
				float p10 = tex2D(_BufferA, q-e.zy).x;
				float p01 = tex2D(_BufferA, q-e.xz).x;
				float p21 = tex2D(_BufferA, q+e.xz).x;
				float p12 = tex2D(_BufferA, q+e.zy).x;

				float3 grad = normalize(float3(p21 - p01,p12 - p10, 1.));
				
				//return (grad.rgbb+1.0)/2.;
				//return tex2D(_BufferA,uv);
				return tex2D(_Tex,uv + grad.xy);
			}
			ENDCG
		}
	}
}
