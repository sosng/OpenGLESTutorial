//
//  GLView.swift
//  GL-Triangle
//
//  Created by naver on 2018/10/17.
//  Copyright © 2018 naver. All rights reserved.
//

import UIKit
import GLKit

struct Vertext {
    var x: GLfloat
    var y: GLfloat
    var z: GLfloat
    var r: GLfloat
    var g: GLfloat
    var b: GLfloat
    var a: GLfloat
    
    init(_ x: GLfloat, _ y: GLfloat, _ z: GLfloat, _ r: GLfloat, _ g: GLfloat, b: GLfloat, a: GLfloat) {
        self.x = x
        self.y = y
        self.z = z
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }
}

extension Array {
    var size: Int {
        return MemoryLayout<Element>.stride * count
    }
}

class GLView: UIView {
    
    private var context: EAGLContext?
    private var frameBuffer = GLuint()
    private var colorRenderBuffer = GLuint()
    
    private var vao = GLuint()
    private var vbo = GLuint()
    
    var vertices = [Vertext(1, -1, 0, 1, 0, b: 0, a: 1),
                    Vertext(-1, -1, 0, 0, 1, b: 0, a: 1),
                    Vertext(0, 1, 0, 0, 0, b: 1, a: 1)]
    
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
        // 设置帧缓存
        setupFrameBuffer()
        // 设置渲染缓存
        setupRenderBufer()
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
        glDeleteRenderbuffers(0, &colorRenderBuffer)
        colorRenderBuffer = 0
    }
    
    private func setupFrameBuffer() {
        glGenFramebuffers(1, &frameBuffer)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), frameBuffer)
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER),
                                  GLenum(GL_COLOR_ATTACHMENT0),
                                  GLenum(GL_RENDERBUFFER),
                                  colorRenderBuffer)
    }
    
    private func setupRenderBufer() {
        glGenRenderbuffers(1, &colorRenderBuffer)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), colorRenderBuffer)
    }
    
    private func render() {
        glClearColor(0, 1.0, 1.0, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))

    }
    
    
    
}

