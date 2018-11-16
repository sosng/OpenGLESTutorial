//
//  GLView.swift
//  GL003-Camera
//
//  Created by naver on 2018/11/15.
//  Copyright © 2018 naver. All rights reserved.
//

import UIKit
import GLKit

class GLView: UIView {
    
    private var context: EAGLContext?
    private var shader: Shader!
    private var vao = GLuint()
    private var vbo = GLuint()
    private var ebo = GLuint()
    private var renderBuffer = GLuint()
    private var frameBuffer = GLuint()
    
    override class var layerClass: AnyClass {
        return CAEAGLLayer.self
    }
    
    
    private var vertices: [Vertext] = [Vertext(<#T##x: GLfloat##GLfloat#>, <#T##y: GLfloat##GLfloat#>, <#T##z: GLfloat##GLfloat#>, <#T##w: GLfloat##GLfloat#>, <#T##r: GLfloat##GLfloat#>, <#T##g: GLfloat##GLfloat#>, <#T##b: GLfloat##GLfloat#>, <#T##a: GLfloat##GLfloat#>)]
    
    override func layoutSubviews() {
        setupLayer()
        setupContext()
        destoryFrameAndRenderBuffer()
        setupRenderBuffer()
        setupFrameBuffer()
        setupShader()
    }
    
    private func setupLayer() {
        contentScaleFactor = UIScreen.main.scale
        if let glLayer = layer as? CAEAGLLayer {
            glLayer.drawableProperties = [kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8, kEAGLDrawablePropertyRetainedBacking: false]
            glLayer.isOpaque = true
        }
    }
    
    private func setupContext() {
        context = EAGLContext(api: .openGLES2)
        EAGLContext.setCurrent(context)
    }
    
    private func setupShader() {
        shader = Shader(vertexShader: "shaderv.vsh", fragShader: "shaderf.fsh")
    }
    
    private func destoryFrameAndRenderBuffer() {
        glDeleteFramebuffers(1, &frameBuffer)
        frameBuffer = 0
        glDeleteRenderbuffers(1, &renderBuffer)
        renderBuffer = 0
    }
    
    private func setupRenderBuffer() {
        glGenRenderbuffers(1, &frameBuffer)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), renderBuffer)
        context?.renderbufferStorage(Int(GL_RENDERBUFFER), from: layer as? CAEAGLLayer)
    }
    
    private func setupFrameBuffer() {
        glGenFramebuffers(1, &frameBuffer)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), frameBuffer)
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER),
                                  GLenum(GL_COLOR_ATTACHMENT0),
                                  GLenum(GL_RENDERBUFFER),
                                  renderBuffer)
    }
    
    
    private func render() {
        glClearColor(0.5, 0.5, 0.5, 0.5)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        let scale = UIScreen.main.scale
        glViewport(GLint(frame.origin.x * scale),
                   GLint(frame.origin.y * scale),
                   GLsizei(frame.width * scale),
                   GLsizei(frame.height * scale))
        
        // vao
        glGenBuffers(1, &vao)
        glBindVertexArrayOES(vao)
        
        // vbo
        glGenBuffers(1, &vbo)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo)
        glBufferData(GLenum(GL_ARRAY_BUFFER), <#T##size: GLsizeiptr##GLsizeiptr#>, <#T##data: UnsafeRawPointer!##UnsafeRawPointer!#>, <#T##usage: GLenum##GLenum#>)
    }
    
    private func update() {
        
    }

}
