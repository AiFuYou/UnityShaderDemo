Shader "Demo/ImagePartGray"
{
    Properties{
        _MainTex ("Main Texture", 2D) = "white" {}
    }
    
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
                float4 vertex : SV_POSITION;
                float2 grabPos : TEXCOORD0;
                float2 uv : TEXCOORD1;
            };

            sampler2D _GrabTexture;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.grabPos = ComputeGrabScreenPos(o.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            

            fixed4 frag (v2f i) : SV_Target
            {
                // return tex2D(_MainTex, i.uv);

                fixed4 tColor = tex2D(_MainTex, i.uv);
                clip(tColor.a - 0.001);

                fixed4 col = tex2D(_GrabTexture, i.grabPos);
                fixed grayScale = Luminance(col.rgb);
                return fixed4(grayScale, grayScale, grayScale, col.a);
            }
            ENDCG
        }
    }
}
