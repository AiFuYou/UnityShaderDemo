Shader "Demo/ImageGray"
{
    Properties{
        _MainTex ("Main Texture", 2D) = "white" {}
        _Color ("Main Color", Color) = (1, 1, 1, 1)
        }
    
    SubShader{
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjection"="True"
            "RenderType"="Transparent"
        }
        
        Blend One OneMinusSrcAlpha
        
        Pass
        {
            CGPROGRAM

            #include "UnityCG.cginc"
            
            #pragma vertex vert
            #pragma fragment frag

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;

            struct a2v
            {
                float4 pos : POSITION;
                fixed4 color : COLOR;
                float2 uv : TEXCOORD0;
            };
            
            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed4 color : COLOR;
                float2 uv : TEXCOORD0;
            };
            
            v2f vert (a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.pos);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.color = v.color;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 color = tex2D(_MainTex, i.uv) * i.color;
                
                // 原图
                // return color;
                
                // 平均值法，GrayScale=(R+G+B)/3
                fixed val = (color.r + color.g + color.b) / 3;
                return fixed4(val, val, val, color.a);

                // 分量法，GrayScale1 = R，GrayScale2=G，GrayScale3=B
                // return fixed4 (color.r, color.r, color.r, color.a);
                // return fixed4 (color.g, color.g, color.g, color.a);
                // return fixed4 (color.b, color.b, color.b, color.a);

                // 最大值法，GrayScale=max(R,G,B)
                // fixed val = max(max(color.r, color.g), color.b) ;
                // return fixed4(val, val, val, color.a);

                // 加权平均法，GrayScale=0.299*R+0.578*G+0.114*B，（彩色转灰度，著名的心理学公式）
                // 根据每个色值所占比重计算出灰度，通常也使用这种方法计算像素的亮度
                // fixed val = 0.299 * color.r + 0.578 * color.g + 0.114 * color.b;
                // return fixed4(val, val, val, color.a);
            }

            ENDCG
        }
    }
}
