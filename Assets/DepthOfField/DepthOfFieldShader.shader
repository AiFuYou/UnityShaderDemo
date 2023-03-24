Shader "Hidden/DepthOfFieldShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
        Cull Off 
        ZWrite Off 
        ZTest Off
        
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

        float4 _MainTex_TexelSize;
        float _BlurSize;
        sampler2D _BlurTex;
        sampler2D _MainTex;
        

        v2f vert_hor (appdata v)
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

        v2f vert_ver (appdata v)
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

        fixed4 frag_blur(v2f i) : SV_Target
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
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_hor
            #pragma fragment frag_blur
            ENDCG
        }
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_ver
            #pragma fragment frag_blur
            ENDCG
        }      
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_local _ USE_NEAR_BLUR
            #pragma multi_compile_local _ USE_FAR_BLUR

            #include "UnityCG.cginc"

            struct v2fTemp
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };
            
            v2fTemp vert (appdata v)
            {
                v2fTemp o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _CameraDepthTexture;
            float _FocalDistance;
            float _NearBlurScale;
            float _FarBlurScale;
            
            fixed4 frag (v2fTemp i) : SV_Target
            {
                fixed4 colOri = tex2D(_MainTex, i.uv);

                //直接根据UV坐标取该点的深度值  
                float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);  
                // 将深度值变为线性01空间  
                depth = Linear01Depth(depth);  
                // return fixed4(depth, depth, depth, 1);
                fixed4 colBlur = tex2D(_BlurTex, i.uv);
                float focalTest = clamp(sign(depth - _FocalDistance), 0, 1);

                // 效果一
                // fixed4 colFinal = depth <= _FocalDistance ? colOri : lerp(colOri, colBlur, clamp((depth - _FocalDistance) * _FarBlurScale, 0, 1));
                // colFinal = depth > _FocalDistance ? colFinal : lerp(colOri, colBlur, clamp((_FocalDistance - depth) * _NearBlurScale, 0, 1));

                // 过度效果更好
                // 深度与焦距比较，为负值，则为0，为正值，则为本身
                
                fixed4 colFinal = colOri;

                // 深度大于焦距的颜色，远景模糊
                #ifdef USE_FAR_BLUR
                colFinal = lerp(colOri, lerp(colOri, colBlur, clamp((depth - _FocalDistance) * _FarBlurScale, 0, 1)), focalTest);
                #endif

                // 深度小于焦距的颜色，近景模糊
                #ifdef USE_NEAR_BLUR
                colFinal = lerp(lerp(colOri, colBlur, clamp((_FocalDistance - depth) * _NearBlurScale, 0, 1)), colFinal, focalTest);
                #endif

                return colFinal;
            }
            ENDCG
        }
    }
}
