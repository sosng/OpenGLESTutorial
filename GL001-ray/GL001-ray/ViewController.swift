//
//  ViewController.swift
//  GL001-ray
//
//  Created by naver on 2018/10/15.
//  Copyright © 2018 naver. All rights reserved.
//

import UIKit
import GLKit


struct Vertex {
    var x: GLfloat
    var y: GLfloat
    var z: GLfloat
    var r: GLfloat
    var g: GLfloat
    var b: GLfloat
    var a: GLfloat
}

class ViewController: GLKViewController {

    var context: EAGLContext?
    
    /*
    var Vertices = [Vertex(x:  1, y: -1, z: 0, r: 1, g: 0, b: 0, a: 1), // 右下
                    Vertex(x:  1, y:  1, z: 0, r: 0, g: 1, b: 0, a: 1), // 右上
                    Vertex(x: -1, y:  1, z: 0, r: 0, g: 0, b: 1, a: 1), // 左上
                    Vertex(x: -1, y: -1, z: 0, r: 0, g: 0, b: 0, a: 1)] //左下
    */
    var Vertices = [Vertex(x:  0.5, y: -0.5, z: 0, r: 1, g: 0, b: 0, a: 1),
                    Vertex(x:  0.5, y:  0.5, z: 0, r: 0, g: 1, b: 0, a: 1),
                    Vertex(x: -0.5, y:  0.5, z: 0, r: 0, g: 0, b: 1, a: 1),
                    Vertex(x: -0.5, y: -0.5, z: 0, r: 0, g: 0, b: 0, a: 1)]
    
    var Indices: [GLubyte] = [0, 1, 2,
                              2, 3, 0]
    
    private var ebo = GLuint()
    private var vbo = GLuint()
    private var vao = GLuint()
    
    private var effect = GLKBaseEffect()
    
    private var rotation: Float = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGL()
    }
    
    deinit {
        tearDownGL()
    }
    
    private func setupGL() {
        
        context = EAGLContext(api: .openGLES3)
        EAGLContext.setCurrent(context)
        if let context = context, let glView = self.view as? GLKView {
            glView.context = context
            delegate = self
        }
        
        let vertexAttribColor = GLuint(GLKVertexAttrib.color.rawValue)
        let vertexAttribPosition = GLuint(GLKVertexAttrib.position.rawValue)
        let vertexSize = MemoryLayout<Vertex>.stride
        let colorOffset = MemoryLayout<GLfloat>.stride * 3
        let colorOffsetPointer = UnsafeRawPointer(bitPattern: colorOffset)
        
        // Create VAO buffers
        // 1 generate VAO and store its identifier into `vao` variable
        glGenVertexArraysOES(1, &vao)
        // 2 bind the VAO that created and stored in the `vao` variable and that any upcoming calls to configure vertex attribute pointers should be stored in this VAO
        glBindVertexArrayOES(vao)
        
        // Create VBO buffers
        // generate VBO and store its identifier into `vbo` variable
        // 申请标识符
        glGenBuffers(1, &vbo)
        // bind buffer identifier into GL_ARRAY_BUFFER
        // 把标识符绑定到GL_ARRAY_BUFFER上
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo)
        // 把顶点数据从CPU复制到GPU
        // passing all vertex informations to OpenGL
        glBufferData(GLenum(GL_ARRAY_BUFFER), // what buffer is passing
                     Vertices.size, // specifies the data size, in byte, of the data
                     Vertices, // actual data going to use
                     GLenum(GL_STATIC_DRAW)) // Tells OpenGL how you want the GPU to manage the data
        
        // How to interupt data when draw it on the screen.
        // enable vertex attribute for position
        glEnableVertexAttribArray(vertexAttribPosition)
        glVertexAttribPointer(vertexAttribPosition, // specifies the attribute name to set
                              3, // how many values are present for each vertex, position is 3(x, y, z) and color is 4(r, g, b, a)
                              GLenum(GL_FLOAT), // specifes the types of each value
                              GLboolean(UInt8(GL_FALSE)), // specifies data to be normalized
                              GLsizei(vertexSize), // size of the stride(the size of the data structure containing the per-vertex data, when is's array)
                              nil)// offset of the data, for postion, it's nil, for color it's the offet after the postions.
        
        // enable vertex attribute for color
        glEnableVertexAttribArray(vertexAttribColor)
        glVertexAttribPointer(vertexAttribColor,
                              4,
                              GLenum(GL_FLOAT),
                              GLboolean(UInt8(GL_FALSE)),
                              GLsizei(vertexSize),
                              colorOffsetPointer)

        
        // Create EBO Buffers
        // generate buffer and store its identifier into `ebo`
        glGenBuffers(1, &ebo)
        // bind buffer into GL_ELEMENT_ARRAY_BUFFER
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), ebo)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER),
                     Indices.size,
                     Indices,
                     GLenum(GL_STATIC_DRAW))
        
        // Unbind VAO
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glBindVertexArrayOES(0)
    }
    
    private func tearDownGL() {
        EAGLContext.setCurrent(context)
        
        glDeleteBuffers(1, &vao)
        glDeleteBuffers(1, &vbo)
        glDeleteBuffers(1, &ebo)
        
        EAGLContext.setCurrent(nil)
        context = nil
    }
    
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        glClearColor(0.85, 0.85, 0.85, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        effect.prepareToDraw()
        // tell OpenGL what to draw and how to draw it.
        // bind VAO that OpenGL uses it
        glBindVertexArrayOES(vao)
        // perform drawing
        glDrawElements(GLenum(GL_TRIANGLES), // specifies what you want to draw,
                       GLsizei(Indices.count), // tell OpenGL how many vertex you want to draw
                       GLenum(GL_UNSIGNED_BYTE), // specifies the type of values contained in each index
                       nil) // specifies an offset within a buffer
        glBindVertexArrayOES(0)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isPaused = !isPaused
    }

}

extension ViewController: GLKViewControllerDelegate {
    
    func glkViewControllerUpdate(_ controller: GLKViewController) {
        /*
        // calculates the aspect ration of the GLKView
        let aspect = fabsf(Float(view.frame.width) / Float(view.frame.height))
        // use built-in function to create a perspective matrix, filed of view radians, aspect, near panel, far panel
        let projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0), aspect, 4.0, 10.0)
        // set the projection matrix on the effect's transform property
        effect.transform.projectionMatrix = projectionMatrix
        
        var modelViewMatrix = GLKMatrix4MakeTranslation(0.0, 0.0, -6.0)
        
        rotation += 90 * Float(timeSinceLastUpdate)
        
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(rotation), 0, 0, 1)
        effect.transform.modelviewMatrix = modelViewMatrix
        */
    }
}

extension Array {
    var size: Int {
        return MemoryLayout<Element>.stride * count
    }
}
