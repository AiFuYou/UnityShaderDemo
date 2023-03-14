using UnityEngine;
using UnityEngine.UI;

public class FrostedGlassImage : Image
{
    [SerializeField] [Range(1, 10)] private int _iterations = 3;
    [SerializeField] [Range(1, 10)] private int _downSample = 2;

    private static readonly int BlurTex = Shader.PropertyToID("_BlurTex");
    private static readonly int MainTex = Shader.PropertyToID("_MainTex");

    public int downSample
    {
        get => _downSample;
        set
        {
            _downSample = value;
            GaussianBlur();
        }
    }

    public int iterations
    {
        get => _iterations;
        set
        {
            _iterations = value;
            GaussianBlur();
        }
    }

    protected override void OnEnable()
    {
        base.OnEnable();
        material = new Material(Shader.Find("Demo/FrostedGlass"));
        material.hideFlags = HideFlags.HideAndDontSave;
        GaussianBlur();
    }

    /// <summary>
    /// 降低图片采样，进行模糊处理
    /// </summary>
    private void GaussianBlur()
    {
        var oriT = sprite.texture;
        var w = oriT.width / downSample;
        var h = oriT.height / downSample;

        var mat = new Material(Shader.Find("Demo/GaussianBlur"));
        var buffer0 = RenderTexture.GetTemporary(w, h);
        Graphics.Blit(oriT, buffer0);
        for (var i = 0; i < iterations; i++)
        {
            var buffer1 = RenderTexture.GetTemporary(w, h);
            buffer1.filterMode = FilterMode.Bilinear;
            Graphics.Blit(buffer0, buffer1, mat, 0);
        
            // 释放buffer0并将buffer1赋值给buffer0
            RenderTexture.ReleaseTemporary(buffer0);
            buffer0 = buffer1;
        
            buffer1 = RenderTexture.GetTemporary(w, h);
            buffer1.filterMode = FilterMode.Bilinear;
            Graphics.Blit(buffer0, buffer1, mat, 1);
        
            // 释放buffer0并将buffer1赋值给buffer0
            RenderTexture.ReleaseTemporary(buffer0);
            buffer0 = buffer1;
        }

        material.SetTexture(BlurTex, buffer0);
        SetMaterialDirty();
    }
}