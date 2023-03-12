Shader "Demo/FrameAnimation"
{
    Properties
    {
        _Speed("Speed", int) = 30
        _Y("Row Number", int) = 1
        _X("Colum Number", int) = 1
    }
    
    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
        }
        
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

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
            int _X;
            int _Y;
            int _Speed;

            fixed4 frag (v2f i) : SV_Target
            {
                // 总时间
                int num = floor(_Time.y * _Speed);

                // 把时间控制在设定的数量内
                num %= _X * _Y;

                // 计算当前列
                int x = num % _X;

                // 计算当前行
                int y = num / _X;

                // 偏移量
                i.uv += half2(x, _Y - 1 - y);

                // 缩放
                i.uv.x /= _X;
                i.uv.y /= _Y;

                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
