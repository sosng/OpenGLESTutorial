//
//  GLView.swift
//  GL-EBO
//
//  Created by naver on 2018/10/30.
//  Copyright © 2018 naver. All rights reserved.
//

import UIKit
import GLKit

class GLView: UIView {

    private var context: EAGLContext?
    
    //
    private var renderBuffer = GLuint()
    private var frameBuffer = GLuint()
    
    private var shader: Shader!
    
    private var verticis = [Vertext(1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), // 右上
                            Vertext(1.0, -1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 1.0), // 右下
                            Vertext(-1.0, -1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 1.0), // 左下
                            Vertext(-1.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 1.0)] // 左上
    
    private var indecis: [GLubyte] = [0, 1, 2,
                                      2, 3, 0]
    
    var vao = GLuint()
    var vbo = GLuint()
    var ebo = GLuint()
    
    override class var layerClass: AnyClass {
        return CAEAGLLayer.self
    }
    
    override func layoutSubviews() {
        setupLayer()
        setupContext()
        deinitRenderFrameBuffer()
        setupRenderBuffer()
        setupFrameBuffer()
        loadShader()
        bufferObjects()
        render()
    }
    
    private func setupLayer() {
        if let glLayer = self.layer as? CAEAGLLayer {
            glLayer.isOpaque = true
            glLayer.drawableProperties = [kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8, kEAGLDrawablePropertyRetainedBacking : true]
            glLayer.contentsScale = UIScreen.main.scale
        }
    }
    
    private func setupContext() {
        context = EAGLContext(api: .openGLES2)
        EAGLContext.setCurrent(context)
    }
    
    private func deinitRenderFrameBuffer() {
        glDeleteFramebuffers(0, &frameBuffer)
        frameBuffer = 0
        glDeleteRenderbuffers(0, &renderBuffer)
        renderBuffer = 0
    }
    
    private func setupRenderBuffer() {
        glGenRenderbuffers(1, &renderBuffer)
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
    
    private func loadShader() {
        shader = Shader(vertexShader: "shaderv.vsh", fragShader: "shaderf.fsh")
    }
    
    private func bufferObjects() {
    }
    
    private func render() {
        glClearColor(0.5, 0.5, 0.5, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        let scale = UIScreen.main.scale
        glViewport(0, 0, GLsizei(scale * bounds.width), GLsizei(scale * bounds.height))
        
        // vao
        glGenVertexArraysOES(1, &vao)
        glBindVertexArrayOES(vao)
        
        // vbo
        glGenBuffers(1, &vbo)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo)
        glBufferData(GLenum(GL_ARRAY_BUFFER),
                     GLsizeiptr(verticis.size),
                     verticis,
                     GLenum(GL_STATIC_DRAW))
        
        // ebo
        glGenBuffers(1, &ebo)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), ebo)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER),
                     GLsizeiptr(indecis.size),
                     indecis,
                     GLenum(GL_STATIC_DRAW))
        
        let position = shader.attributeLocation("a_position")
        glVertexAttribPointer(position,
                              3,
                              GLenum(GL_FLOAT),
                              GLboolean(GL_FALSE),
                              GLsizei(MemoryLayout<Vertext>.stride),
                              nil)
        glEnableVertexAttribArray(position)
        
        // Unbind VAO
        glBindVertexArrayOES(0)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), 0)
        
        shader.prepareDraw()
        
        glBindVertexArrayOES(vao)
        
        glDrawElements(GLenum(GL_TRIANGLES),
                       GLsizei(indecis.count),
                       GLenum(GL_UNSIGNED_BYTE),
                       nil)
        
        context?.presentRenderbuffer(Int(GL_RENDERBUFFER))
        glBindVertexArrayOES(0)
    }
    
    
}
