//
//  Model.swift
//  Model
//
//  Created by naver on 2018/11/5.
//  Copyright © 2018 naver. All rights reserved.
//

import Foundation
import GLKit

class Model {
    
    var shader: Shader!
    var name: String!
    var vertices: [Vertex]!
    var indices: [GLubyte]
    var indexCount: GLuint!
    
    var vao = GLuint(0)
    var vbo = GLuint(0)
    var ebo = GLuint(0)
    var context: EAGLContext!
    
    init(name: String, shader: Shader, vertices: [Vertex], indices: [GLubyte], context: EAGLContext) {
        
        self.name = name
        self.shader = shader
        self.vertices = vertices
        self.indexCount = GLuint(vertices.count)
        self.indices = indices
        self.indexCount = GLuint(indices.count)
        self.context = context
        
        glGenVertexArraysOES(1, &vao)
        glBindVertexArrayOES(vao)
        
        
        glGenBuffers(GLsizei(1), &vbo)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo)
        
        let count = vertices.count
        let size = MemoryLayout<Vertex>.size
        glBufferData(GLenum(GL_ARRAY_BUFFER),
                     count * size,
                     vertices,
                     GLenum(GL_STATIC_DRAW))
        
        glGenBuffers(GLsizei(1), &ebo)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), ebo)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER),
                     indices.count * MemoryLayout<GLubyte>.size,
                     indices,
                     GLenum(GL_STATIC_DRAW))
        
        let position = shader.attributeLocation("a_Position")
        glVertexAttribPointer(
            position,
            3,
            GLenum(GL_FLOAT),
            GLboolean(GL_FALSE),
            GLsizei(MemoryLayout<Vertex>.size),
            nil)
        glEnableVertexAttribArray(position)
        
        let color = shader.attributeLocation("a_Color")
        glVertexAttribPointer(color,
                              4,
                              GLenum(GL_FLOAT),
                              GLboolean(GL_FALSE),
                              GLsizei(MemoryLayout<Vertex>.size),
                              UnsafeRawPointer(bitPattern: 3 * MemoryLayout<GLfloat>.stride))
        glEnableVertexAttribArray(color)

        glBindVertexArrayOES(0)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), 0)
    }
    
    func render() {
        shader.prepareDraw()
        glBindVertexArrayOES(vao)
        glDrawElements(GLenum(GL_TRIANGLES),
                       GLsizei(indices.count),
                       GLenum(GL_UNSIGNED_BYTE),
                       nil)
        glBindVertexArrayOES(0)
    }
    
}
