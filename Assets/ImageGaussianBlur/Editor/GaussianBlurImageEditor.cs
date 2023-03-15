using UnityEditor;
using UnityEditor.UI;

[CustomEditor(typeof(GaussianBlurImage), true)]
[CanEditMultipleObjects]
public class GaussianBlurImageEditor : ImageEditor
{
    private SerializedProperty _downSample;
    private SerializedProperty _iterations;

    protected override void OnEnable()
    {
        base.OnEnable();
        _downSample = serializedObject.FindProperty("_downSample");
        _iterations = serializedObject.FindProperty("_iterations");
    }

    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        BlurGUI();
        serializedObject.ApplyModifiedProperties();
    }

    private void BlurGUI()
    {
        EditorGUILayout.PropertyField(_downSample);
        EditorGUILayout.PropertyField(_iterations);
    }
}