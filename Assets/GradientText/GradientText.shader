Shader "Hidden/GradientText"
{
    Properties
    {
        _ColorLeft ("Color Left", Color) = (1, 1, 1, 1)
        _ColorRight ("Color Right", Color) = (0, 0, 0, 1)
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
            fixed4 _ColorLeft;
            fixed4 _ColorRight;

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = lerp(_ColorLeft, _ColorRight, i.uv.x);
                col.a = tex2D(_MainTex, i.uv).a;
                return col;
            }
            ENDCG
        }
    }
}
