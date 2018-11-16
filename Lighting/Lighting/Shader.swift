//
//  Shader.swift
//  GL-EBO
//
//  Created by naver on 2018/10/30.
//  Copyright © 2018 naver. All rights reserved.
//

import Foundation
import GLKit

class Shader {
    
    private var programHandle = GLuint()
    
    init(vertexShader: String, fragShader: String) {
        programHandle = compile(vertextShader: vertexShader, fragShader: fragShader)
    }
    
    func prepareDraw() {
        glUseProgram(programHandle)
    }
    
    func attributeLocation(_ name: String) -> GLuint {
        return GLuint(glGetAttribLocation(programHandle, name))
    }
    
    func unifromLocation(_ name: String) -> GLuint {
        return GLuint(glGetUniformLocation(programHandle, name))
    }
    
    private func compile(vertextShader: String, fragShader: String) -> GLuint {
        // 1
        let vertexShaderName = compile(shader: vertextShader, type: GLenum(GL_VERTEX_SHADER))
        let fragmentShaderName = compile(shader: fragShader, type: GLenum(GL_FRAGMENT_SHADER))
        // 2
        let program = glCreateProgram()
        // 3
        glAttachShader(program, vertexShaderName)
        glAttachShader(program, fragmentShaderName)
        //
        glLinkProgram(program)
        //
        var linkStatus = GLint()
        glGetProgramiv(program, GLenum(GL_LINK_STATUS), &linkStatus)
        if linkStatus == GL_FALSE {
            var infoLength : GLsizei = 0
            let bufferLength : GLsizei = 1024
            glGetProgramiv(program, GLenum(GL_INFO_LOG_LENGTH), &infoLength)
            
            let info: [GLchar] = Array(repeating: GLchar(0), count: Int(bufferLength))
            var actualLength : GLsizei = 0
            
            glGetProgramInfoLog(program, bufferLength, &actualLength, UnsafeMutablePointer(mutating: info))
            print("=============\nshader link status info: \(String(describing: String(validatingUTF8: info)))\n=============")
            
            exit(0)
        }
        
        return program
    }
    
    private func compile(shader: String, type: GLenum) -> GLuint {
        guard let path = Bundle.main.path(forResource: shader, ofType: nil) else {
            exit(0)
        }
        do {
            // 1 - 读取shaders string
            let shaderString = try String(contentsOfFile: path, encoding: .utf8)
            // 2 - handler
            let shaderHandler = glCreateShader(type)
            // 3 -
            var shaderStringLength = GLint(Int32(shaderString.lengthOfBytes(using: .utf8)))
            let shaderCString = shaderString.cString(using: .utf8)
            var pointer = UnsafePointer<GLchar>(shaderCString)
            // 4 -
            glShaderSource(shaderHandler, GLsizei(1), &pointer, &shaderStringLength)
            // 5 -
            glCompileShader(shaderHandler)
            // 6 -
            var compileStatus = GLint(0)
            glGetShaderiv(shaderHandler, GLenum(GL_COMPILE_STATUS), &compileStatus)
            
            if compileStatus == GL_FALSE {
                var infoLength: GLsizei = 0
                var bufferLength: GLsizei = 1024
                
                glGetShaderiv(shaderHandler, GLenum(GL_INFO_LOG_LENGTH), &infoLength)
                let info = Array(repeating: GLchar(0), count: Int(bufferLength))
                
                var actualLength: GLsizei = 0
                glGetShaderInfoLog(shaderHandler, bufferLength, &actualLength, UnsafeMutablePointer(mutating: info))
                
                print("=============\nshader compile status info: \(String(describing: String(validatingUTF8: info)))\nshader string:\(shaderString)=============")
                exit(0)
                
            }
            
            return shaderHandler
        } catch {
            exit(0)
        }
        
    }
    
}

struct Vertext {
    var x: GLfloat
    var y: GLfloat
    var z: GLfloat
    var w: GLfloat
    var r: GLfloat
    var g: GLfloat
    var b: GLfloat
    var a: GLfloat
    // 法向量
    var nX: GLfloat
    var nY: GLfloat
    var nZ: GLfloat
    
    init(_ x: GLfloat, _ y: GLfloat, _ z: GLfloat, _ w: GLfloat, _ r: GLfloat, _ g: GLfloat, _ b: GLfloat, _ a: GLfloat, _ nX: GLfloat, _ nY: GLfloat, _ nZ: GLfloat) {
        self.x = x
        self.y = y
        self.z = z
        self.w = w
        self.r = r
        self.g = g
        self.b = b
        self.a = a
        self.nX = nX
        self.nY = nY
        self.nZ = nZ
    }
}

extension Array {
    var size: Int {
        return MemoryLayout<Element>.stride * count
    }
}

extension GLKMatrix4 {
    
    var array: [Float] {
        return (0...15).map{ self[$0] }
    }
}

extension GLKVector3 {
    var array: [Float] {
        return (0...2).map{ self[$0] }
    }
}

struct NormalVector {
    var x: GLfloat
    var y: GLfloat
    var z: GLfloat
    
    init(_ x: GLfloat, _ y: GLfloat, _ z: GLfloat) {
        self.x = x
        self.y = y
        self.z = z
    }
}
