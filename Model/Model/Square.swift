//
//  Square.swift
//  Model
//
//  Created by naver on 2018/11/5.
//  Copyright © 2018 naver. All rights reserved.
//

import Foundation
import GLKit

class Square: Model {
    
    var vertexs = [Vertex( 0.5, -0.5, 0, 0.5, 0.0, 0.0, 0.5),
                   Vertex( 0.5,  0.5, 0, 0.0, 0.5, 0.0, 0.5),
                   Vertex(-0.5,  0.5, 0, 0.0, 0.0, 0.5, 0.5),
                   Vertex(-0.5, -0.5, 0, 0.5, 0.5, 0.0, 0.5)]
    let indexs: [GLubyte] = [0, 1, 2,
                             2, 3, 0]
    
    init(shader: Shader, context: EAGLContext) {
        super.init(name: "square", shader: shader, vertices: vertexs, indices: indexs, context: context)
    }
}
