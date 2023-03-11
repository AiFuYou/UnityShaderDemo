using UnityEngine;

public class Magnifier : MonoBehaviour
{
    [Range(0, 0.5f)] public float zoomFactor = 0.4f;
    [Range(0, 0.2f)] public float size = 0.5f;
    [Range(0, 0.2f)] public float edgeFactor = 0.1f;
    private Vector2 _pos = new(0.5f, 0.5f);
    private Material _material;
    private static readonly int Pos = Shader.PropertyToID("_Pos");
    private static readonly int ZoomFactor = Shader.PropertyToID("_ZoomFactor");
    private static readonly int Size = Shader.PropertyToID("_Size");
    private static readonly int EdgeFactor = Shader.PropertyToID("_EdgeFactor");

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (!_material)
        {
            _material = new Material(Shader.Find("Hidden/Magnifier"));
        }

        if (_material != null && _material.shader.isSupported)
        {
            _material.SetVector(Pos, _pos);
            _material.SetFloat(ZoomFactor, zoomFactor);
            _material.SetFloat(Size, size);
            _material.SetFloat(EdgeFactor, edgeFactor);
            Graphics.Blit(src, dest, _material);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetMouseButton(0))
        {
            _pos = new Vector2(Input.mousePosition.x / Screen.width, Input.mousePosition.y / Screen.height);
        }
    }
}
