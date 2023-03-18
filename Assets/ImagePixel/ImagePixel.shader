Shader "Demo/ImagePixel"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _PixelSize ("DownSample", int) = 1
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
            float4 _MainTex_TexelSize;
            float _PixelSize;

            fixed4 frag (v2f i) : SV_Target
            {
                // 对图像进行分块，每块的颜色使用当前块的中心点像素颜色填充
                // 也可以使用当前块的所有像素计算出一个值来填充，但这样会增加计算量，以上的算法已经可以得到比较好的效果
                float2 newUV = floor(i.uv * _MainTex_TexelSize.zw / _PixelSize + 0.5) * _PixelSize;
                return tex2D(_MainTex, newUV / _MainTex_TexelSize.zw);
            }
            ENDCG
        }
    }
}
