Shader "Demo/FrostedGlassGrabPassDualKawase"
{
	Properties
	{
		_Offset ("Offset", float) = 1.0
	}
	
	SubShader
	{
		Tags
        {
            "Queue"="Transparent"
            "IgnoreProjection"="True"
            "RenderType"="Transparent"
        }
        
        Cull Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
		
		CGINCLUDE

		#include "UnityCG.cginc"
		
		sampler2D _GrabTexture;
		float4 _GrabTexture_ST;
		float2 _GrabTexture_TexelSize;
		half _Offset;

		struct AttributesDefault
		{
		    float3 vertex : POSITION;
			float2 uv : TEXCOORD0;
		};
		
		struct v2f_DownSample
		{
			float4 vertex: SV_POSITION;
			float2 uv: TEXCOORD0;
			float4 uv01: TEXCOORD1;
			float4 uv23: TEXCOORD2;
		};
		
		
		struct v2f_UpSample
		{
			float4 vertex: SV_POSITION;
			float4 uv01: TEXCOORD1;
			float4 uv23: TEXCOORD2;
			float4 uv45: TEXCOORD3;
			float4 uv67: TEXCOORD4;
		};
		
		v2f_DownSample Vert_DownSample(AttributesDefault v)
		{
			v2f_DownSample o;
			o.vertex = UnityObjectToClipPos(v.vertex);
			float2 uv = ComputeGrabScreenPos(o.vertex);
			_GrabTexture_TexelSize *= 0.5;
			float offset = 1 + _Offset;
			o.uv = uv;
			o.uv01.xy = uv + _GrabTexture_TexelSize * float2(1, 1) * offset;//top right
			o.uv01.zw = uv + _GrabTexture_TexelSize * float2(-1, -1) * offset;//bottom left
			o.uv23.xy = uv + _GrabTexture_TexelSize * float2(-1, 1) * offset;//top left
			o.uv23.zw = uv + _GrabTexture_TexelSize * float2(1, -1) * offset;//bottom right
			return o;
		}
		
		half4 Frag_DownSample(v2f_DownSample i): SV_Target
		{
			half4 sum = tex2D(_GrabTexture, i.uv);
			sum += tex2D(_GrabTexture, i.uv01.xy);
			sum += tex2D(_GrabTexture, i.uv01.zw);
			sum += tex2D(_GrabTexture, i.uv23.xy);
			sum += tex2D(_GrabTexture, i.uv23.zw);
			
			return sum * 0.2;
		}
		
		v2f_UpSample Vert_UpSample(AttributesDefault v)
		{
			v2f_UpSample o;
			o.vertex = UnityObjectToClipPos(v.vertex);
			float2 uv = ComputeGrabScreenPos(o.vertex);
			_GrabTexture_TexelSize *= 0.5;
			float offset = 1 + _Offset;
			o.uv01.xy = uv + _GrabTexture_TexelSize * float2(-3, -3) * offset;
			o.uv01.zw = uv + _GrabTexture_TexelSize * float2(-3, 3) * offset;
			o.uv23.xy = uv + _GrabTexture_TexelSize * float2(-1, 3) * offset;
			o.uv23.zw = uv + _GrabTexture_TexelSize * float2(-1, 1) * offset;
			o.uv45.xy = uv + _GrabTexture_TexelSize * float2(3, -3) * offset;
			o.uv45.zw = uv + _GrabTexture_TexelSize * float2(3, 3) * offset;
			o.uv67.xy = uv + _GrabTexture_TexelSize * float2(1, -3) * offset;
			o.uv67.zw = uv - _GrabTexture_TexelSize * float2(3, -2) * offset;

			return o;
		}
		
		half4 Frag_UpSample(v2f_UpSample i): SV_Target
		{
			half4 sum = 0;
			sum += tex2D(_GrabTexture, i.uv01.xy);
			sum += tex2D(_GrabTexture, i.uv01.zw);
			sum += tex2D(_GrabTexture, i.uv23.xy);
			sum += tex2D(_GrabTexture, i.uv23.zw);
			sum += tex2D(_GrabTexture, i.uv45.xy);
			sum += tex2D(_GrabTexture, i.uv45.zw);
			sum += tex2D(_GrabTexture, i.uv67.xy);
			sum += tex2D(_GrabTexture, i.uv67.zw);
			return sum * 0.125;
		}

		ENDCG
		
		Cull Off ZWrite Off ZTest Always
		
		GrabPass {}
		Pass
		{
			CGPROGRAM
			
			#pragma vertex Vert_DownSample
			#pragma fragment Frag_DownSample
			
			ENDCG
		}
		
		GrabPass {}
		Pass
		{
			CGPROGRAM
			
			#pragma vertex Vert_DownSample
			#pragma fragment Frag_DownSample
			
			ENDCG
		}
		
		GrabPass {}
		Pass
		{
			CGPROGRAM
			
			#pragma vertex Vert_DownSample
			#pragma fragment Frag_DownSample
			
			ENDCG
		}
		
		GrabPass {}
		Pass
		{
			CGPROGRAM
			
			#pragma vertex Vert_UpSample
			#pragma fragment Frag_UpSample
			
			ENDCG
		}
		
		GrabPass {}
		Pass
		{
			CGPROGRAM
			
			#pragma vertex Vert_UpSample
			#pragma fragment Frag_UpSample
			
			ENDCG
		}
		
		GrabPass {}
		Pass
		{
			CGPROGRAM
			
			#pragma vertex Vert_UpSample
			#pragma fragment Frag_UpSample
			
			ENDCG
		}
	}
}
