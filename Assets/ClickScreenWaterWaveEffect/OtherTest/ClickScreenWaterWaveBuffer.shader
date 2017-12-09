Shader "PK365/TNWX/ClickScreenWaterWaveBuffer"
{
	Properties
	{
		_MainTex ("tex2D", 2D) = "white" {}
	}

	CGINCLUDE
		#include "UnityCG.cginc"
		//sampler2D _MainTex;
		sampler2D _BufferA;
		float4 iMouse;
		int iFrame;


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
		Cull Off ZWrite Off ZTest Always
		Pass{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			fixed4 frag (v2f i) : SV_Target
			{
			   	float3 e = float3(_ScreenParams.zw-1,0.);
			   	float2 q = i.uv;//fragCoord.xy/iResolution.xy;
			    
			   	float4 c = tex2D(_BufferA, q);
			    
			   	float p11 = c.y;
			   	float p10 = tex2D(_BufferA, q-e.zy).x;
			   	float p01 = tex2D(_BufferA, q-e.xz).x;
			   	float p21 = tex2D(_BufferA, q+e.xz).x;
			   	float p12 = tex2D(_BufferA, q+e.zy).x;
			   	
			   	float d = 0.;
			    
			   	if (iMouse.z > 0.) 
			   	{
			    	d = smoothstep(4.5,.5,length(iMouse.xy - i.uv*_ScreenParams.xy));
			   	}

			   	d += -(p11-.5)*2. + (p10 + p01 + p21 + p12 - 2.);
			   	d *= .99; // dampening
			   	d *= float(iFrame>=2); // clear the buffer at iFrame < 2
			   	d = d*.5 + .5;
			   
			   	// Put previous state as "y":
			   	float4 col = float4(d, c.x, 0, 0);
				return col*0.+1.;
			}
			ENDCG
		}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
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
				float4 c = tex2D(_BufferA, uv*2. + grad.xy*0.35);
				float3 light = normalize(float3(0.2,-0.5,0.7));
				float diffuse = dot(grad,light);
				float spec = pow(max(0.,-reflect(light,grad).z),32.);

				float4 col = lerp(c,float4(0.7,0.8,0.1,1.),0.25)*max(diffuse,0.0) + spec;
				return col*0.+1.;
			}
			ENDCG
		}


	}
}
