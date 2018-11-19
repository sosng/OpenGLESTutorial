attribute vec4 position;
attribute vec4 positionColor;
attribute vec3 normal;
attribute vec2 uv;

uniform mat4 projectionMatrix;
uniform mat4 modelViewMatrix;

varying vec4 varyColor;
varying vec3 varyNormal;
varying vec2 fragUV;

void main()
{
    varyColor = positionColor;
    // 法线向量
    varyNormal = normal;
    // 贴图
    fragUV = uv;
    
    vec4 vPos = projectionMatrix * modelViewMatrix * position;
    gl_Position = vPos;
//    gl_Position = position;
}
