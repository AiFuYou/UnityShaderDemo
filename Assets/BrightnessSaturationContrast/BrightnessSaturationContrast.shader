Shader "Hidden/BrightnessSaturationContrast"
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
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            float _Brightness;
            float _Saturation;
            float _Contrast;

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                // 亮度
                col.rgb *= _Brightness;

                // 饱和度
                fixed gray = Luminance(col.rgb);
                col.rgb = lerp(fixed3(gray, gray, gray), col.rgb, _Saturation);

                // 对比度
                fixed3 sat = fixed3(0.5, 0.5, 0.5);
                col.rgb = lerp(sat, col.rgb, _Contrast);

                return col;
            }
            ENDCG
        }
    }
}
