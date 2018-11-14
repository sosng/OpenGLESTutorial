//
//  ViewController.swift
//  Model
//
//  Created by naver on 2018/11/5.
//  Copyright © 2018 naver. All rights reserved.
//

import UIKit
import GLKit

class ViewController: GLKViewController {

    private var shader: Shader!
    private var square: Square!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let glView = view as? GLKView else {
            return
        }
        let context = EAGLContext(api: .openGLES2)!
        glView.context = context
        EAGLContext.setCurrent(context)
        shader = Shader(vertextShader: "shaderv.vsh", fragShader: "shaderf.fsh")
        square = Square(shader: shader, context: context)
    }
//
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        glClearColor(0.5, 0.5, 0.5, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))

        square.render()

    }


}

