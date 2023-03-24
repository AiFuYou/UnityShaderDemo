using UnityEngine;
using UnityEngine.Serialization;

public class DepthOfFieldShader : MonoBehaviour
{
    [Range(1, 5)] public float blurSize = 1;
    [Range(1, 8)] public int downSample = 1;
    [Range(1, 4)] public int iterations = 1;

    [Range(0f, 40)] public float focalDistance = 20f;
    [Range(0f, 10)] public float nearBlurScale = 5f;
    [Range(0f, 10)] public float farBlurScale = 5f;

    public bool useNearBlur = true;
    public bool useFarBlur = true;
    private string _keyWordUseNearBlur = "USE_NEAR_BLUR";
    private string _keyWordUseFarBlur = "USE_FAR_BLUR";

    private Material _mat;
    private Camera _curCamera;

    private Camera CurCamera
    {
        get
        {
            if (_curCamera == null) _curCamera = GetComponent<Camera>();

            return _curCamera;
        }
    }

    private static readonly int BlurSize = Shader.PropertyToID("_BlurSize");
    private static readonly int BlurTex = Shader.PropertyToID("_BlurTex");
    private static readonly int FocalDistance = Shader.PropertyToID("_FocalDistance");
    private static readonly int NearBlurScale = Shader.PropertyToID("_NearBlurScale");
    private static readonly int FarBlurScale = Shader.PropertyToID("_FarBlurScale");

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (!_mat)
        {
            _mat = new Material(Shader.Find("Hidden/DepthOfFieldShader"));
            CurCamera.depthTextureMode = DepthTextureMode.Depth;
        }

        if (_mat != null && _mat.shader.isSupported)
        {
            // 高斯模糊处理
            _mat.SetFloat(BlurSize, blurSize);
            var w = src.width / downSample;
            var h = src.height / downSample;
            var buffer0 = RenderTexture.GetTemporary(w, h);

            Graphics.Blit(src, buffer0);
            for (var i = 0; i < iterations; i++)
            {
                var buffer1 = RenderTexture.GetTemporary(w, h);
                buffer1.filterMode = FilterMode.Bilinear;
                Graphics.Blit(buffer0, buffer1, _mat, 0);
                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;

                buffer1 = RenderTexture.GetTemporary(w, h);
                buffer1.filterMode = FilterMode.Bilinear;
                Graphics.Blit(buffer0, buffer1, _mat, 1);
                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
            }

            // 景深处理
            _mat.SetTexture(BlurTex, buffer0);
            var fd = Mathf.Clamp(focalDistance, CurCamera.nearClipPlane, CurCamera.farClipPlane);
            fd = FocalDistance01(fd);
            _mat.SetFloat(FocalDistance, fd);
            _mat.SetFloat(NearBlurScale, nearBlurScale);
            _mat.SetFloat(FarBlurScale, farBlurScale);
            if (useNearBlur)
                _mat.EnableKeyword(_keyWordUseNearBlur);
            else
                _mat.DisableKeyword(_keyWordUseNearBlur);
            if (useFarBlur)
                _mat.EnableKeyword(_keyWordUseFarBlur);
            else
                _mat.DisableKeyword(_keyWordUseFarBlur);

            Graphics.Blit(src, dest, _mat, 2);
            RenderTexture.ReleaseTemporary(buffer0);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }

    private float FocalDistance01(float distance)
    {
        return (distance - CurCamera.nearClipPlane) / (CurCamera.farClipPlane - CurCamera.nearClipPlane);
        // return CurCamera.WorldToViewportPoint((distance - CurCamera.nearClipPlane) * CurCamera.transform.forward + CurCamera.transform.position).z / (CurCamera.farClipPlane - CurCamera.nearClipPlane);  
    }
}