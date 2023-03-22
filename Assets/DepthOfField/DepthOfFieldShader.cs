using System;
using UnityEngine;

public class DepthOfFieldShader : MonoBehaviour
{
    private Material _mat;

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (!_mat) _mat = new Material(Shader.Find("Hidden/DepthOfFieldShader"));

        if (_mat != null && _mat.shader.isSupported)
        {
            Graphics.Blit(src, dest, _mat);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}
