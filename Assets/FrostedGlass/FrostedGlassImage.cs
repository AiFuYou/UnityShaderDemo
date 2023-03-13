using UnityEditor;
using UnityEditor.UI;
using UnityEngine;
using UnityEngine.UI;

public class FrostedGlassImage : Image
{
    [Range(1, 10)] public int blurSize = 1;
    [Range(1, 13)] public int kernelSize = 3;
}

[CustomEditor(typeof(FrostedGlassImage), true)]
[CanEditMultipleObjects]
public class FrostedGlassImageEditor : ImageEditor
{
    private SerializedProperty _blurSize;
    private SerializedProperty _kernelSize;

    protected override void OnEnable()
    {
        base.OnEnable();
        _blurSize = serializedObject.FindProperty("blurSize");
        _kernelSize = serializedObject.FindProperty("kernelSize");
    }

    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();
        BlurGUI();
    }

    private void BlurGUI()
    {
        EditorGUILayout.PropertyField(_blurSize);
        EditorGUILayout.PropertyField(_kernelSize);
    }
}