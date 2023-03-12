using UnityEngine;

public class GaussianBlur : MonoBehaviour
{
    // 过大会有虚影
    [Range(0, 3)] public float blurSize = 1f;

    // 滤波次数越多，越模糊，但会造成计算量过大，影响性能
    [Range(1, 10)] public int iterations = 1;

    // downSample越大，采样次数越少，效果越好，但过大会造成像素化
    [Range(1, 10)] public int downSample = 1;

    private Material _mat;
    private static readonly int BlurSize = Shader.PropertyToID("_BlurSize");

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (!_mat) _mat = new Material(Shader.Find("Demo/GaussianBlur"));

        if (_mat != null && _mat.shader.isSupported)
        {
            _mat.SetFloat(BlurSize, blurSize);

            var w = src.width / downSample;
            var h = src.height / downSample;

            // 临时渲染纹理，不使用时要使用函数ReleaseTemporary销毁
            var buffer0 = RenderTexture.GetTemporary(w, h);
            buffer0.filterMode = FilterMode.Bilinear;

            Graphics.Blit(src, buffer0);

            for (var i = 0; i < iterations; i++)
            {
                var buffer1 = RenderTexture.GetTemporary(w, h);
                buffer1.filterMode = FilterMode.Bilinear;
                Graphics.Blit(buffer0, buffer1, _mat, 0);

                // 释放buffer0并将buffer1赋值给buffer0
                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;

                buffer1 = RenderTexture.GetTemporary(w, h);
                buffer1.filterMode = FilterMode.Bilinear;
                Graphics.Blit(buffer0, buffer1, _mat, 1);

                // 释放buffer0并将buffer1赋值给buffer0
                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
            }

            Graphics.Blit(buffer0, dest);
            RenderTexture.ReleaseTemporary(buffer0);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}