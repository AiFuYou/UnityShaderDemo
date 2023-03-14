Shader "Demo/FrostedGlassGrabPassMultiPass"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlurSize ("BlurSize", Range(1, 10)) = 1.0
    }
    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjection"="True"
            "RenderType"="Transparent"
        }
        
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
            float2 grabPos[5] : TEXCOORD0;
            float2 uv : TEXCOORD5;
            float4 vertex : SV_POSITION;
        };

        sampler2D _GrabTexture;
        float2  _GrabTexture_TexelSize;
        float _BlurSize;
        sampler2D _MainTex;
        float4 _MainTex_ST;
        
        fixed4 frag (v2f i) : SV_Target
        {
            fixed4 tColor = tex2D(_MainTex, i.uv);
            clip(tColor.a - 0.001);
            
            // fixed weight[3] = {0.4026, 0.2442, 0.0545};//5x5
            fixed weight[3] = {1, 3, 5};//5x5
            
            float3 col = tex2D(_GrabTexture, i.grabPos[0]).rgb * weight[0];
            float sum = weight[0];
            for (int idx = 1; idx < 3; idx++)
            {
                fixed w = weight[idx];
                col += tex2D(_GrabTexture, i.grabPos[idx]).rgb * w;
                col += tex2D(_GrabTexture, i.grabPos[idx + 2]).rgb * w;
                sum += w;
                sum += w;
            }
            return fixed4(col / sum, 1);
        }

        v2f vert_vertical(appdata v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv = v.uv;
            const float2 uv = ComputeGrabScreenPos(o.vertex);
            o.grabPos[0] = uv;
            o.grabPos[1] = uv + float2(0.0, _GrabTexture_TexelSize.y * 1.0) * _BlurSize;
            o.grabPos[2] = uv + float2(0.0, _GrabTexture_TexelSize.y * 2.0) * _BlurSize;
            o.grabPos[3] = uv - float2(0.0, _GrabTexture_TexelSize.y * 1.0) * _BlurSize;
            o.grabPos[4] = uv - float2(0.0, _GrabTexture_TexelSize.y * 2.0) * _BlurSize;
            return o;
        }

        v2f vert_horizon (appdata v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv = v.uv;
            const float2 uv = ComputeGrabScreenPos(o.vertex);
            o.grabPos[0] = uv;
            o.grabPos[1] = uv + float2(_GrabTexture_TexelSize.x * 1.0, 0.0) * _BlurSize;
            o.grabPos[2] = uv + float2(_GrabTexture_TexelSize.x * 2.0, 0.0) * _BlurSize;
            o.grabPos[3] = uv - float2(_GrabTexture_TexelSize.x * 1.0, 0.0) * _BlurSize;
            o.grabPos[4] = uv - float2(_GrabTexture_TexelSize.x * 2.0, 0.0) * _BlurSize;
            return o;
        }
        
        ENDCG

        GrabPass {}
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_vertical
            #pragma fragment frag
            ENDCG
        }
        GrabPass {}
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_horizon
            #pragma fragment frag
            ENDCG
        }
        GrabPass {}
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_vertical
            #pragma fragment frag
            ENDCG
        }
        GrabPass {}
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_horizon
            #pragma fragment frag
            ENDCG
        }
        GrabPass {}
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_vertical
            #pragma fragment frag
            ENDCG
        }
        GrabPass {}
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_horizon
            #pragma fragment frag
            ENDCG
        }
        GrabPass {}
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_vertical
            #pragma fragment frag
            ENDCG
        }
        GrabPass {}
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_horizon
            #pragma fragment frag
            ENDCG
        }
    }
}