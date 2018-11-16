attribute vec4 position;
attribute vec4 positionColor;
attribute vec3 normal;

uniform mat4 projectionMatrix;
uniform mat4 modelViewMatrix;

varying vec4 varyColor;
varying vec3 varyNormal;

void main()
{
    varyColor = positionColor;
    // 法线向量
    varyNormal = normal;
    
    vec4 vPos = projectionMatrix * modelViewMatrix * position;
    gl_Position = vPos;
//    gl_Position = position;
}
