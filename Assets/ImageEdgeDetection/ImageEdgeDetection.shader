Shader "Demo/ImageEdgeDetection"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _EdgeColor ("EdgeColor", Color) = (1, 1, 1, 1)
        _BackgroundColor ("BackgroundColor", Color) = (1, 1, 1, 1)
        _EdgeOnly ("EdgeOnly", Range(0, 1)) = 1
    }
    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjection"="True"
            "RenderType"="Transparent"
        }
        
        // No culling or depth
        Cull Off 
        ZWrite Off 
        ZTest Always
        Blend SrcAlpha OneMinusSrcAlpha

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
            float2 _MainTex_TexelSize;
            fixed4 _EdgeColor;
            fixed4 _BackgroundColor;
            half _EdgeOnly;

            half Sobel(v2f i)
            {
                // 左+左上+左下+右+右上+右下
                half Gx = Luminance(tex2D(_MainTex, i.uv + _MainTex_TexelSize * half2(-1, 0))) * -2;
                Gx += Luminance(tex2D(_MainTex, i.uv + _MainTex_TexelSize * half2(-1, 1))) * -1;
                Gx += Luminance(tex2D(_MainTex, i.uv + _MainTex_TexelSize * half2(-1, -1))) * -1;
                Gx += Luminance(tex2D(_MainTex, i.uv + _MainTex_TexelSize * half2(1, 0))) * 2;
                Gx += Luminance(tex2D(_MainTex, i.uv + _MainTex_TexelSize * half2(1, 1))) * 1;
                Gx += Luminance(tex2D(_MainTex, i.uv + _MainTex_TexelSize * half2(1, -1))) * 1;

                // 上+左上+右上+下+左下+右下
                half Gy = Luminance(tex2D(_MainTex, i.uv + _MainTex_TexelSize * half2(0, 1))) * -2;
                Gy += Luminance(tex2D(_MainTex, i.uv + _MainTex_TexelSize * half2(-1, -1))) * -1;
                Gy += Luminance(tex2D(_MainTex, i.uv + _MainTex_TexelSize * half2(1, 1))) * -1;
                Gy += Luminance(tex2D(_MainTex, i.uv + _MainTex_TexelSize * half2(0, -1))) * 2;
                Gy += Luminance(tex2D(_MainTex, i.uv + _MainTex_TexelSize * half2(-1, -1))) * 1;
                Gy += Luminance(tex2D(_MainTex, i.uv + _MainTex_TexelSize * half2(1, -1))) * 1;
                
                return abs(Gx) + abs(Gy);
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 colOri = tex2D(_MainTex, i.uv);
                clip(colOri.a - 0.0001);

                // edge越大，越有可能是边缘，将edge的值当成边缘的权重
                half edge = Sobel(i);

                // 边缘的权重越大，则边缘颜色所占比例越大
                fixed4 withEdgeColor = lerp(colOri, _EdgeColor, edge);
                fixed4 onlyEdgeColor = lerp(_BackgroundColor, _EdgeColor, edge);

                // EdgeOnly越大，则显示边缘比重越大，剩下的为backgroundColor
                return lerp(withEdgeColor, onlyEdgeColor, _EdgeOnly) * colOri.a;
            }
            ENDCG
        }
    }
}
