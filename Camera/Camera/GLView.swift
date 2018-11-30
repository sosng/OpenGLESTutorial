//
//  GLView.swift
//  Camera
//
//  Created by naver on 2018/11/20.
//  Copyright © 2018 naver. All rights reserved.
//

import UIKit
import GLKit
import AVFoundation

class GLView: UIView {
    
    enum Uniform {
        case y
        case uv
        case ColorConversionMatrix
    }
    
    enum Attribute: GLuint {
        case vertex = 0
        case texcoord
    }
    
    struct Constants {
        struct ColorConversion {
            static let C601: [GLfloat] = [1.164,  1.164, 1.164,
                                          0.0, -0.392, 2.017,
                                          1.596, -0.813,   0.0,]
            static let C709: [GLfloat] = [1.164,  1.164, 1.164,
                                          0.0, -0.213, 2.112,
                                          1.793, -0.533,   0.0,]
            static let C601FullRange: [GLfloat] = [1.0,    1.0,    1.0,
                                                   0.0,    -0.343, 1.765,
                                                   1.4,    -0.711, 0.0,]
        }
    }
    
    var isFullYUVRange = true
    private var context: EAGLContext?
    private var shader: Shader!
    private var program = GLuint()
    private var frameBuffer = GLuint()
    private var renderBuffer = GLuint()
    private var backingWidth = GLint()
    private var backingHeight = GLint()
    private var lumaTexture: CVOpenGLESTexture?
    private var chromaTexture: CVOpenGLESTexture?
    private var videoTextureCache: CVOpenGLESTextureCache?
    private var preferredConversion = Constants.ColorConversion.C601FullRange
    private var uniforms: [Uniform : GLint] = [.uv: 0,
                                                .y: 0,
                                                .ColorConversionMatrix: 0]
    
    override class var layerClass: AnyClass {
        return CAEAGLLayer.self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    deinit {
        cleanUpTextures()
        videoTextureCache = nil
    }
    
    private func cleanUpTextures() {
        lumaTexture = nil
        chromaTexture = nil
        if let texture = videoTextureCache {
            CVOpenGLESTextureCacheFlush(texture, 0)
        }
    }
    
    private func setup() {
        self.contentScaleFactor = UIScreen.main.scale
        if let layer = layer as? CAEAGLLayer {
            layer.isOpaque = true
            layer.drawableProperties = [kEAGLDrawablePropertyRetainedBacking: false,kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8]
        }
        context = EAGLContext(api: .openGLES2)
    }
    
    func setupGL() {
        EAGLContext.setCurrent(context)
        setupBuffers()
        loadShaders()
        
        glUseProgram(program)
        
        glUniform1i(uniforms[Uniform.y] ?? 0, 0)
        glUniform1i(uniforms[Uniform.uv] ?? 0, 1)
        
        glUniformMatrix3fv(uniforms[Uniform.ColorConversionMatrix] ?? 0, GLsizei(1), GLboolean(GL_FALSE), &preferredConversion)
        if videoTextureCache == nil {
            let cvReturn = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, nil, context!, nil, &videoTextureCache)
            print("CVOpenGLESTextureCacheCreate: \(cvReturn)")
        }
    }
    
    private func setupBuffers() {
        glDisable(GLenum(GL_DEPTH_TEST))
        
        glEnableVertexAttribArray(Attribute.vertex.rawValue)
        glVertexAttribPointer(Attribute.vertex.rawValue,
                              2,
                              GLenum(GL_FLOAT),
                              GLboolean(GL_FALSE),
                              GLsizei(MemoryLayout<GLfloat>.stride * 2),
                              nil)
        
        deinitRenderFrameBuffer()
        setupRenderBuffer()
        setupFrameBuffer()
    }
    
    
    private func deinitRenderFrameBuffer() {
        glDeleteRenderbuffers(1, &renderBuffer)
        renderBuffer = 0
        glDeleteFramebuffers(1, &frameBuffer)
        frameBuffer = 0
    }
    
