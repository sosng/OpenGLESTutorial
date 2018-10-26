//
//  GLView.swift
//  GL002
//
//  Created by naver on 2018/10/18.
//  Copyright © 2018 naver. All rights reserved.
//

import UIKit
import GLKit
import CoreGraphics

class GLView: UIView {

    var context: EAGLContext?
    var eagLayer: CAEAGLLayer?
    var program = GLuint()
    var renderBuffer = GLuint()
    var frameBuffer = GLuint()
    
    override class var layerClass: AnyClass {
        return CAEAGLLayer.self
    }
    
    override func layoutSubviews() {
        setupLayer()
        setupContext()
        deinitRenderAndFrameBuffer()
        setupRenderBuffer()
        setupFrameBuffer()
        render()
    }
    
    private func render() {
        
        glClearColor(0, 1.0, 1.0, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        let scale = UIScreen.main.scale
        // 设置视口大小
        glViewport(GLint(frame.origin.x * scale), GLint(frame.origin.y * scale), GLsizei(frame.width * scale), GLsizei(frame.height * scale))
        
        // 读取文件路径
        guard  let vertFile = Bundle.main.path(forResource: "shaderv", ofType: "vsh"),
            let fragFile = Bundle.main.path(forResource: "shaderf", ofType: "fsh") else {
                return
        }
        // 加载shader
        program = load(vertexShader: vertFile, fragmentShader: fragFile)
        
        // 链接
        glLinkProgram(program)
        var linkSuccess = GLint()
        glGetProgramiv(program, GLenum(GL_LINK_STATUS), &linkSuccess)
        if linkSuccess == GL_FALSE {
            var infoLength: GLsizei = 0
            var bufferLength: GLsizei = 1024
            
            glGetShaderiv(program, GLenum(GL_INFO_LOG_LENGTH), &infoLength)
            let info = Array(repeating: GLchar(0), count: Int(bufferLength))
            
            var actualLength: GLsizei = 0
            glGetShaderInfoLog(program, bufferLength, &actualLength, UnsafeMutablePointer(mutating: info))
            
            print("=============\nshader link status info: \(String(validatingUTF8: info))\n=============")

//            return
        } else {
            print("Program link success")
            glUseProgram(program)
        }
        glUseProgram(program)

        // 顶点
        let vertecies = [Vertex(0.5, -0.5, 1.0, 1.0, 0.0),
                         Vertex(-0.5, 0.5, -1.0, 0.0, 1.0),
                         Vertex(-0.5, -0.5, -1.0, 0.0, 1.0),
                         Vertex(0.5, 0.5, -1.0, 1.0, 1.0),
                         Vertex(-0.5, 0.5, -1.0, 0.0, 1.0),
                         Vertex(0.5, -0.5, -1.0, 1.0, 0.0)]
        
        var attrBuffer = GLuint()
        glGenBuffers(1, &attrBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), attrBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), GLsizeiptr(vertecies.size), vertecies, GLenum(GL_DYNAMIC_DRAW))
        
        var position = GLuint(glGetAttribLocation(program, "position"))
        glVertexAttribPointer(position, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<Vertex>.stride), nil)
        glEnableVertexAttribArray(position)
        
        var textCoor = GLuint(glGetAttribLocation(program, "textCoordinate"))
        glVertexAttribPointer(textCoor, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<Vertex>.stride), UnsafeRawPointer(bitPattern: MemoryLayout<Vertex>.stride * 3))
        glEnableVertexAttribArray(textCoor)
        
        // 加载纹理
        setup(texture: "for_test")
        
        // 获得shader里面的变量，要在glLinkProgram后面
        var rotate = GLuint(glGetUniformLocation(program, "rotateMatrix"))
        
        let radians = GLfloat(10 * Float.pi / 180.0)
        let s = GLfloat(sin(radians))
        let c = GLfloat(cos(radians))
        
        // z轴旋转矩阵
        let zRotation: [GLfloat] = [c, -s, 0, 0.2,
                                    s, c, 0, 0,
                                    0, 0, 1.0, 0,
                                    0, 0, 0, 1,0]
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 6)
        context?.presentRenderbuffer(Int(GL_RENDERBUFFER))
    }
    
    private func setupContext() {
        context = EAGLContext(api: .openGLES2)
        EAGLContext.setCurrent(context)
    }
    
    private func setupLayer() {
        contentScaleFactor = UIScreen.main.scale
        eagLayer = layer as? CAEAGLLayer
        eagLayer?.isOpaque = true
        eagLayer?.drawableProperties = [kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8,
                                        kEAGLDrawablePropertyRetainedBacking: false];
    }
    
    private func setupRenderBuffer() {
        glGenRenderbuffers(1, &renderBuffer)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), renderBuffer)
        context?.renderbufferStorage(Int(GL_RENDERBUFFER), from: eagLayer)
    }
    
    private func setupFrameBuffer() {
        glGenFramebuffers(1, &frameBuffer)
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER),
                                  GLenum(GL_COLOR_ATTACHMENT0),
                                  GLenum(GL_RENDERBUFFER),
                                  frameBuffer)
    }
    
    private func deinitRenderAndFrameBuffer() {
        glDeleteFramebuffers(1, &frameBuffer)
        frameBuffer = 0
        glDeleteRenderbuffers(1, &renderBuffer)
        renderBuffer = 0
    }
    
    private func load(vertexShader vertName: String, fragmentShader fragName: String) -> GLuint {
        
        var vertShader = GLuint()
        var fragShader = GLuint()
        
        var program = glCreateProgram()
        compile(shader: &vertShader, type: GLenum(GL_VERTEX_SHADER), file: vertName)
        compile(shader: &fragShader, type: GLenum(GL_FRAGMENT_SHADER), file: fragName)
        
        glDeleteShader(vertShader)
        glDeleteShader(fragShader)
        return program
    }
    
    private func compile(shader: inout GLuint, type: GLenum, file: String) {
        do {
            shader = glCreateShader(type)
            let content = try String(contentsOfFile: file, encoding: .utf8)
            let cString = content.cString(using: String.Encoding.utf8)
            var pointer = UnsafePointer<GLchar>(cString)
            glShaderSource(shader, 1, &pointer, nil)
            glCompileShader(shader)
        } catch {
            print("compile shader error: \(error)")
        }
    }
    
    private func setup(texture: String) -> GLuint {
        // 获取纹理图片
        guard let spriteImage = UIImage(named: texture)?.cgImage else {
            print("failed to load image")
            return 0
        }
        
        // 读取图片的大小
        let width = spriteImage.width
        let height = spriteImage.height
        let spriteData = calloc(width * height * 4, MemoryLayout<GLubyte>.stride)
        let context = CGContext(data: spriteData,
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: width * 4,
                                space: spriteImage.colorSpace!,
                                bitmapInfo: CGImageAlphaInfo.last.rawValue)
        
        // 在CGContext上绘图
        context?.draw(spriteImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        // 绑定纹理到默认的纹理ID
        // 一张图片，相当于默认片元着色器里面的colormap，多张图片不可这么做
        
        glBindTexture(GLenum(GL_TEXTURE_2D), 0)
        
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GLint(GL_LINEAR))
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GLint(GL_LINEAR))
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GLint(GL_CLAMP_TO_EDGE))
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GLint(GL_CLAMP_TO_EDGE))
        
        let fw = width
        let fh = height
        
        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GLint(GL_RGBA), GLsizei(fw), GLsizei(fh), 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), spriteData)
        glBindTexture(GLenum(GL_TEXTURE_2D), 0)
        free(spriteData)
        return 0
    }
    
}



