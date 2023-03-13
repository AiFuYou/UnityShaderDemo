using UnityEditor;
using UnityEditor.UI;
using UnityEngine;

[CustomEditor(typeof(FrostedGlassImage), true)]
[CanEditMultipleObjects]
public class FrostedGlassImageEditor : ImageEditor
{
    private SerializedProperty _blurSize;
    private SerializedProperty _kernelSize;

    protected override void OnEnable()
    {
        base.OnEnable();
        _blurSize = serializedObject.FindProperty("_blurSize");
        _kernelSize = serializedObject.FindProperty("_kernelSize");
    }

    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        BlurGUI();
        serializedObject.ApplyModifiedProperties();
    }

    private void BlurGUI()
    {
        EditorGUILayout.PropertyField(_blurSize);

        // 卷积核为奇数
        if (_kernelSize.intValue % 2 == 0) ++_kernelSize.intValue;
        EditorGUILayout.PropertyField(_kernelSize);
    }
}