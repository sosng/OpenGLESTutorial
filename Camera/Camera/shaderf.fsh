varying highp vec2 texCoordVarying;
precision mediump float;

uniform sampler2D SamplerY;
uniform sampler2D SamplerUV;
uniform mat3 colorConversionMatrix;

void main() {
    mediump vec3 yuv;
    lowp vec3 rgb;
    
    yuv.x = (texture2D(SamplerY, texCoordVarying).r);
    yuv.yz = (texture2D(SamplerUV, texCoordVarying).ra - vec2(0.5, 0.5));
    
    rgb = colorConversionMatrix * yuv;
    
    gl_FragColor = vec4(rgb, 1);
}
