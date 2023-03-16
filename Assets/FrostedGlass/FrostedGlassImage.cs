using System.Collections;
using UnityEngine;
using UnityEngine.UI;

public class FrostedGlassImage : Image
{
    [SerializeField] [Range(1, 10)] private int _iterations = 3;
    [SerializeField] [Range(1, 10)] private int _downSample = 2;

    private Material _blurMat;
    private Texture2D _texture2D;
    private WaitForEndOfFrame _frameEnd = new();

    private static readonly int BlurTex = Shader.PropertyToID("_BlurTex");

    public int downSample
    {
        get => _downSample;
        set
        {
            if (_downSample.Equals(value)) return;
            _downSample = value;
        }
    }

    public int iterations
    {
        get => _iterations;
        set
        {
            if (_iterations.Equals(value)) return;
            _iterations = value;
        }
    }

    protected override void OnEnable()
    {
        base.OnEnable();
        material = new Material(Shader.Find("Demo/CustomImage"));
        var rect = rectTransform.rect;
        _texture2D = new Texture2D((int)rect.width, (int)rect.height);
        StartCoroutine(GaussianBlur());
    }

    protected override void OnDisable()
    {
        base.OnDisable();

        DestroyImmediate(_texture2D);
        _texture2D = null;
    }

    /// <summary>
    /// 降低图片采样，进行模糊处理
    /// </summary>
    private IEnumerator GaussianBlur()
    {
        yield return _frameEnd;
        //
        // var pos = rectTransform.anchoredPosition;
        // var rect = rectTransform.rect;
        //
        // var rectScreen = new Rect(pos.x + rect.x + Screen.width / 2f, pos.y + rect.y + Screen.height / 2f, rect.width,
        //     rect.height);
        //
        // if (rectScreen.x + rect.width <= 0 || rectScreen.y + rect.height <= 0) yield break;
        // if (rectScreen.x >= Screen.width || rectScreen.height >= Screen.height) yield break;
        //
        // rectScreen.width = rectScreen.width > rect.width ? rect.width : rectScreen.width;
        // rectScreen.height = rectScreen.height > rect.height ? rect.height : rectScreen.height;
        //
        // _texture2D.ReadPixels(rectScreen, 0, 0);
        // _texture2D.Apply();
        //
        // _blurMat = _blurMat != null ? _blurMat : new Material(Shader.Find("Demo/GaussianBlur"));
        //
        // var w = (int)rectScreen.width / downSample;
        // var h = (int)rectScreen.height / downSample;
        //
        // var buffer0 = RenderTexture.GetTemporary(w, h);
        // Graphics.Blit(_texture2D, buffer0);
        // for (var i = 0; i < iterations; i++)
        // {
        //     var buffer1 = RenderTexture.GetTemporary(w, h);
        //     buffer1.filterMode = FilterMode.Bilinear;
        //     Graphics.Blit(buffer0, buffer1, _blurMat, 0);
        //
        //     // 释放buffer0并将buffer1赋值给buffer0
        //     RenderTexture.ReleaseTemporary(buffer0);
        //     buffer0 = buffer1;
        //
        //     buffer1 = RenderTexture.GetTemporary(w, h);
        //     buffer1.filterMode = FilterMode.Bilinear;
        //     Graphics.Blit(buffer0, buffer1, _blurMat, 1);
        //
        //     // 释放buffer0并将buffer1赋值给buffer0
        //     RenderTexture.ReleaseTemporary(buffer0);
        //     buffer0 = buffer1;
        // }
        //
        // material.SetTexture(BlurTex, buffer0);
        // SetMaterialDirty();
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        StartCoroutine(GaussianBlur());
        Graphics.Blit(src, dest);
    }
}