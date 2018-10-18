//
//  ViewController.swift
//  GL001
//
//  Created by naver on 2018/10/11.
//  Copyright © 2018 naver. All rights reserved.
//

import UIKit
import GLKit

class ViewController: GLKViewController {
    
    @IBOutlet var glView: GLKView!
    // 上下文
    lazy var mContext: EAGLContext?  = {
        let context =  EAGLContext(api: .openGLES3)
        return context
    }()

    lazy var mEffect: GLKBaseEffect = {
        let effect = GLKBaseEffect()
        effect.texture2d0.enabled = GLboolean(GL_TRUE)
        return effect
    }()
    
    var vbo = GLuint()
    var vao = GLuint()
    var ebo = GLuint()
    
    // 顶点数据，三个点一个三角形
    // 顶点坐标(x, y, z) & 纹理坐标(x, y)
    
    var vertexData = [Vertex(0.5, -0.5, 0.0, 1.0, 0.0),
                      Vertex(0.5, 0.5, 0.0, 1.0, 1.0),
                      Vertex(-0.5, 0.5, 0.0, 0.0, 1.0),
                      Vertex(-0.5, -0.5, 0.0, 0.0, 0.0)]
    var indecies: [GLubyte] = [0, 1, 2,
                               2, 3, 0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        uploadVertexArray()
        uploadTexture()
    }
    
}

extension ViewController {
    
    func setup() {
        glView.drawableColorFormat = .RGBA8888
        glView.context = mContext!
        EAGLContext.setCurrent(mContext)
    }
    
    //  顶点数据缓存
    func uploadVertexArray() {
        
        // VAO
        glGenVertexArraysOES(1, &vao)
        glBindVertexArrayOES(vao)
        
        // VBO
        glGenBuffers(1, &vbo)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo)
        glBufferData(GLenum(GL_ARRAY_BUFFER), vertexData.size, vertexData, GLenum(GL_STATIC_DRAW))
        
        // vertexes
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.position.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.position.rawValue),
                              3,
                              GLenum(GL_FLOAT),
                              GLboolean(GL_FALSE),
                              GLsizei(MemoryLayout<Vertex>.stride),
                              nil)
        // texture
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.texCoord0.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.texCoord0.rawValue),
                              2,
                              GLenum(GL_FLOAT),
                              GLboolean(GL_FALSE),
                              GLsizei(MemoryLayout<Vertex>.stride),
                              UnsafeRawPointer(bitPattern: MemoryLayout<Vertex>.stride * 3))
        
        // ebo
        glGenBuffers(1, &ebo)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), ebo)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER),
                     indecies.size,
                     indecies,
                     GLenum(GL_STATIC_DRAW))
        // unbind vao
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glBindVertexArrayOES(0)
        
        
        /*
        // 顶点数据缓存
        // 申请标识符
        var buffer: GLuint = 0
        glGenBuffers(1, &buffer)
        // 把标识符绑定在GL_ARRAY_BUFFER上
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), buffer)
        // 把顶点数据从CPU复制到GPU
        glBufferData(GLenum(GL_ARRAY_BUFFER), vertexData.size, vertexData, GLenum(GL_STATIC_DRAW))
        // 开始对应顶点数据缓存
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.position.rawValue))
        // 设置合适的格式从buffer里面读取数据
        glVertexAttribPointer(GLuint(GLKVertexAttrib.position.rawValue),
                              GLint(3),
                              GLenum(GL_FLOAT),
                              GLboolean(GL_FALSE),
                              GLsizei(MemoryLayout<Vertex>.stride),
                              nil)//BUFFER_OFFSET(0)
        
        // 纹理数据缓存
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.texCoord0.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.texCoord0.rawValue),
                              GLint(2),
                              GLenum(GL_FLOAT),
                              GLboolean(GL_FALSE),
                              GLsizei(MemoryLayout<Vertex>.stride),
                              UnsafeRawPointer(bitPattern: MemoryLayout<GLfloat>.stride * 3))
        */
    }
    
    // 纹理贴图
    func uploadTexture() {
        guard let filePath = Bundle.main.path(forResource: "logo", ofType: "png") else { return }
        let image = UIImage(named: "logo")
        
        guard let imageFile = image?.cgImage else { return }
        let option = [GLKTextureLoaderOriginBottomLeft: NSNumber(integerLiteral: 1)]
        do {
            // 着色器
//            let textureInfo = try GLKTextureLoader.texture(withContentsOfFile: filePath, options: option)
            let textureInfo = try GLKTextureLoader.texture(with: imageFile, options: option)
            mEffect.texture2d0.name = textureInfo.name
        } catch {
            print("load image error: \(error)")
        }
    }
    
    // 渲染场景代码
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        glClearColor(GLclampf(0.0), GLclampf(0.6), GLclampf(1.0), GLclampf(1.0))
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
        // 启动着色器
        mEffect.prepareToDraw()
        //
        glBindVertexArrayOES(vao)
        glDrawElements(GLenum(GL_TRIANGLES),
                       GLsizei(indecies.count),
                       GLenum(GL_UNSIGNED_BYTE),
                       nil)
        glBindVertexArrayOES(0)
    }
}

struct Vertex {
    var x: GLfloat
    var y: GLfloat
    var z: GLfloat
    var tx: GLfloat
    var ty: GLfloat
    
    init(_ x: GLfloat, _ y: GLfloat, _ z: GLfloat, _ tx: GLfloat, _ ty: GLfloat) {
        self.x = x
        self.y = y
        self.z = z
        self.tx = tx
        self.ty = ty
    }
}

extension Array {
    var size: Int {
        return MemoryLayout<Element>.size * count
    }
}
