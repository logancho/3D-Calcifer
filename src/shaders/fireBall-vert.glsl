#version 300 es

//This is a vertex shader. While it is called a "shader" due to outdated conventions, this file
//is used to apply matrix transformations to the arrays of vertex data passed to it.
//Since this code is run on your GPU, each vertex is transformed simultaneously.
//If it were run on your CPU, each vertex would have to be processed in a FOR loop, one at a time.
//This simultaneous transformation allows your program to run much faster, especially when rendering
//geometry with millions of vertices.

uniform mat4 u_Model;       // The matrix that defines the transformation of the
                            // object we're rendering. In this assignment,
                            // this will be the result of traversing your scene graph.

uniform mat4 u_ModelInvTr;  // The inverse transpose of the model matrix.
                            // This allows us to transform the object's normals properly
                            // if the object has been non-uniformly scaled.

uniform mat4 u_ViewProj;    // The matrix that defines the camera's transformation.
                            // We've written a static matrix for you to use for HW2,
                            // but in HW3 you'll have to generate one yourself

uniform vec4 u_CamPos;

uniform float u_Time;

in vec4 vs_Pos;             // The array of vertex positions passed to the shader

in vec4 vs_Nor;             // The array of vertex normals passed to the shader

in vec4 vs_Col;             // The array of vertex colors passed to the shader.

out vec4 fs_Nor;            // The array of normals that has been transformed by u_ModelInvTr. This is implicitly passed to the fragment shader.
out vec4 fs_LightVec;       // The direction in which our virtual light lies, relative to each vertex. This is implicitly passed to the fragment shader.
out vec4 fs_Col;            // The color of each vertex. This is implicitly passed to the fragment shader.
out vec4 fs_Pos;

const vec4 lightPos = vec4(0, 5, 0, 1); //The position of our virtual light, which is used to compute the shading of
                                        //the geometry in the fragment shader.

int N_OCTAVES = 1;

float noise_gen2(float x, float y, float z, float w) {
    return fract(sin(dot(vec4(x, y, z, w), vec4(1.9898, 7.233, 4.984, 100.2974))) * 437.54531);
}

float fbm(float x, float y, float z) {
    float total = 0.f;
    float persistence = 1.f / 2.f;
    float amplitude = 1.f;
    float frequency = 1.f;
    for (int i = 0; i < N_OCTAVES; ++i) {
        frequency *= 2.f;
        amplitude *= persistence;
        total += amplitude * noise_gen2(x, y, z, frequency);
    }
    return total;
}

float bias(float t, float b) {
    return (t / ((((1.0/b) - 2.0)*(1.0 - t))+1.0));
}

float noise_gen3(float x, float y, float z) {
    return fract(sin(dot(vec3(x, y, z), vec3(0, 1, 0))) * 4337.54531);
}

float fbm_test(float x, float y, float z) {
    float total = 0.f;
    float frequency = 1.f;
    float amplitude = 1.f;
    float maxValue = 0.f;  // Used for normalizing result to 0.0 - 1.0
    float persistence = 0.5f;
    for(int i = 0; i < N_OCTAVES; i++) {
        total += noise_gen3(x * frequency, y * frequency, z * frequency) * amplitude;
        maxValue += amplitude;
        amplitude *= persistence;
        frequency *= 2.f;
    }
    return total/maxValue;
}

void main()
{
    fs_Col = vs_Col;                         // Pass the vertex colors to the fragment shader for interpolation

    mat3 invTranspose = mat3(u_ModelInvTr);
    fs_Nor = normalize(vec4(invTranspose * vec3(vs_Nor), 0));

    vec4 modelposition = u_Model * vs_Pos;   // Temporarily store the transformed vertex positions for use below

    vec3 tempPos = vec3(modelposition);

    // vec3 i = 0.01f * tempPos + 0.0000010f * vec3(u_Time);
    // float disp = fbm_test(i.x, i.y, i.z);
    // vec3 i = 0.000006f * vec3(tempPos) + 0.00000009f * vec3(u_Time);
    // float disp = bias(fbm_test(i.x, i.y, i.z), 0.45f);
    // tempPos += disp * vec3(normalize(vec4(invTranspose * vec3(vs_Nor), 0)));
    // vec3 i = 0.00001f * vec3(tempPos) + 0.0000002f * vec3(u_Time);
    // vec3 i = 0.0001f * vec3(tempPos);
    // float fbm_2 = bias(fbm_test(i.x, i.y, i.z), 0.97f);

    // tempPos += 1.f * fbm_2 * vec3(invTranspose * vec3(vs_Nor));
    // tempPos += fbm_2 * vec3(normalize(vec4(invTranspose * vec3(vs_Nor), 0)));
    // tempPos += 0.7f * fbm_2 * vec3(normalize(vec4(invTranspose * vec3(vs_Nor), 0)));

    fs_LightVec = lightPos - vec4(tempPos, 1.f);

    gl_Position = u_ViewProj * vec4(tempPos, 1.f);// gl_Position is a built-in variable of OpenGL which is
                                             // used to render the final positions of the geometry's vertices

    // fs_Pos = vec4(tempPos, 1.f);
    fs_Pos = modelposition;
}
