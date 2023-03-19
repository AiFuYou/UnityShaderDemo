using UnityEngine;

public class ImagePartWithCtrl : MonoBehaviour
{
    [Range(0, 10)]public float blurIntensity = 3f;
    
    private Material _mat;
    private Vector2 _pos = new(0.5f, 0.5f);
    private static readonly int BlurIntensity = Shader.PropertyToID("_BlurIntensity");
    private static readonly int Pos = Shader.PropertyToID("_Pos");

    // Start is called before the first frame update
    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (!_mat) _mat = new Material(Shader.Find("Demo/ImagePartWithCtrl"));

        if (_mat != null && _mat.shader.isSupported)
        {
            _mat.SetVector(Pos, _pos);
            _mat.SetFloat(BlurIntensity, blurIntensity);
            Graphics.Blit(src, dest, _mat);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }

    // Update is called once per frame
    private void Update()
    {
        if (Input.GetMouseButton(0))
            _pos = new Vector2(Input.mousePosition.x / Screen.width, Input.mousePosition.y / Screen.height);
    }
}
