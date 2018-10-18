//
//  GLTriangleView.swift
//  GL-Triangle
//
//  Created by naver on 2018/10/17.
//  Copyright © 2018 naver. All rights reserved.
//

import UIKit
import GLKit

class GLTriangleView: UIView {
    
    private var context: EAGLContext?

    override class var layerClass: AnyClass {
        return CAEAGLLayer.self
    }
    
    private func commit() {
        guard let glLayer = layer as? CAEAGLLayer else { return }
        glLayer.drawableProperties = [kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8,
                                      kEAGLDrawablePropertyRetainedBacking: true]
        glLayer.isOpaque = true
        glLayer.contentsScale = UIScreen.main.scale
    }
    
    private func settingContext() {
        context = EAGLContext(api: .openGLES2)
        EAGLContext.setCurrent(context)
    }
    
    private func createFrameBuffer() -> GLuint {
        var id = GLuint()
        glGenFramebuffers(1, &id)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), id)
        return id
    }
    
    
    
}
