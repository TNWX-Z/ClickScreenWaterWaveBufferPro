Shader "TNWX/CG/WaterWave_BufferSimulation_CG"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "black" {}
		_BufferA ("Buffer A", 2D) = "black" {}
	}
	CGINCLUDE
		#include "UnityCG.cginc"
		uniform float4 iMouse;
		uniform float time;
		//uniform int iFrame;
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
				float4 screenPos = ComputeScreenPos(o.vertex);
				o.uv = o.vertex.xy/o.vertex.w * 0.5 + 0.5;
				//o.uv.y = 1.-o.uv.y;
				#ifdef UNITY_UV_STARTS_AT_TOP
					o.uv.y = 1.-o.uv.y;
				#endif
				//o.uv.y = 1.-o.uv.y;
			return o;
		}
	ENDCG
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always
		Pass{
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			sampler2D _MainTex;
			sampler2D _BufferA;

			float GetVelocity(sampler2D _Tex,float2 uv){
				float2 p = uv;
				//if(p.x>1. || p.x<0. || p.y>1. || p.y<0.){
					//return -100.;
				//}
				return tex2D(_Tex, p).x;
			}
			//, UNITY_VPOS_TYPE screenPos : VPOS
			float4 frag (v2f i) : SV_Target
			{
			   	float3 e = float3(1./iScreenSize.xy,0.);
				float2 q = i.uv;//(i.uv/4.);//(4.*iScreenSize.x/iScreenSize.y);
				float4 c = tex2D(_BufferA, q);
				float p00 = c.y;
				float p0_1 = GetVelocity(_BufferA, q-e.zy);
				float p_10 = GetVelocity(_BufferA, q-e.xz);
				float p10 = GetVelocity(_BufferA, q+e.xz);
				float p01 = GetVelocity(_BufferA, q+e.zy);

				float p11 = GetVelocity(_BufferA, q+e.xy);
				float p1_1 = GetVelocity(_BufferA, q+float2(e.x,-e.y));
				float p_1_1 = GetVelocity(_BufferA, q-e.xy);
				float p_11 = GetVelocity(_BufferA, q+float2(-e.x,e.y));

				float d = 0.;
				if (iMouse.z > 0.) {
					d = length(iMouse.xy - q * iScreenSize.xy);
					d = smoothstep(30.5,5.5,d);
					d *= (sin(time*18.)+1.5)*100.0;
				}
				d += -p00 + (p0_1 + p_10 + p10 + p01 + (p11+p1_1+p_1_1+p_11))*.25;
				d *= 0.999;
				
				float a = 0.;
				//return float4(q,0.,0);
				return float4(d,c.xyz);
			}
			ENDCG
		}
	}
}
