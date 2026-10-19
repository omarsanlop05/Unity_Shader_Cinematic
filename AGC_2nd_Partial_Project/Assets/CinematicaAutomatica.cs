using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEngine.InputSystem;

public class CinematicaAutomatica : MonoBehaviour
{
    [System.Serializable]
    public struct FrameData
    {
        public float time; 
        public Vector3 pos;
        public Quaternion rot;
    }

    [Header("Modo de la Cámara")]
    [Tooltip("Marca esto para pilotar y grabar. Desmárcalo para reproducir automáticamente.")]
    public bool modoGrabacion = false;

    [Header("Controles de Vuelo (Solo en Grabación)")]
    public float moveSpeed = 6.0f;
    public float boostMultiplier = 2.0f;
    public float lookSensitivity = 0.04f;
    public float smoothTime = 0.15f;

    private float targetYaw, targetPitch, currentYaw, currentPitch, yawVel, pitchVel;
    private Vector3 targetPos, currentPosVel;

    private List<FrameData> frames = new List<FrameData>();
    private string filePath;
    private bool guardado = false;

    private float playbackTimer = 0f;
    private int playIndex = 0;

    void Awake()
    {
        filePath = Path.Combine(Application.streamingAssetsPath, "recorrido_camara.json");

        if (!modoGrabacion)
        {
            CargarRecorrido();
        }
    }

    void Start()
    {
        Vector3 angles = transform.eulerAngles;
        targetYaw = currentYaw = angles.y;
        targetPitch = currentPitch = angles.x;
        targetPos = transform.position;
        playbackTimer = 0f;
        playIndex = 0;
    }

    void Update()
    {
        if (modoGrabacion)
        {
            ActualizarVueloPiloto();
            playbackTimer += Time.deltaTime;
            frames.Add(new FrameData 
            { 
                time = playbackTimer, 
                pos = transform.position, 
                rot = transform.rotation 
            });
        }
        else
        {
            ReproducirRecorridoPorTiempo();
        }
    }

    void ActualizarVueloPiloto()
    {
        var mouse = Mouse.current;
        var keyboard = Keyboard.current;
        if (mouse == null || keyboard == null) return;

        if (mouse.rightButton.isPressed)
        {
            Vector2 delta = mouse.delta.ReadValue();
            targetYaw += delta.x * lookSensitivity;
            targetPitch -= delta.y * lookSensitivity;
            targetPitch = Mathf.Clamp(targetPitch, -85f, 85f);
        }

        currentYaw = Mathf.SmoothDampAngle(currentYaw, targetYaw, ref yawVel, smoothTime);
        currentPitch = Mathf.SmoothDamp(currentPitch, targetPitch, ref pitchVel, smoothTime);
        transform.eulerAngles = new Vector3(currentPitch, currentYaw, 0f);

        float speed = moveSpeed;
        if (keyboard.leftShiftKey.isPressed) speed *= boostMultiplier;

        Vector3 inputDir = Vector3.zero;
        if (keyboard.wKey.isPressed) inputDir += transform.forward;
        if (keyboard.sKey.isPressed) inputDir -= transform.forward;
        if (keyboard.dKey.isPressed) inputDir += transform.right;
        if (keyboard.aKey.isPressed) inputDir -= transform.right;
        if (keyboard.spaceKey.isPressed) inputDir += Vector3.up;
        if (keyboard.leftCtrlKey.isPressed || keyboard.rightCtrlKey.isPressed) inputDir -= Vector3.up;

        targetPos += inputDir.normalized * speed * Time.deltaTime;
        transform.position = Vector3.SmoothDamp(transform.position, targetPos, ref currentPosVel, smoothTime);
    }

    void ReproducirRecorridoPorTiempo()
    {
        if (frames == null || frames.Count < 2) return;

        playbackTimer += Time.deltaTime;

        while (playIndex < frames.Count - 2 && frames[playIndex + 1].time < playbackTimer)
        {
            playIndex++;
        }

        if (playIndex >= frames.Count - 1)
        {
            transform.position = frames[frames.Count - 1].pos;
            transform.rotation = frames[frames.Count - 1].rot;
            return;
        }

        FrameData fA = frames[playIndex];
        FrameData fB = frames[playIndex + 1];

        float duration = Mathf.Max(0.0001f, fB.time - fA.time);
        float t = Mathf.Clamp01((playbackTimer - fA.time) / duration);

        transform.position = Vector3.Lerp(fA.pos, fB.pos, t);
        transform.rotation = Quaternion.Slerp(fA.rot, fB.rot, t);
    }

    void GuardarRecorrido()
    {
        if (guardado || frames.Count == 0) return;
        guardado = true;

        string folder = Application.streamingAssetsPath;
        if (!Directory.Exists(folder)) Directory.CreateDirectory(folder);

        string json = JsonUtility.ToJson(new Wrapper { lista = frames });
        File.WriteAllText(filePath, json);
        Debug.Log("<color=green><b>✔ Recorrido guardado con sincronización de tiempo (" + playbackTimer.ToString("F1") + "s).</b></color>");
    }

    void CargarRecorrido()
    {
        if (File.Exists(filePath))
        {
            string json = File.ReadAllText(filePath);
            Wrapper w = JsonUtility.FromJson<Wrapper>(json);
            frames = w.lista;
            Debug.Log("<color=cyan><b>✔ Recorrido cargado listo para reproducir.</b></color>");
        }
        else
        {
            Debug.LogWarning("No se encontró el archivo de recorrido grabado en: " + filePath);
        }
    }

    void OnDisable()
    {
        if (modoGrabacion) GuardarRecorrido();
    }

    void OnApplicationQuit()
    {
        if (modoGrabacion) GuardarRecorrido();
    }

    [System.Serializable]
    private class Wrapper
    {
        public List<FrameData> lista;
    }
}