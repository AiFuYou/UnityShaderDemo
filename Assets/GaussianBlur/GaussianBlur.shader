Shader "Demo/GaussianBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlurSize ("BlurSize", float) = 1.0
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
            float2 uv : TEXCOORD0;
            float4 uv12 : TEXCOORD1;
            float4 uv34 : TEXCOORD2;
            float4 vertex : SV_POSITION;
        };

        sampler2D _MainTex;
        float2  _MainTex_TexelSize;
        float _BlurSize;
        
        fixed4 frag (v2f i) : SV_Target
        {
            fixed weight[3] = {0.4026, 0.2442, 0.0545};//5x5
            fixed3 col = tex2D(_MainTex, i.uv).rgb * weight[0];
            col += tex2D(_MainTex, i.uv12.xy).rgb * weight[1];
            col += tex2D(_MainTex, i.uv34.xy).rgb * weight[1];
            col += tex2D(_MainTex, i.uv12.zw).rgb * weight[2];
            col += tex2D(_MainTex, i.uv34.zw).rgb * weight[2];
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
                o.uv = uv;
                o.uv12.xy = uv + float2(0.0, _MainTex_TexelSize.y * 1.0) * _BlurSize;
                o.uv12.zw = uv + float2(0.0, _MainTex_TexelSize.y * 2.0) * _BlurSize;
                o.uv34.xy = uv - float2(0.0, _MainTex_TexelSize.y * 1.0) * _BlurSize;
                o.uv34.zw = uv - float2(0.0, _MainTex_TexelSize.y * 2.0) * _BlurSize;
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
                o.uv = uv;
                o.uv12.xy = uv + float2(_MainTex_TexelSize.x * 1.0, 0.0) * _BlurSize;
                o.uv12.zw = uv + float2(_MainTex_TexelSize.x * 2.0, 0.0) * _BlurSize;
                o.uv34.xy = uv - float2(_MainTex_TexelSize.x * 1.0, 0.0) * _BlurSize;
                o.uv34.zw = uv - float2(_MainTex_TexelSize.x * 2.0, 0.0) * _BlurSize;
                return o;
            }
            
            ENDCG
        }
    }
}