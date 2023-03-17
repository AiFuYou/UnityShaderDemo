Shader "Demo/SpotlightWithCtrl"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlurIntensity("Blur Intensity", float) = 0
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
        Cull Off ZWrite Off ZTest Always
        
        CGINCLUDE

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
        float _BlurIntensity;
        fixed2 _Pos;
        float2 _MainTex_TexelSize;

        fixed4 grag(v2f i) : SV_Target
        {
            half2 dir = _Pos - i.uv;
            dir *= float2(_MainTex_TexelSize.y / _MainTex_TexelSize.x, 1);
            fixed dist = length(dir);
            // saturate函数（saturate(x)的作用是如果x取值小于0，则返回值为0。如果x取值大于1，则返回值为1。若x在0到1之间，则直接返回x的值.）
            fixed4 col = lerp(tex2D(_MainTex, i.uv), fixed4(0, 0, 0, 1), saturate(_BlurIntensity * dist));
            return col;
        }

        ENDCG

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment grag
            ENDCG
        }
    }
}
