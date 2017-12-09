using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[RequireComponent(typeof(Camera))]
public class ClickScreenWaterWaveEffect : MonoBehaviour {

    [SerializeField]
    private Material mat_ClickWaterWave_BufferSimulation;
    [SerializeField]
    private Material mat_ClickWaterWave_CalculateNormal;

    private RenderTexture rt_BufferA;

    private CommandBuffer comBuffer;

    private Camera camera_Bake;
    //pass values
    private int m_iFrame = 0;

    private Mesh m_mesh;
    void DrawMyMesh()
    {
        if (m_mesh == null)
        {
            m_mesh = new Mesh();
            float aspect = (float)Screen.width / (float)Screen.height;
            m_mesh.vertices = new[] {
                new Vector3(-1*aspect,-1),new Vector3( 1*aspect,-1),
                new Vector3( 1*aspect, 1),new Vector3(-1*aspect, 1)
            };
            m_mesh.uv = new Vector2[4] {
                    Vector2.zero,Vector2.right,
                    Vector2.one, Vector2.up
            };
            m_mesh.triangles = new int[] { 0, 1, 2, 0, 2, 3 };
        }
    }
    //void CreateBuffer()
    //{
    //    if (this.tex_BufferA == null)
    //    {
    //        this.tex_BufferA = new Texture2D(Screen.width, Screen.height, TextureFormat.RGBAFloat, false);
    //        this.tex_BufferA.name = "BufferA";
    //        this.tex_BufferA.wrapMode = TextureWrapMode.Clamp;
    //        this.tex_BufferA.filterMode = FilterMode.Point;
    //        this.tex_BufferA.Apply();
    //    }
    //    for (int x = 0; x < tex_BufferA.width; x++)
    //    {
    //        for (int y = 0; y < tex_BufferA.height; y++)
    //        {
    //            tex_BufferA.SetPixel(x, y, Color.black);
    //        }
    //    }
    //}

    void CreateRTBuffer()
    {
        if (this.rt_BufferA == null)
        {
            this.rt_BufferA = new RenderTexture(Screen.width/1, Screen.height/1, 0, RenderTextureFormat.RGHalf);
            Debug.Log(Screen.width+"x"+Screen.height);
            this.rt_BufferA.name = "rt_BufferA";
            this.rt_BufferA.filterMode = FilterMode.Trilinear;
            this.rt_BufferA.wrapMode = TextureWrapMode.Clamp;
            this.rt_BufferA.useMipMap = false;
            this.rt_BufferA.Create();
            this.rt_BufferA.Release();
        }
    }

    void CreatCommandBuffer()
    {
        if (this.comBuffer == null)
        {
            DrawMyMesh();
            this.comBuffer = new CommandBuffer();
            this.comBuffer.name = "Back Full Screen Mesh";
            this.comBuffer.DrawMesh(this.m_mesh, Matrix4x4.identity, this.mat_ClickWaterWave_BufferSimulation, 0, 0);
            this.camera_Bake.AddCommandBuffer(CameraEvent.BeforeImageEffectsOpaque, this.comBuffer);
        }
    }

    void Start () {
        camera_Bake = GetComponent<Camera>();
        ReMoveBuffer();
        CreateRTBuffer();
        CreatCommandBuffer();
	}

    void UpdateValues()
    {
        this.m_iFrame++;
    }

    void Update()
    {
        UpdateValues();
    }

    void PassValuesIntoShader(Material _mat,float _witdh, float _height)
    {
        //pass texture
        _mat.SetTexture("_BufferA", this.rt_BufferA);
        //pass value
        _mat.SetVector("iMouse", new Vector4(Input.mousePosition.x, Input.mousePosition.y, Input.GetMouseButton(0) ? 2.0f : 0.0f, 0));
        _mat.SetFloat("time", Time.time);
        //_mat.SetFloat("iFrame", this.m_iFrame);
        _mat.SetVector("iScreenSize", new Vector4(_witdh, _height, 1f / _witdh, 1f / _height));
    }

    void OnRenderImage(RenderTexture src,RenderTexture dst)
    {
        Graphics.Blit(src, rt_BufferA);
        PassValuesIntoShader(this.mat_ClickWaterWave_BufferSimulation, Screen.width, Screen.height);

        PassValuesIntoShader(this.mat_ClickWaterWave_CalculateNormal, Screen.width, Screen.height);
        Graphics.Blit(this.rt_BufferA, dst, this.mat_ClickWaterWave_CalculateNormal, -1);

    }


    void ReMoveBuffer()
    {
        if (this.rt_BufferA != null)
        {
            this.rt_BufferA.Release();
            this.rt_BufferA = null;
        }
    }
    void OnDisable()
    {
        ReMoveBuffer();
    }
    void OnDestroy()
    {
        ReMoveBuffer();
    }
    
}
