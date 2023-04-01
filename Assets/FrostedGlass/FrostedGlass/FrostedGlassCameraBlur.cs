using UnityEngine;
using UnityEngine.Rendering;

public class FrostedGlassCameraBlur : MonoBehaviour
{
    // 过大会有虚影
    [Range(0, 3)] public float blurSize = 1f;

    // 滤波次数越多，越模糊，但会造成计算量过大，影响性能
    [Range(1, 10)] public int iterations = 1;

    // downSample越大，采样次数越少，效果越好，但过大会造成像素化
    [Range(1, 10)] public int downSample = 1;

    private Vector2 _screenResolution;
    private Camera _camera;
    private CommandBuffer _commandBuffer;
    private Material _mat;
    private static readonly int BlurSize = Shader.PropertyToID("_BlurSize");

    private void OnEnable()
    {
        Cleanup();
        Initialize();
    }

    private void OnDisable()
    {
        Cleanup();
    }

    private void Cleanup()
    {
        if (!Initialized) return;

        _camera.RemoveCommandBuffer(CameraEvent.BeforeForwardAlpha, _commandBuffer);
        _commandBuffer.Release();
        _commandBuffer = null;
        DestroyImmediate(_mat);
    }

    private bool Initialized => _commandBuffer != null;

    private void OnPreRender()
    {
        if (_screenResolution != new Vector2(Screen.width, Screen.height))
            Cleanup();

        Initialize();
    }

    private void Initialize()
    {
        if (Initialized) return;

        if (!_mat)
            _mat = new Material(Shader.Find("Demo/GaussianBlur"))
            {
                hideFlags = HideFlags.HideAndDontSave
            };

        _mat.SetFloat(BlurSize, blurSize);

        _commandBuffer = new CommandBuffer();
        _commandBuffer.name = "GaussianBlur";

        var w = Screen.width / downSample;
        var h = Screen.height / downSample;
        var screenCopyID = Shader.PropertyToID("_ScreenCopyTexture");
        _commandBuffer.GetTemporaryRT(screenCopyID, -1, -1, 0, FilterMode.Bilinear);
        _commandBuffer.Blit(BuiltinRenderTextureType.CurrentActive, screenCopyID);

        var blurredID1 = Shader.PropertyToID("_Grab1_Temp1");
        var blurredID2 = Shader.PropertyToID("_Grab1_Temp2");
        _commandBuffer.GetTemporaryRT(blurredID1, w, h, 0, FilterMode.Bilinear, RenderTextureFormat.ARGB32);
        _commandBuffer.Blit(screenCopyID, blurredID1);
        _commandBuffer.ReleaseTemporaryRT(screenCopyID);

        for (var i = 0; i < iterations; i++)
        {
            _commandBuffer.GetTemporaryRT(blurredID2, w, h, 0, FilterMode.Bilinear, RenderTextureFormat.ARGB32);
            _commandBuffer.Blit(blurredID1, blurredID2, _mat, 0);
            _commandBuffer.Blit(blurredID2, blurredID1, _mat, 1);
            _commandBuffer.ReleaseTemporaryRT(blurredID2);
        }

        _commandBuffer.SetGlobalTexture("_GrabBlurTexture_0", blurredID1);
        _commandBuffer.ReleaseTemporaryRT(blurredID1);

        _camera = GetComponent<Camera>();
        _camera.AddCommandBuffer(CameraEvent.BeforeForwardAlpha, _commandBuffer);
    }
}