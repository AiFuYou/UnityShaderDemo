Shader "Hidden/RadialBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Degree ("Degress", float) = 0
        _BlurIntensity("Blur Intensity", float) = 0
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
        sampler2D _BlurTex;
        float _Degree;
        float _BlurIntensity;
        
        fixed4 fragRadialBlur (v2f i) : SV_Target
        {
            // 中心点
            float2 center = float2(0.5, 0.5);

            // 距离
            fixed2 dir = center - i.uv;
            dir /= length(dir);
            dir *= _Degree;

            float4 sum = tex2D(_MainTex, i.uv + dir * 0.01);
            sum += tex2D(_MainTex, i.uv + dir * -0.01);
            sum += tex2D(_MainTex, i.uv + dir * 0.02);
            sum += tex2D(_MainTex, i.uv + dir * -0.02);
            sum += tex2D(_MainTex, i.uv + dir * 0.03);
            sum += tex2D(_MainTex, i.uv + dir * -0.03);
            sum += tex2D(_MainTex, i.uv + dir * 0.05);
            sum += tex2D(_MainTex, i.uv + dir * -0.05);
            sum += tex2D(_MainTex, i.uv + dir * 0.08);
            sum += tex2D(_MainTex, i.uv + dir * -0.08);
            
            return sum * 0.1;
        }

        fixed4 fragCombine(v2f i) : SV_Target
        {
            fixed dist = length(0.5 - i.uv);
            // saturate函数（saturate(x)的作用是如果x取值小于0，则返回值为0。如果x取值大于1，则返回值为1。若x在0到1之间，则直接返回x的值.）
            return lerp(tex2D(_MainTex, i.uv), tex2D(_BlurTex, i.uv), saturate(_BlurIntensity * dist));
        }

        ENDCG

        // 径向模糊的原理
        // 第一步：确定径向模糊的中心点，通常取图像的正中心点
        // 第二步：计算采样像素与中心点的距离，根据距离确定偏移程度，即离中心点越远，偏移量越大
        // 第三步：将采样点的颜色值做加权求和
        // 第四步：将前面的结果与原图像做一个lerp差值合成
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragRadialBlur
            ENDCG
        }
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragCombine
            ENDCG
        }
    }
}
