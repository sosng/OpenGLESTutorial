//
//  ViewController.swift
//  ModelTransForm
//
//  Created by naver on 2018/11/5.
//  Copyright © 2018 naver. All rights reserved.
//

import UIKit
import GLKit

class ViewController: GLKViewController {

    private var context: EAGLContext?
    private var square: Square?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let glkView = view as? GLKView, let context = EAGLContext(api: .openGLES2) {
            self.context = context
            glkView.context = context
            EAGLContext.setCurrent(context)
        }
        let shader = Shader(vertextShader: "shaderv.vsh", fragShader: "shaderf.fsh")
        if let context = context {
            square = Square(shader: shader, context: context)
        }
        square?.position = GLKVector3(v: (0.5, -0.5, 0))
    }
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        let scale = UIScreen.main.scale
        glViewport(0,
                   0,
                   GLsizei(self.view.bounds.width * scale),
                   GLsizei(self.view.bounds.height * scale))
        glClearColor(0.5, 0.5, 0.5, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        square?.render()
    }
    

}

