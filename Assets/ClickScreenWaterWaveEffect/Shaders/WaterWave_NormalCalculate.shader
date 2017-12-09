Shader "TNWX/GLSL/WaterWave_NormalCalculate"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Tex ("Tex", 2D) = "white" {}
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
			uniform sampler2D _Tex;
			//uniform sampler2D _BufferA;
			uniform vec4 iMouse;
			uniform float time;
			uniform int iFrame;
			uniform vec4 iScreenSize;
			#ifdef VERTEX
			out vec2 uv; 
			void main()
			{
				uv = gl_MultiTexCoord0.xy;
				gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
			}
			#endif
			
			#ifdef FRAGMENT
			in vec2 uv; 
			void main()
			{
				vec2 R = iScreenSize.xy;
				vec2 q = gl_FragCoord.xy/R;
				vec3 e = vec3(1./R,0.0);
				float p10 = texture2D(_BufferA, q-e.zy).x;
				float p01 = texture2D(_BufferA, q-e.xz).x;
				float p21 = texture2D(_BufferA, q+e.xz).x;
				float p12 = texture2D(_BufferA, q+e.zy).x;
				vec3 grad = normalize(vec3(p21 - p01,p12 - p10 , 1.));
				
				//gl_FragColor = texture2D(_MainTex, q);
				gl_FragColor = (grad.rgbb+1.0)/2.;
				//gl_FragColor = texture2D(_Tex,q + grad.xy);
			}
			#endif
			ENDGLSL

		}
	}
}
