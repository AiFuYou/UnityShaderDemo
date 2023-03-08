Shader "Demo/ImageGrayWithMask"
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
        
        Stencil
        {
            Ref 1
            Comp Equal
        }
        
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

                // 平均值法，GrayScale=(R+G+B)/3
                fixed val = (color.r + color.g + color.b) / 3;
                return fixed4(val, val, val, color.a);
            }

            ENDCG
        }
    }
}
