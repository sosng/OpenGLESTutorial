//
//  GLView.swift
//  Camera
//
//  Created by naver on 2018/11/20.
//  Copyright © 2018 naver. All rights reserved.
//

import UIKit
import GLKit

class GLView: UIView {
    
    private var context: EAGLContext?
    private var shader: Shader!
    private var frameBuffer = GLuint()
    private var renderBuffer = GLuint()
    
    override class var layerClass: AnyClass {
        return CAEAGLLayer.self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        self.contentScaleFactor = UIScreen.main.scale
        if let layer = layer as? CAEAGLLayer {
            layer.isOpaque = true
            layer.drawableProperties = [kEAGLDrawablePropertyRetainedBacking: false,kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8]
        }
        context = EAGLContext(api: .openGLES2)
        
    }
    
    private func setupBuffers() {
        
        glDisable(GLenum(GL_DEPTH_TEST))
        
        glEnable(<#T##cap: GLenum##GLenum#>)
        
    }
    
    func setupGL() {
        EAGLContext.setCurrent(context)
        shader = Shader(vertexShader: "shaderv.vsh", fragShader: "shaderf.fsh")
        shader.prepareDraw()
    }
    
    func display(_ pixelData: CVPixelBuffer) {
        
    }

}
