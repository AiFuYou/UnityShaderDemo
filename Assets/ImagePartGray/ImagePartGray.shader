Shader "Demo/ImagePartGray"
{
    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjection"="True"
            "RenderType"="Transparent"
        }
        
        Cull Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        
        GrabPass {}
        
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
                float2 grabPos : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.grabPos = ComputeGrabScreenPos(o.vertex);
                return o;
            }

            sampler2D _GrabTexture;

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_GrabTexture, i.grabPos);
                fixed grayScale = Luminance(col.rgb);
                return fixed4(grayScale, grayScale, grayScale, col.a);
            }
            ENDCG
        }
    }
}
