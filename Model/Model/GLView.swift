//
//  GLView.swift
//  Model
//
//  Created by naver on 2018/11/6.
//  Copyright © 2018 naver. All rights reserved.
//

import UIKit
import GLKit

class GLView: UIView {

    override class var layerClass: AnyClass {
        return CAEAGLLayer.self
    }
    
    private var context: EAGLContext!
    var shader: Shader!
    var square: Square!
    
    override func layoutSubviews() {
        setupLayerAndContext()
        
        let shader = Shader(vertextShader: "shaderv.vsh", fragShader: "shaderf.fsh")
        square = Square(shader: shader, context: context)
        render()
    }
    
    private func setupLayerAndContext() {
        contentScaleFactor = UIScreen.main.scale
        if let glLayer = self.layer as? CAEAGLLayer {
            glLayer.isOpaque = true
            glLayer.drawableProperties = [kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8,
                                          kEAGLDrawablePropertyRetainedBacking: true]
            glLayer.contentsScale = UIScreen.main.scale
        }
        context = EAGLContext(api: .openGLES2)
        EAGLContext.setCurrent(context)
    }
    
    private func render() {
        glClearColor(0.5, 0.5, 0.5, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        let scale = UIScreen.main.scale
        glViewport(GLint(scale * frame.origin.x),
                   GLint(scale * frame.origin.y),
                   GLint(scale * frame.width),
                   GLint(scale * frame.height))
        square.render()
    }

}
