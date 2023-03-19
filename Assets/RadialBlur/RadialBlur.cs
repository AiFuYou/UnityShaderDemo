using UnityEngine;

public class RadialBlur : MonoBehaviour
{
    [Range(0, 1)] public float degree = 0.2f;
    [Range(0, 10)] public float intensity = 2;
    [Range(1, 8)] public float downSample = 1;
    [Range(1, 4)] public int iterations = 1;

    private Material _mat;
    private static readonly int Degree = Shader.PropertyToID("_Degree");
    private static readonly int BlurIntensity = Shader.PropertyToID("_BlurIntensity");
    private static readonly int BlurTex = Shader.PropertyToID("_BlurTex");

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (_mat == null) _mat = new Material(Shader.Find("Hidden/RadialBlur"));

        if (_mat != null && _mat.shader.isSupported)
        {
            _mat.SetFloat(Degree, degree);
            _mat.SetFloat(BlurIntensity, intensity);

            var w = (int)(src.width / downSample);
            var h = (int)(src.height / downSample);

            var buffer0 = RenderTexture.GetTemporary(w, h);
            Graphics.Blit(src, buffer0, _mat, 0);

            for (var i = 0; i < iterations - 1; i++)
            {
                var buffer1 = RenderTexture.GetTemporary(w, h);
                buffer1.filterMode = FilterMode.Bilinear;
                Graphics.Blit(buffer0, buffer1, _mat, 0);
                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
            }

            _mat.SetTexture(BlurTex, buffer0);

            Graphics.Blit(src, dest, _mat, 1);
            RenderTexture.ReleaseTemporary(buffer0);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}