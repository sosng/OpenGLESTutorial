//
//  GLLearView.swift
//  GL003-transformation
//
//  Created by naver on 2018/11/5.
//  Copyright © 2018 naver. All rights reserved.
//

import UIKit
import GLKit

class GLLearView: UIView {

    override class var layerClass: AnyClass {
        return CAEAGLLayer.self
    }
    private var context: EAGLContext?
    private var renderBuffer = GLuint()
    private var frameBuffer = GLuint()
    private var vbo = GLuint(0)
    private var program: GLuint?
    
    private var degree: Float = 0.0
    private var yDegree: Float = 0.0
    
    private let incides = [0, 3, 2,
                           0, 1, 3,
                           0, 2, 4,
                           0, 4, 1,
                           2, 3, 4,
                           1, 4, 3,]
    
    private let vertices = [Vertext(-0.5, 0.5, 0.0, 1.0,   1.0, 0.0, 1.0, 1.0),
                            Vertext(0.5, 0.5, 0.0, 1.0,    0.0, 0.0, 1.0, 1.0),
                            Vertext(-0.5, -0.5, 0.0, 1.0,  1.0, 1.0, 1.0, 1.0),
                            Vertext(0.5, -0.5, 0.0, 2.0,   1.0, 0.0, 1.0, 1.0),
                            Vertext(0.0, 0.0, 1.0, 2.0,    0.0, 1.0, 0.0, 1.0),]

    override func layoutSubviews() {
        setupLayer()
        setupContext()
        destoryFrameRenderBuffer()
        setupRenderBuffer()
        setupFrameBuffer()
        render()
    }
    
    private func setupLayer() {
        if let glLayer = layer as? CAEAGLLayer {
            glLayer.drawableProperties = [kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8, kEAGLDrawablePropertyRetainedBacking: false]
            glLayer.isOpaque = true
        }
    }
    
    private func setupContext() {
        context = EAGLContext(api: .openGLES2)
        EAGLContext.setCurrent(context)
    }
    
    private func destoryFrameRenderBuffer() {
        glDeleteFramebuffers(1, &frameBuffer)
        frameBuffer = 0
        glDeleteRenderbuffers(1, &renderBuffer)
        renderBuffer = 0
    }
    
    private func setupRenderBuffer() {
        glGenRenderbuffers(1, &renderBuffer)
        glBindBuffer(GLenum(GL_RENDERBUFFER), renderBuffer)
        context?.renderbufferStorage(Int(GL_RENDERBUFFER), from: self.layer as? CAEAGLLayer)
    }
    
