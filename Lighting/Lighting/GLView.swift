//
//  GLView.swift
//  GL003-transformation
//
//  Created by naver on 2018/10/26.
//  Copyright © 2018 naver. All rights reserved.
//

import UIKit
import GLKit

class GLView: UIView {

    private var context: CVEAGLContext?
    private var renderBuffer = GLuint()
    private var frameBuffer = GLuint()
    private var vao = GLuint()
    private var vbo = GLuint()
    private var ebo = GLuint()
    private var normalVAO = GLuint()
    private var normalVBO = GLuint()
    private var shader: Shader!
    override class var layerClass: AnyClass {
        return CAEAGLLayer.self
    }
    
    private var degree: Float = 0.0
    private var yDegree: Float = 0.0
    private var bX = false
    private var bY = false
    private var timer: Timer?
    
    
//    private let incides: [GLubyte] = [0, 3, 2,
//                                      0, 1, 3,
//                                      0, 2, 4,
//                                      0, 4, 1,
//                                      2, 3, 4,
//                                      1, 4, 3,]
    
    let incides: [GLubyte] = [0, 2, 1,
                              0, 3, 2,
                              3, 4, 2,
                              2, 4, 7,
                              2, 7, 6,
                              2, 6, 1,
                              1, 6, 5,
                              0, 1, 5,
                              0, 5, 3,
                              3, 5, 4,
                              5, 7, 4,
                              5, 6, 7]
//    
//    let vertices = [Vertext(-0.5, 0.5, -0.5, 1.0,     1.0, 0.0, 0.0, 1.0,   0, 1, 0),
//                    Vertext(0.5, 0.5, -0.5, 1.0,      1.0, 0.0, 0.0, 1.0,   0, 0, -1),
//                    Vertext(0.5, 0.5, 0.5, 1.0,       1.0, 0.0, 0.0, 1.0,   0, 0, 1),
//                    Vertext(-0.5, 0.5, 0.5, 1.0,      1.0, 0.0, 0.0, 1.0,   -1, 0, 0),
//                    Vertext(-0.5, -0.5, 0.5, 1.0,     1.0, 0.0, 0.0, 1.0,   0, -1, 0),
//                    Vertext(-0.5, -0.5, -0.5, 1.0,    1.0, 0.0, 0.0, 1.0,   0, 0, -1),
//                    Vertext(0.5, -0.5, -0.5, 1.0,     1.0, 0.0, 0.0, 1.0,   0, -1, 0),
//                    Vertext(0.5, -0.5, 0.5, 1.0,      1.0, 0.0, 0.0, 1.0,   1, 0, 0)]
    
    let vertices = [
    -0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
    0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
    0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
    0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
    -0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
    
    -0.5f, -0.5f,  0.5f,  0.0f,  0.0f, 1.0f,
    0.5f, -0.5f,  0.5f,  0.0f,  0.0f, 1.0f,
    0.5f,  0.5f,  0.5f,  0.0f,  0.0f, 1.0f,
    0.5f,  0.5f,  0.5f,  0.0f,  0.0f, 1.0f,
    -0.5f,  0.5f,  0.5f,  0.0f,  0.0f, 1.0f,
    -0.5f, -0.5f,  0.5f,  0.0f,  0.0f, 1.0f,
    
    -0.5f,  0.5f,  0.5f, -1.0f,  0.0f,  0.0f,
    -0.5f,  0.5f, -0.5f, -1.0f,  0.0f,  0.0f,
    -0.5f, -0.5f, -0.5f, -1.0f,  0.0f,  0.0f,
    -0.5f, -0.5f, -0.5f, -1.0f,  0.0f,  0.0f,
    -0.5f, -0.5f,  0.5f, -1.0f,  0.0f,  0.0f,
    -0.5f,  0.5f,  0.5f, -1.0f,  0.0f,  0.0f,
    
    0.5f,  0.5f,  0.5f,  1.0f,  0.0f,  0.0f,
    0.5f,  0.5f, -0.5f,  1.0f,  0.0f,  0.0f,
    0.5f, -0.5f, -0.5f,  1.0f,  0.0f,  0.0f,
    0.5f, -0.5f, -0.5f,  1.0f,  0.0f,  0.0f,
    0.5f, -0.5f,  0.5f,  1.0f,  0.0f,  0.0f,
    0.5f,  0.5f,  0.5f,  1.0f,  0.0f,  0.0f,
    
    -0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,
    0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,
    0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,
    0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,
    -0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,
    -0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,
    
    -0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f,
    0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f,
    0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,
    0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,
    -0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,
    -0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f
    ]
    
