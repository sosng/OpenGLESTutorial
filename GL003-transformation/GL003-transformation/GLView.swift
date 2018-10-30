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

    var context: CVEAGLContext?
    
    override class var layerClass: AnyClass {
        return CAEAGLLayer.self
    }
    
    override func layoutSubviews() {
        setupLayer()
        setupContext()
    }
    
    
    private func setupLayer() {
        if let glLayer = self.layer as? CAEAGLLayer {
            glLayer.drawableProperties = [kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8, kEAGLDrawablePropertyRetainedBacking: false]
            glLayer.isOpaque = true
        }
    }
    
    private func setupContext() {
        context = CVEAGLContext(api: .openGLES2)
        EAGLContext.setCurrent(context)
    }
    

}