    private func setupFrameBuffer()  {
        glGenFramebuffers(1, &frameBuffer)
        glBindBuffer(GLenum(GL_FRAMEBUFFER), frameBuffer)
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER),
                                  GLenum(GL_COLOR_ATTACHMENT0),
                                  GLenum(GL_RENDERBUFFER),
                                  renderBuffer)
    }
    
    private func render() {
        glClearColor(0.5, 1.0, 0.5, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        let scale = UIScreen.main.scale
        glViewport(GLint(frame.origin.x * scale),
                   GLint(frame.origin.y * scale),
                   GLint(frame.size.width * scale),
                   GLint(frame.size.height * scale))
        
        if let _ = program  {
            glDeleteProgram(program!)
            program = 0
        }
        
        program = load(vertexShader: "shaderv.vsh", fragShader: "shaderf.fsh")
        guard let program = program else {
            return
        }
        glUseProgram(program)
        glLinkProgram(program)
        
        //
        if vbo == GLuint(0) {
            glGenBuffers(1, &vbo)
        }
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo)
        glBufferData((GLenum(GL_ARRAY_BUFFER)),
                     vertices.size,
                     vertices,
                     GLenum(GL_DYNAMIC_DRAW))
        
        
        //
        var position = glGetAttribLocation(program, "position")
        glVertexAttribPointer(GLuint(position),
                              3,
                              GLenum(GL_FLOAT),
                              GLboolean(GL_FALSE),
                              GLsizei(MemoryLayout<Vertext>.stride),
                              nil)
        glEnableVertexAttribArray(GLuint(position))
        
        var positionColor = glGetAttribLocation(program, "positionColor")
        glVertexAttribPointer(GLuint(positionColor),
                              3,
                              GLenum(GL_FLOAT),
                              GLboolean(GL_FALSE),
                              GLsizei(MemoryLayout<Vertext>.stride),
                              UnsafeRawPointer(bitPattern: MemoryLayout<Vertext>.stride * 3))
        glEnableVertexAttribArray(GLuint(positionColor))

        var pojectionMatrixSlot = glGetUniformLocation(program, "projectionMatrix")
        var modelViewMatrixSlot = glGetUniformLocation(program, "modelViewMatrix")
        
        let width = frame.size.width
        let height = frame.size.height
        let aspect = Float(width / height)
        
        // 透视变换
        var projectionMatrix = KSMatrix4()
        ksMatrixLoadIdentity(&projectionMatrix)
        
        // 透视变换.视角30°
        ksPerspective(&projectionMatrix, 30.0, aspect, 5.0, 20.0)
        
        // 设置glsl里面的投影矩阵
        glUniformMatrix4fv(GLint(pojectionMatrixSlot),
                           1,
                           GLboolean(GL_FALSE),
                           &projectionMatrix.m.0.0)
        glEnable(GLenum(GL_CULL_FACE))
        
        // 模型
        var modelViewMatrix = KSMatrix4()
        ksMatrixLoadIdentity(&modelViewMatrix)
        
        // 平移
        ksTranslate(&modelViewMatrix, 0.0, 0.0, -10.0)
        // 旋转
        var rotationMatrix = KSMatrix4()
        ksMatrixLoadIdentity(&rotationMatrix)
        ksRotate(&rotationMatrix, degree, 1.0, 0.0, 0.0) // X 轴
        ksRotate(&rotationMatrix, yDegree, 0.0, 1.0, 0.0) // Y 轴
        
        // 将变换矩阵相乘
        var temp = modelViewMatrix
        ksMatrixMultiply(&modelViewMatrix, &rotationMatrix, &temp)
//        memcpy(&modelViewMatrix, &temp, MemoryLayout<KSMatrix4>.size)
        //
        glUniformMatrix4fv(GLint(modelViewMatrixSlot),
                           1,
                           GLboolean(GL_FALSE),
                           &modelViewMatrix.m.0.0)
        
        glDrawElements(GLenum(GL_TRIANGLES),
                       GLsizei(incides.count),
                       GLenum(GL_UNSIGNED_INT),
                       incides)
        
        context?.presentRenderbuffer(Int(GL_RENDERBUFFER))
    }

    
    private func load(vertexShader: String, fragShader: String) -> GLuint {
        var verShader = GLuint()
        var frgShader = GLuint()
        var program = glCreateProgram()
        compile(shader: &verShader, type: GLenum(GL_VERTEX_SHADER), file: vertexShader)
        compile(shader: &frgShader, type: GLenum(GL_FRAGMENT_SHADER), file: fragShader)
        
        glAttachShader(program, verShader)
        glAttachShader(program, frgShader)
    
        glDeleteShader(verShader)
        glDeleteShader(frgShader)
        
        return program
    }
    
    private func compile(shader: inout GLuint, type: GLenum, file: String) {
        guard let path = Bundle.main.path(forResource: file, ofType: nil) else {
            exit(0)
        }
        do {
            // 1 - 读取shaders string
            let shaderString = try String(contentsOfFile: path, encoding: .utf8)
            // 2 - handler
            shader = glCreateShader(type)
            // 3 -
            var shaderStringLength = GLint(Int32(shaderString.lengthOfBytes(using: .utf8)))
            let shaderCString = shaderString.cString(using: .utf8)
            var pointer = UnsafePointer<GLchar>(shaderCString)
            // 4 -
            glShaderSource(shader, GLsizei(1), &pointer, &shaderStringLength)
            // 5 -
            glCompileShader(shader)
            // 6 -
            var compileStatus = GLint(0)
            glGetShaderiv(shader, GLenum(GL_COMPILE_STATUS), &compileStatus)
            
            if compileStatus == GL_FALSE {
                var infoLength: GLsizei = 0
                var bufferLength: GLsizei = 1024
                
                glGetShaderiv(shader, GLenum(GL_INFO_LOG_LENGTH), &infoLength)
                let info = Array(repeating: GLchar(0), count: Int(bufferLength))
                
                var actualLength: GLsizei = 0
                glGetShaderInfoLog(shader, bufferLength, &actualLength, UnsafeMutablePointer(mutating: info))
                
                print("=============\nshader compile status info: \(String(describing: String(validatingUTF8: info)))\n=============\nshader string:\n\(shaderString)=============")
                exit(0)
            }
        } catch {
            exit(0)
        }

    }
    
    
    @IBAction func pressedOnX(_ sender: UIButton) {
        
    }
    
    @IBAction func pressedOnY(_ sender: UIButton) {
        
    }
}
