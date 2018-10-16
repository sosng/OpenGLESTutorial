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
        let context =  EAGLContext(api: .openGLES2)
        return context
    }()

    
    lazy var mEffect: GLKBaseEffect = {
        let effect = GLKBaseEffect()
        effect.texture2d0.enabled = GLboolean(GL_TRUE)
        return effect
    }()
    
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
        // 顶点数据，三个点一个三角形
        // 顶点坐标(x, y, z) & 纹理坐标(x, y)
        var vertexData = [-0.5, -0.5, 0.0, 1.0, 0.0, // 右下
                          0.5, 0.5, -0.0, 1.0, 1.0, // 右上
                          -0.5, 0.5, 0.0, 0.0, 1.0, // 左上
            
                          0.5, 0.5, 0.0, 1.0, 0.0, // 右下
                          -0.5, 0.5, 0.0, 1.0, 0.0, // 左上
                          -0.5, -0.5, 0.0, 0.0, 0.0 // 左下
                        ]
        
        // 顶点数据缓存
        // 申请标识符
        var buffer: GLuint = 0
        glGenBuffers(1, &buffer)
        // 把标识符绑定在GL_ARRAY_BUFFER上
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), buffer)
        // 把顶点数据从CPU复制到GPU
        glBufferData(GLenum(GL_ARRAY_BUFFER), vertexData.count, &vertexData, GLenum(GL_STATIC_DRAW))
        // 开始对应顶点数据缓存
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.position.rawValue))
        // 设置合适的格式从buffer里面读取数据
        glVertexAttribPointer(GLuint(GLKVertexAttrib.position.rawValue),
                              GLint(3),
                              GLenum(GL_FLOAT),
                              GLboolean(GL_FALSE),
                              GLsizei(MemoryLayout<GLfloat>.stride * 5),
                              UnsafeRawPointer(bitPattern: MemoryLayout<GLfloat>.stride * 0))//BUFFER_OFFSET(0)
        
        // 纹理数据缓存
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.texCoord0.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.texCoord0.rawValue),
                              GLint(2),
                              GLenum(GL_FLOAT),
                              GLboolean(GL_FALSE),
                              GLsizei(MemoryLayout<GLfloat>.stride * 5),
                              UnsafeRawPointer(bitPattern: MemoryLayout<GLfloat>.stride * 3))
        
    }
    
    // 纹理贴图
    func uploadTexture() {
//        guard let filePath = Bundle.main.path(forResource: "logo", ofType: "png") else { return }
        let image = UIImage(named: "logo")
        guard let imageFile = image?.cgImage else { return }
        let option = [GLKTextureLoaderOriginBottomLeft: NSNumber(integerLiteral: 1)]
        do {
            // 着色器
            let texttureInfo = try GLKTextureLoader.texture(with: imageFile, options: option)
            mEffect.texture2d0.name = texttureInfo.name
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
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 6)
    }
    
    func BUFFER_OFFSET(_ n: Int) -> UnsafeRawPointer {
        let ptr: UnsafeRawPointer? = nil
        return ptr! + n * MemoryLayout<Void>.size
    }
    
}
