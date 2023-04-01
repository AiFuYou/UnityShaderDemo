Shader "Hidden/FrostedGlass"
{
    Properties
    {
        _FrostTex ("Texture", 2D) = "white" {}
        _FrostIntensity ("FrostIntensity", float) = 1
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 uvgrab : TEXCOORD01;
                float4 vertex : SV_POSITION;
            };

            sampler2D _GrabBlurTexture_0;
			
			v2f vert (appdata v) {
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uvgrab = ComputeGrabScreenPos(o.vertex); // 这个就是获取模型 顶点位置 在屏幕空间的值, 在 [0, 1] 区间, 屏幕空间位置
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target {
				return tex2Dproj(_GrabBlurTexture_0, i.uvgrab); // 用 屏幕空间位置 采样 模糊效果 的纹理
			}

            ENDCG
        }
    }
}
