//
//  Model.swift
//  GLTransformations
//
//  Created by naver on 2018/11/8.
//  Copyright © 2018 naver. All rights reserved.
//

import Foundation
import GLKit

class Model {
    
    var shader: Shader!
    var vertices: [Vertex]!
    var indices: [GLubyte]
    
    var vao = GLuint()
    var vbo = GLuint()
    var ebo = GLuint()
    
    init(shader: Shader, vertices: [Vertex], indices: [GLubyte]) {
        self.shader = shader
        self.vertices = vertices
        self.indices = indices
        
        glGenVertexArrays(1, &vao)
        glBindVertexArrayOES(vao)
        
    }
    
}
