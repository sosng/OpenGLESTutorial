//
//  GLView.swift
//  GL-Triangle
//
//  Created by naver on 2018/10/17.
//  Copyright © 2018 naver. All rights reserved.
//

import UIKit
import GLKit


class GLView: UIView {
    
    private var context: EAGLContext?
    private var frameBuffer = GLuint()
    private var renderBuffer = GLuint()
    
    private var vao = GLuint()
    private var vbo = GLuint()
    
    private var shader: Shader!
    
    var vertices = [Vertext(1, 1, 0, 1, 1, 0, 0, 1),
                    Vertext(1, -1, 0, 0, 1, 1, 0, 1),
                    Vertext(0, 1, 0, 0, 0, 1, 1, 1)]
    
    override class var layerClass: AnyClass {
        return CAEAGLLayer.self
    }
    
    override func layoutSubviews() {
        // 设置layer
        setupLayer()
        // 设置context
        setupContext()
        // 避免重复设置，先要清除缓存
        destoryFrameAndRenderBuffer()
        // 设置渲染缓存
        setupRenderBufer()
        // 设置帧缓存
        setupFrameBuffer()
        // load shader
        loadShader()
        // 渲染
        render()
    }
    
    private func setupLayer() {
        guard let glLayer = layer as? CAEAGLLayer else { return }
        glLayer.drawableProperties = [kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8,
                                      kEAGLDrawablePropertyRetainedBacking: true]
        glLayer.isOpaque = true
        glLayer.contentsScale = UIScreen.main.scale
    }
    
    private func setupContext() {
        context = EAGLContext(api: .openGLES2)
        EAGLContext.setCurrent(context)
    }
    
    private func destoryFrameAndRenderBuffer() {
        glDeleteFramebuffers(0, &frameBuffer)
        frameBuffer = 0
        glDeleteRenderbuffers(0, &renderBuffer)
        renderBuffer = 0
    }
    
    private func setupRenderBufer() {
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
    
    private func render() {
        // background color
        glClearColor(0.5, 0.5, 0.5, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        //设置viewport
        let scale = UIScreen.main.scale
        glViewport(0, 0, GLsizei(scale * bounds.width), GLsizei(scale * bounds.height))
        
        // use shader
        
        
        // start
        // vao
        var vao = GLuint()
        glGenVertexArraysOES(1, &vao)
        glBindVertexArrayOES(vao)
        
        // vbo
        var vbo = GLuint()
        
        glGenBuffers(1, &vbo)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo)
        glBufferData(GLenum(GL_ARRAY_BUFFER),
                     GLsizeiptr(vertices.size),
                     vertices,
                     GLenum(GL_STATIC_DRAW))
        
        // 将position传给shader
        let position = shader.attributeLocation("a_position")
        glVertexAttribPointer(position,
                              3,
                              GLenum(GL_FLOAT),
                              GLboolean(GL_FALSE),
                              GLsizei(MemoryLayout<Vertext>.stride),
                              nil)
        glEnableVertexAttribArray(position)
        
        shader.prepareDraw()
        // 开始绘制
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 3)
        
        context?.presentRenderbuffer(Int(GL_RENDERBUFFER))
        //
    }
    
    
    
}