    private func setupRenderBuffer() {
        glGenRenderbuffers(1, &renderBuffer)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), renderBuffer)
        context?.renderbufferStorage(Int(GL_RENDERBUFFER), from: layer as? CAEAGLLayer)
        glGetRenderbufferParameteriv(GLenum(GL_RENDERBUFFER), GLenum(GL_RENDERBUFFER_WIDTH), &backingWidth)
        glGetRenderbufferParameteriv(GLenum(GL_RENDERBUFFER), GLenum(GL_RENDERBUFFER_HEIGHT), &backingHeight)
    }
    
    private func setupFrameBuffer() {
        glGenFramebuffers(1, &frameBuffer)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), frameBuffer)
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER),
                                  GLenum(GL_COLOR_ATTACHMENT0),
                                  GLenum(GL_RENDERBUFFER),
                                  renderBuffer)
    }
    
    private func loadShaders() -> Bool {
        let vertShader = compile(shader: "shaderv.vsh", for: GLenum(GL_VERTEX_SHADER))
        let fragShader = compile(shader: "shaderf.fsh", for: GLenum(GL_FRAGMENT_SHADER))
        
        program = glCreateProgram()
        
        glAttachShader(program, vertShader)
        glAttachShader(program, fragShader)
        
        // bind attribute locations
        glBindAttribLocation(program, Attribute.vertex.rawValue, "position")
        glBindAttribLocation(program, Attribute.texcoord.rawValue, "texCoord")
        
        glLinkProgram(program)
        
        var linkStatus = GLint()
        glGetProgramiv(program, GLenum(GL_LINK_STATUS), &linkStatus)
        if linkStatus == GL_FALSE {
            var infoLength : GLsizei = 0
            let bufferLength : GLsizei = 1024
            glGetProgramiv(program, GLenum(GL_INFO_LOG_LENGTH), &infoLength)
            
            let info: [GLchar] = Array(repeating: GLchar(0), count: Int(bufferLength))
            var actualLength : GLsizei = 0
            
            glGetProgramInfoLog(program, bufferLength, &actualLength, UnsafeMutablePointer(mutating: info))
            print("=============\nshader link status info: \(String(describing: String(validatingUTF8: info)))\n=============")
            
            return false
        }
        
        uniforms[.y] = glGetUniformLocation(program, "SamplerY")
        uniforms[.uv] = glGetUniformLocation(program, "SamplerUV")
        uniforms[.ColorConversionMatrix] = glGetUniformLocation(program, "colorConversionMatrix")
        
        glDetachShader(program, vertShader)
        glDeleteShader(vertShader)
        glDetachShader(program, fragShader)
        glDeleteShader(fragShader)
        
        return true
    }
    

    private func compile(shader url: String, for type: GLenum) -> GLuint {
        guard let path = Bundle.main.path(forResource: url, ofType: nil) else {
            exit(0)
        }
        do {
            // 1 - 读取shaders string
            let shaderString = try String(contentsOfFile: path, encoding: .utf8)
            // 2 - handler
            let shaderHandler = glCreateShader(type)
            // 3 -
            var shaderStringLength = GLint(Int32(shaderString.lengthOfBytes(using: .utf8)))
            let shaderCString = shaderString.cString(using: .utf8)
            var pointer = UnsafePointer<GLchar>(shaderCString)
            // 4 -
            glShaderSource(shaderHandler, GLsizei(1), &pointer, &shaderStringLength)
            // 5 -
            glCompileShader(shaderHandler)
            // 6 -
            var compileStatus = GLint(0)
            glGetShaderiv(shaderHandler, GLenum(GL_COMPILE_STATUS), &compileStatus)
            
            if compileStatus == GL_FALSE {
                var infoLength: GLsizei = 0
                var bufferLength: GLsizei = 1024
                
                glGetShaderiv(shaderHandler, GLenum(GL_INFO_LOG_LENGTH), &infoLength)
                let info = Array(repeating: GLchar(0), count: Int(bufferLength))
                
                var actualLength: GLsizei = 0
                glGetShaderInfoLog(shaderHandler, bufferLength, &actualLength, UnsafeMutablePointer(mutating: info))
                
                print("=============\nshader compile status info: \(String(describing: String(validatingUTF8: info)))\nshader string:\(shaderString)=============")
                exit(0)
            }
            return shaderHandler
        } catch {
            exit(0)
        }
    }
    
    
    
    
    func display(_ pixelData: CVPixelBuffer?) {
        if let pixel = pixelData {
            let width = CVPixelBufferGetWidth(pixel)
            let height = CVPixelBufferGetHeight(pixel)
            guard let videoTextureCache = videoTextureCache else {
                print("No video texture cache")
                return
            }
            if EAGLContext.current() != context {
                EAGLContext.setCurrent(context)
            }
            cleanUpTextures()
            
            let colorAttachMents = CVBufferGetAttachment(pixel, kCVImageBufferYCbCrMatrixKey, nil)
            if let value = colorAttachMents?.takeUnretainedValue(), let cfValue = CFCopyDescription(value) {
                if cfValue == kCVImageBufferYCbCrMatrix_ITU_R_601_4 {
                    if isFullYUVRange {
                        preferredConversion = Constants.ColorConversion.C601FullRange
                    } else {
                        preferredConversion = Constants.ColorConversion.C601
                    }
                } else {
                    preferredConversion = Constants.ColorConversion.C709

                }
            }
            
            glActiveTexture(GLenum(GL_TEXTURE0))
            // luma
            CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                         videoTextureCache,
                                                         pixel,
                                                         nil,
                                                         GLenum(GL_TEXTURE_2D),
                                                         GLint(GL_LUMINANCE),
                                                         GLsizei(width),
                                                         GLsizei(height),
                                                         GLenum(GL_LUMINANCE),
                                                         GLenum(GL_UNSIGNED_BYTE),
                                                         0,
                                                         &lumaTexture)
            
            glBindTexture(CVOpenGLESTextureGetTarget(lumaTexture!),
                          CVOpenGLESTextureGetName(lumaTexture!))
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GLint(GL_LINEAR))
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GLint(GL_LINEAR))
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GLint(GL_CLAMP_TO_EDGE))
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GLint(GL_CLAMP_TO_EDGE))
            
            // chroma
            glActiveTexture(GLenum(GL_TEXTURE1))
            CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                         videoTextureCache,
                                                         pixel,
                                                         nil,
                                                         GLenum(GL_TEXTURE_2D),
                                                         GLint(GL_LUMINANCE_ALPHA),
                                                         GLsizei(width / 2),
                                                         GLsizei(height / 2),
                                                         GLenum(GL_LUMINANCE_ALPHA),
                                                         GLenum(GL_UNSIGNED_BYTE),
                                                         1,
                                                         &chromaTexture)
            glBindTexture(CVOpenGLESTextureGetTarget(chromaTexture!),
                          CVOpenGLESTextureGetName(chromaTexture!))
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GLint(GL_LINEAR))
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GLint(GL_LINEAR))
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GLint(GL_CLAMP_TO_EDGE))
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GLint(GL_CLAMP_TO_EDGE))
            
            glBindFramebuffer(GLenum(GL_FRAMEBUFFER), frameBuffer)
            
            glViewport(0, 0, GLsizei(backingWidth), GLsizei(backingHeight))
        }
        
        glClearColor(1.0, 1.0, 1.0, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        // use program
        glUseProgram(program)
        glUniformMatrix3fv(uniforms[.ColorConversionMatrix]!, 1, GLboolean(GL_FALSE), preferredConversion)
        
        let vertexSamplingRect = AVMakeRect(
            aspectRatio: CGSize(width: CGFloat(backingWidth), height: CGFloat(backingHeight)),
            insideRect: layer.bounds)
        
        var normalizedSamplingSize = CGSize.zero
        let cropScaleAmount = CGSize(width: vertexSamplingRect.size.width / layer.bounds.size.width,
                                     height: vertexSamplingRect.size.height / layer.bounds.size.height)
        
        if cropScaleAmount.width > cropScaleAmount.height {
            normalizedSamplingSize.width = 1.0
            normalizedSamplingSize.height = cropScaleAmount.height / cropScaleAmount.width
        } else {
            normalizedSamplingSize.width = 1.0
            normalizedSamplingSize.height = cropScaleAmount.width / cropScaleAmount.height
        }
        
        let quadVertexData: [GLfloat] = [GLfloat(normalizedSamplingSize.width), GLfloat(normalizedSamplingSize.height),
                                         GLfloat(normalizedSamplingSize.width), GLfloat(-1 * normalizedSamplingSize.height),
                                         GLfloat(-1 * normalizedSamplingSize.width), GLfloat( normalizedSamplingSize.height),
                                         GLfloat(-1 * normalizedSamplingSize.width), GLfloat(-1 * normalizedSamplingSize.height)]
        glVertexAttribPointer(Attribute.vertex.rawValue,
                              2,
                              GLenum(GL_FLOAT),
                              GLboolean(GL_FALSE),
                              0,
                              quadVertexData)
        glEnableVertexAttribArray(Attribute.vertex.rawValue)
        
        let quadTextureData: [GLfloat] = [
            0, 0,
            1, 0,
            0, 1,
            1, 1,
            ]
        
        glVertexAttribPointer(Attribute.texcoord.rawValue,
                              2,
                              GLenum(GL_FLOAT),
                              GLboolean(GL_FALSE),
                              0,
                              quadTextureData)
        
        glEnableVertexAttribArray(Attribute.texcoord.rawValue)
        
        glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0, 4)
        
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), renderBuffer)
        
        if EAGLContext.current() == context {
            context?.presentRenderbuffer(Int(renderBuffer))
        }
        
        
    }

}
