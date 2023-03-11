Shader "Hidden/Magnifier"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
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
            float2 _Pos;
            float _ZoomFactor;
            float _Size;
            float _EdgeFactor;

            fixed4 frag (v2f i) : SV_Target
            {
                float2 center = _Pos;
                float2 dir = center - i.uv;

                float2 scale = float2(_ScreenParams.x / _ScreenParams.y, 1);
                float len = length(dir * scale);

                // step(x, y)，如果x<=y,则返回1，否则返回0
                // float atZoomArea = 1 - step(_Size, len);

                // 平滑阶梯函数
                // float smootherstep(float edge0, float edge1, float x) {
                //   // Scale, and clamp x to 0..1 range
                //   x = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0);
                //   // Evaluate polynomial
                //   return x * x * x * (x * (x * 6 - 15) + 10);
                // }
                //
                // float clamp(float x, float lowerlimit, float upperlimit) {
                //   if (x < lowerlimit)
                //     x = lowerlimit;
                //   if (x > upperlimit)
                //     x = upperlimit;
                //   return x;
                // }
                float atZoomArea = 1 - smoothstep(_Size, _Size + _EdgeFactor, len);
                
                fixed4 col = tex2D(_MainTex, i.uv + dir * _ZoomFactor * atZoomArea);
                return col;
            }
            ENDCG
        }
    }
}
