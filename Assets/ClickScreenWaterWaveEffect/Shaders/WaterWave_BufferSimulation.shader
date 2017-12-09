Shader "TNWX/GLSL/WaterWave_BufferSimulation"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always
		Pass
		{
			GLSLPROGRAM
			uniform sampler2D _MainTex;
			uniform sampler2D _BufferA;
			uniform sampler2D _TestTex;
			uniform vec4 iMouse;
			uniform float time;
			//uniform float iFrame;
			uniform vec4 iScreenSize;
			
			#ifdef VERTEX
			varying vec2 uv;
			void main()
			{
				uv = gl_MultiTexCoord0.xy;
				gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
			}
			#endif
			
			#ifdef FRAGMENT
			varying vec2 uv;

			float GetVelocity(sampler2D _Tex,vec2 uv){
				vec2 p = uv;
				//if(p.x>1. || p.x<0. || p.y>1. || p.y<0.){
					//return -100.;
				//}
				return texture2D(_Tex, p).x;
			}

			void main()
			{
				vec3 e = vec3(vec2(1.)/iScreenSize.xy,0.);
				vec2 q = gl_FragCoord.xy/iScreenSize.xy;
				vec4 c = texture2D(_BufferA, q);
				float p00 = c.y;
				float p0_1 = GetVelocity(_BufferA, q-e.zy);
				float p_10 = GetVelocity(_BufferA, q-e.xz);
				float p10 = GetVelocity(_BufferA, q+e.xz);
				float p01 = GetVelocity(_BufferA, q+e.zy);

				float p11 = GetVelocity(_BufferA, q+e.xy);
				float p1_1 = GetVelocity(_BufferA, q+vec2(e.x,-e.y));
				float p_1_1 = GetVelocity(_BufferA, q-e.xy);
				float p_11 = GetVelocity(_BufferA, q+vec2(-e.x,e.y));

				float d = 0.;
				if (iMouse.z > 0.) {
					d = length(iMouse.xy - gl_FragCoord.xy);
					d = smoothstep(30.5,5.5,d);
					d *= (sin(time*18.)+1.5)*100.0;
				}
				d += -p00 + (p0_1 + p_10 + p10 + p01 + (p11+p1_1+p_1_1+p_11))*.25;
				d *= 0.998;
				//gl_FragColor = vec4(d,c.xyz);
				gl_FragColor = vec4(q,0.,1.);
			}
			#endif
			ENDGLSL
		}
	}
}