    // 每个面的法线向量
//    var normals = [NormalVector(0, 0, 0)]

//    private let vertices = [Vertext(-0.5, 0.5, 0.0, 1.0,   1.0, 0.0, 0.0, 1.0),
//                            Vertext(0.5, 0.5, 0.0, 1.0,    0.0, 1.0, 0.0, 1.0),
//                            Vertext(-0.5, -0.5, 0.0, 1.0,  0.0, 0.0, 1.0, 1.0),
//                            Vertext(0.5, -0.5, 0.0, 1.0,   1.0, 0.0, 0.0, 1.0),
//                            Vertext(0.0, 0.0, 1.0, 1.0,    0.0, 0.0, 0.0, 1.0),]
    
    override func layoutSubviews() {
        setupLayer()
        setupContext()
        destoryRenderBufferAndFrameBuffer()
        setupRenderBuffer()
        setupFrameBuffer()
        setupShader()
        render()
    }
    
    
    private func setupLayer() {
        contentScaleFactor = UIScreen.main.scale
        if let glLayer = self.layer as? CAEAGLLayer {
            glLayer.drawableProperties = [kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8, kEAGLDrawablePropertyRetainedBacking: false]
            glLayer.isOpaque = true
        }
    }
    
    private func setupContext() {
        context = CVEAGLContext(api: .openGLES2)
        EAGLContext.setCurrent(context)
        glEnable(GLenum(GL_DEPTH_TEST))
    }
    
    private func destoryRenderBufferAndFrameBuffer() {
        glDeleteFramebuffers(1, &frameBuffer)
        frameBuffer = 0
        glDeleteRenderbuffers(1, &renderBuffer)
        renderBuffer = 0
    }
    
