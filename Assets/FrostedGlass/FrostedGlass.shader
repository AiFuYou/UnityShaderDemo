Shader "Demo/FrostedGlass"
{
    Properties
    {
        [HideInInspector]_MainTex ("Texture", 2D) = "white" {}
        _BlurSize ("BlurSize", Range(1.0, 10)) = 1.0
        _Iterations ("Iterations", Int) = 1
        _DownSample ("DownSample", Int) = 1
    }
    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
        }
        
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv[9] : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float2  _MainTex_TexelSize;
            float _BlurSize;
            int _Iterations;
            int _DownSample;
            
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
                o.uv[5] = uv + float2(_MainTex_TexelSize.x * 1.0, 0.0) * _BlurSize;
                o.uv[6] = uv + float2(_MainTex_TexelSize.x * 2.0, 0.0) * _BlurSize;
                o.uv[7] = uv - float2(_MainTex_TexelSize.x * 1.0, 0.0) * _BlurSize;
                o.uv[8] = uv - float2(_MainTex_TexelSize.x * 2.0, 0.0) * _BlurSize;

                return o;
            }

            fixed3 Gaussian(v2f i, bool isHor)
            {
                fixed weight[3] = {0.4026, 0.2442, 0.0545};//5x5
                fixed3 col = tex2D(_MainTex, i.uv[0] ).rgb * weight[0];
                for (int idx = 1; idx < 3; idx++)
                {
                    fixed w = weight[idx];
                    
                    if (isHor)
                    {
                        col += tex2D(_MainTex, i.uv[idx] + 4).rgb * w;
                        col += tex2D(_MainTex, i.uv[idx + 4 + 2]).rgb * w;
                    } else
                    {
                        col += tex2D(_MainTex, i.uv[idx]).rgb * w;
                        col += tex2D(_MainTex, i.uv[idx + 2]).rgb * w;
                    }
                }
                return col;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 sum = 0;
                sum += Gaussian(i, false) / 2;
                sum += Gaussian(i, true) / 2;
                return fixed4(sum, 1);
            }

            ENDCG
        }
    }
}
