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
    private var shader: Shader!
    override class var layerClass: AnyClass {
        return CAEAGLLayer.self
    }
    
    private var degree: Float = 10.0
    private var yDegree: Float = 10.0
    private var bX = false
    private var bY = false
    private var timer: Timer?
    
    
    private let incides: [GLubyte] = [0, 3, 2,
                                               0, 1, 3,
                                               0, 2, 4,
                                               0, 4, 1,
                                               2, 3, 4,
                                               1, 4, 3,]
    
    private let vertices = [Vertext(-0.5, 0.5, 0.0, 1.0, 0.0, 1.0),
                            Vertext(0.5, 0.5, 0.0, 1.0, 0.0, 1.0),
                            Vertext(-0.5, -0.5, 0.0, 1.0, 1.0, 1.0),
                            Vertext(0.5, -0.5, 0.0, 1.0, 1.0, 1.0),
                            Vertext(0.0, 0.0, 1.0, 0.0, 1.0, 0.0),]
    
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
    
    private func render() {
        glClearColor(0.5, 0.5, 0.5, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        shader.prepareDraw()
        
        let scale = UIScreen.main.scale
        glViewport(GLint(frame.origin.x * scale),
                   GLint(frame.origin.y * scale),
                   GLint(frame.size.width * scale),
                   GLint(frame.size.height * scale))
        
        shader.prepareDraw()
        
        glGenVertexArraysOES(1, &vao)
        glBindVertexArrayOES(vao)

        glGenBuffers(1, &vbo)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo)
        glBufferData(GLenum(GL_ARRAY_BUFFER),
                     vertices.size,
                     vertices,
                     GLenum(GL_DYNAMIC_DRAW))
        
        // shader attribute
        let postition = shader.attributeLocation("position")
        glVertexAttribPointer(postition,
                              3,
                              GLenum(GL_FLOAT),
                              GLboolean(GL_FALSE),
                              GLsizei(MemoryLayout<Vertext>.stride),
                              nil)
        glEnableVertexAttribArray(postition)
        
        let color = shader.attributeLocation("positionColor")
        glVertexAttribPointer(color,
                              3,
                              GLenum(GL_FLOAT),
                              GLboolean(GL_FALSE),
                              GLsizei(MemoryLayout<Vertext>.stride),
                              UnsafeRawPointer(bitPattern: MemoryLayout<Vertext>.stride * 3))
        glEnableVertexAttribArray(color)
    
        
        let pojectionMatrixSlot = shader.unifromLocation("projectionMatrix")
        let modelViewMatrixSlot = shader.unifromLocation("modelViewMatrix")
        
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
//        ksTranslate(&modelViewMatrix, 0.0, 0.0, -10.0)
        // 旋转
        var rotationMatrix = KSMatrix4()
        ksMatrixLoadIdentity(&rotationMatrix)
        ksRotate(&rotationMatrix, degree, 1.0, 0.0, 0.0) // X 轴
        ksRotate(&rotationMatrix, yDegree, 0.0, 1.0, 0.0) // Y 轴
        
        // 将变换矩阵相乘
        var temp = modelViewMatrix
        ksMatrixMultiply(&temp, &rotationMatrix, &modelViewMatrix)
        memcpy(&modelViewMatrix, &temp, MemoryLayout<KSMatrix4>.size)
        //
        glUniformMatrix4fv(GLint(modelViewMatrixSlot),
                           1,
                           GLboolean(GL_FALSE),
                           &modelViewMatrix.m.0.0)
        
        glDrawElements(GLenum(GL_TRIANGLES),
                       GLsizei(incides.size),
                       GLenum(GL_UNSIGNED_BYTE),
                       incides)
        
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
        degree += (bX ? 1 : 0) * 5
        yDegree += (bY ? 1 : 0) * 5
        render()
    }
}
