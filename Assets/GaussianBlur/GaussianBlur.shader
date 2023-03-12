Shader "Demo/GaussianBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlurSize ("_BlurSize", float) = 1.0
    }
    SubShader
    {
        CGINCLUDE

        #include "UnityCG.cginc"

        struct appdata
        {
            float4 vertex : POSITION;
            float2 uv : TEXCOORD0;
        };

        struct v2f
        {
            float2 uv[5] : TEXCOORD0;
            float4 vertex : SV_POSITION;
        };

        sampler2D _MainTex;
        float2  _MainTex_TexelSize;
        float _BlurSize;
        
        fixed4 frag (v2f i) : SV_Target
        {
            fixed weight[3] = {0.4026, 0.2442, 0.0545};
            
            fixed3 col = tex2D(_MainTex, i.uv[0]).rgb * weight[0];
            for (int idx = 1; idx < 3; idx++)
            {
                fixed w = weight[idx];
                col += tex2D(_MainTex, i.uv[idx]).rgb * w;
                col += tex2D(_MainTex, i.uv[idx + 2]).rgb * w;
            }
            return fixed4(col, 1);
        }
        
        ENDCG
        
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                const float2 uv = v.uv;
                o.uv[0] = uv;
                o.uv[1] = uv + float2(0.0, _MainTex_TexelSize.y * 1.0) * _BlurSize;
                o.uv[2] = uv + float2(0.0, _MainTex_TexelSize.y * 2.0) * _BlurSize;
                o.uv[3] = uv - float2(0.0, _MainTex_TexelSize.y * 1.0) * _BlurSize;
                o.uv[4] = uv - float2(0.0, _MainTex_TexelSize.y * 2.0) * _BlurSize;
                return o;
            }
            ENDCG
        }
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                const float2 uv = v.uv;
                o.uv[0] = uv;
                o.uv[1] = uv + float2(_MainTex_TexelSize.x * 1.0, 0.0) * _BlurSize;
                o.uv[2] = uv + float2(_MainTex_TexelSize.x * 2.0, 0.0) * _BlurSize;
                o.uv[3] = uv - float2(_MainTex_TexelSize.x * 1.0, 0.0) * _BlurSize;
                o.uv[4] = uv - float2(_MainTex_TexelSize.x * 2.0, 0.0) * _BlurSize;
                return o;
            }
            
            ENDCG
        }
    }
}