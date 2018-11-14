//
//  Square.swift
//  ModelTransForm
//
//  Created by naver on 2018/11/14.
//  Copyright © 2018 naver. All rights reserved.
//

import UIKit
import GLKit

class Square: Model {

    let vertexList: [Vertex] = [Vertex( 1.0, -1.0, 0, 1.0, 0.0, 0.0, 1.0),
                                Vertex( 1.0,  1.0, 0, 0.0, 1.0, 0.0, 1.0),
                                Vertex(-1.0,  1.0, 0, 0.0, 0.0, 1.0, 1.0),
                                Vertex(-1.0, -1.0, 0, 1.0, 1.0, 0.0, 1.0)]
    
    let indexList: [GLubyte] = [0, 1, 2,
                                2, 3, 0]
    
    init(shader: Shader, context: CVEAGLContext) {
        super.init(name: "square", shader: shader, vertices: vertexList, indices: indexList, context: context)
    }
    
    
}
