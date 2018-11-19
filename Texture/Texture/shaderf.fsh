precision highp float;
varying vec4 varyColor;
varying vec3 varyNormal;
varying vec2 fragUV;

uniform vec3 lightDirection;
uniform mat4 normalMatrix;
uniform sampler2D diffuseMap;

void main()
{
    // 反向归化光源光照
    vec3 normalizedLightDirection = normalize(-lightDirection);
    // 归化法线
    vec3 transformedMatrix = normalize((normalMatrix * vec4(varyNormal, 1)).xyz);
    
    // 漫反射强度
    float diffuseStrength = dot(normalizedLightDirection, transformedMatrix);
    vec3 diffuse= vec3(diffuseStrength);
    
    // 环境光
    vec3 ambient = vec3(0.2);
    
    vec4 finalLightStrength = vec4(ambient + diffuse, 1.0);
    
    vec4 materialColor = texture2D(diffuseMap, fragUV);
    
    gl_FragColor = finalLightStrength * materialColor;
    
//    gl_FragColor = materialColor;
}
