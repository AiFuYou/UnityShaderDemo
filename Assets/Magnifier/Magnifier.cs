using UnityEngine;

public class Magnifier : MonoBehaviour
{
    [Range(0, 1)] public float zoomFactor = 0.4f;
    [Range(0, 1)] public float atZoomArea = 0.5f;
    
    private Vector2 _pos = new(0.5f, 0.5f);
    private Material _material;
    private static readonly int Pos = Shader.PropertyToID("_Pos");
    private static readonly int ZoomFactor = Shader.PropertyToID("_ZoomFactor");
    private static readonly int AtZoomArea = Shader.PropertyToID("_AtZoomArea");

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (!_material)
        {
            _material = new Material(Shader.Find("Demo/Magnifier"));
        }

        if (_material != null && _material.shader.isSupported)
        {
            _material.SetVector(Pos, _pos);
            _material.SetFloat(ZoomFactor, zoomFactor);
            _material.SetFloat(AtZoomArea, atZoomArea);
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
