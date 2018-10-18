//
//  GLView.swift
//  GL002
//
//  Created by naver on 2018/10/18.
//  Copyright © 2018 naver. All rights reserved.
//

import UIKit
import GLKit

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
        
    }
    
    private func setupContext() {
        context = EAGLContext(api: .openGLES2)
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
        var fragSahder = GLuint()
        
        var program = glCreateProgram()
        compile(shader: &vertShader, type: GLenum(GL_VERTEX_SHADER), file: vertName)
        compile(shader: &fragSahder, type: GLenum(GL_FRAGMENT_SHADER), file: fragName)
        
        glDeleteShader(vertShader)
        glDeleteShader(fragSahder)
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
    
}
