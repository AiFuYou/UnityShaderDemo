using UnityEngine;

public class BrightnessSaturationContrast : MonoBehaviour
{
    [Range(0, 10)] public float brightness;
    [Range(0, 10)] public float saturation;
    [Range(0, 10)] public float contrast;

    private Material _mat;
    private static readonly int Brightness1 = Shader.PropertyToID("_Brightness");
    private static readonly int Saturation1 = Shader.PropertyToID("_Saturation");
    private static readonly int Contrast1 = Shader.PropertyToID("_Contrast");

    private void Awake()
    {
        if (!_mat) _mat = new Material(Shader.Find("Hidden/BrightnessSaturationContrast"));
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (_mat != null && _mat.shader.isSupported)
        {
            _mat.SetFloat(Brightness1, brightness);
            _mat.SetFloat(Saturation1, saturation);
            _mat.SetFloat(Contrast1, contrast);

            Graphics.Blit(src, dest, _mat);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}