    private func setupRenderBuffer() {
        glGenRenderbuffers(1, &renderBuffer)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), renderBuffer)
        context?.renderbufferStorage(Int(GL_RENDERBUFFER), from: self.layer as? CAEAGLLayer)
    }
    
    private func setupFrameBuffer() {
        glGenFramebuffers(1, &frameBuffer)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), frameBuffer)
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER),
                                  GLenum(GL_COLOR_ATTACHMENT0),
                                  GLenum(GL_RENDERBUFFER),
                                  renderBuffer)
    }
    
    private func setupShader() {
        shader = Shader(vertexShader: "shaderv.vsh", fragShader: "shaderf.fsh")
    }
    
    private func prepareBuffer() {
        
    }
    
    private func render() {
        glClearColor(0.5, 0.5, 0.5, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
        
        let scale = UIScreen.main.scale
        glViewport(GLint(frame.origin.x * scale),
                   GLint(frame.origin.y * scale),
                   GLint(frame.size.width * scale),
                   GLint(frame.size.height * scale))
        
        shader.prepareDraw()
        
        glGenVertexArraysOES(1, &vao)
        glBindVertexArrayOES(vao)

        if vbo == 0 {
            glGenBuffers(1, &vbo)
        }
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo)
        glBufferData(GLenum(GL_ARRAY_BUFFER),
                     vertices.size,
                     vertices,
                     GLenum(GL_DYNAMIC_DRAW))
        
        glGenBuffers(1, &ebo)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), ebo)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER),
                     incides.size,
                     incides,
                     GLenum(GL_DYNAMIC_DRAW))
        
        // shader attribute
        let postition = shader.attributeLocation("position")
        glVertexAttribPointer(postition,
                              4,
                              GLenum(GL_FLOAT),
                              GLboolean(GL_FALSE),
                              GLsizei(MemoryLayout<Vertext>.stride),
                              nil)
        glEnableVertexAttribArray(postition)
        
        let color = shader.attributeLocation("positionColor")
        glVertexAttribPointer(color,
                              4,
                              GLenum(GL_FLOAT),
                              GLboolean(GL_FALSE),
                              GLsizei(MemoryLayout<Vertext>.stride),
                              UnsafeRawPointer(bitPattern: MemoryLayout<GLfloat>.size * 4))
        glEnableVertexAttribArray(color)
        
        // 法线
        let normal = shader.attributeLocation("normal")
        glVertexAttribPointer(normal,
                              3,
                              GLenum(GL_FLOAT),
                              GLboolean(GL_FALSE),
                              GLsizei(MemoryLayout<NormalVector>.stride),
                               UnsafeRawPointer(bitPattern: MemoryLayout<GLfloat>.size * 8))
        glEnableVertexAttribArray(normal)
        
        // 平行光照
        let lightDirection = GLKVector3(v: (0.0, -1.0, 0.0))
        
        glBindVertexArrayOES(0)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), 0)
        
        let pojectionMatrixSlot = shader.unifromLocation("projectionMatrix")
        let modelViewMatrixSlot = shader.unifromLocation("modelViewMatrix")
        // 平行光
        let lightDirectionSlot = shader.unifromLocation("lightDirection")
        
        let width = frame.size.width
        let height = frame.size.height
        let aspect = Float(width / height)
        
        // 透视变换
        var projectionMatrix = GLKMatrix4Identity
        projectionMatrix = GLKMatrix4MakePerspective(.pi / 2, aspect, 0, 20.0)
        
        // 设置到shader
        glUniformMatrix4fv(GLint(pojectionMatrixSlot),
                           1,
                           GLboolean(GL_FALSE),
                           projectionMatrix.array)
        glEnable(GLenum(GL_CULL_FACE))
        
        // 模型
        var modelViewMatrix = GLKMatrix4Identity
        
        // 平移
        modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0.0, 0.0, -3.0)
        // 旋转
        var rotationMatrix = GLKMatrix4Identity
        rotationMatrix = GLKMatrix4Rotate(rotationMatrix, degree, 1.0, 0.0, 0.0)  // X 轴
        rotationMatrix = GLKMatrix4Rotate(rotationMatrix, yDegree, 0.0, 1.0, 0.0) // Y 轴
        
        // 将变换矩阵相乘
        var temp = GLKMatrix4Multiply(modelViewMatrix, rotationMatrix)
        
        // 设置到shader
        glUniformMatrix4fv(GLint(modelViewMatrixSlot),
                           1,
                           GLboolean(GL_FALSE),
                           temp.array)
        glEnable(GLenum(GL_CULL_FACE))
        
        // 法线矩阵
        var canInvert = true
        let normalMatrix = GLKMatrix4InvertAndTranspose(modelViewMatrix, &canInvert)
        if canInvert {
            let normalMatrixSlot = shader.unifromLocation("normalMatrix")
            glUniformMatrix4fv(GLint(normalMatrixSlot),
                               1,
                               GLboolean(GL_FALSE),
                               normalMatrix.array)
        }
        
        // 光照设置到 shader
        glUniform3fv(GLint(lightDirectionSlot), 1, lightDirection.array)
        
        // start render
        glBindVertexArrayOES(vao)
        glDrawElements(GLenum(GL_TRIANGLES),
                       GLsizei(incides.count),
                       GLenum(GL_UNSIGNED_BYTE),
                       nil)
        glBindVertexArrayOES(0)
        
        context?.presentRenderbuffer(Int(GL_RENDERBUFFER))
    }
    
    
    
    @IBAction func tapX(_ sender: Any) {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(onRes), userInfo: nil, repeats: true)
        }
        bX = !bX
    }
    
    @IBAction func tapY(_ sender: Any) {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(onRes), userInfo: nil, repeats: true)
        }
        bY = !bY
    }
    
}

extension GLView {
    @objc func onRes() {
        degree += (bX ? 1 : 0) * GLKMathDegreesToRadians(5)
        yDegree += (bY ? 1 : 0) * GLKMathDegreesToRadians(5)
        render()
    }
}

