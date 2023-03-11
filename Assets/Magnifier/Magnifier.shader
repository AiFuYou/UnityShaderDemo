Shader "Demo/Magnifier"
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
            float _AtZoomArea;

            fixed4 frag (v2f i) : SV_Target
            {
                float2 scale = float2(_ScreenParams.x / _ScreenParams.y, 1);
                
                float2 center = _Pos;
                float2 dir = center - i.uv;

                dir.x *= _ScreenParams.x / _ScreenParams.y;
                
                float len = length(dir);

                // step(x, y)，如果x<=y,则返回1，否则返回0
                _AtZoomArea = step(len, _AtZoomArea);
                
                fixed4 col = tex2D(_MainTex, i.uv + dir * _ZoomFactor * _AtZoomArea);
                return col;
            }
            ENDCG
        }
    }
}
