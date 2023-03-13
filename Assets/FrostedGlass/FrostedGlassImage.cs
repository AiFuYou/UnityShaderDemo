using System;
using System.Text;
using UnityEngine;
using UnityEngine.UI;

public class FrostedGlassImage : Image
{
    [SerializeField] [Range(1, 10)] private int _blurSize = 1;
    [SerializeField] [Range(3, 13)] private int _kernelSize = 3;

    public int kernelSize
    {
        get => _kernelSize;
        set
        {
            _kernelSize = value;
            CalculateGaussian();
            SetMaterialDirty();
        }
    }

    public int blurSize
    {
        get => _blurSize;
        set
        {
            _blurSize = value;
            SetMaterialDirty();
        }
    }

    protected override void Awake()
    {
        base.Awake();
        CalculateGaussian();
    }

    private void CalculateGaussian()
    {
        var kernel = new float[kernelSize * kernelSize];
        var edge = kernelSize / 2;
        var count = 0;
        for (var i = -edge; i <= edge; i++)
        for (var j = -edge; j <= edge; j++)
        {
            kernel[count] = GetGaussian(i, j);
            count++;
        }

        var sb = new StringBuilder();
        var idx = 0;
        for (var i = -edge; i <= edge; i++)
        {
            for (var j = -edge; j <= edge; j++)
            {
                sb.Append(kernel[idx]);
                sb.Append(", ");
                idx++;
            }

            sb.Append("\n");
        }

        Debug.Log(sb);
    }

    private float GetGaussian(int x, int y, float sigma = 1f)
    {
        var left = 1 / (2 * Math.PI * sigma * sigma);
        var right = Math.Exp(-(x * x + y * y) / (2 * sigma * sigma));
        return (float)(left * right);
    }
}