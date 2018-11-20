//
//  Shader.swift
//  Camera
//
//  Created by naver on 2018/11/20.
//  Copyright © 2018 naver. All rights reserved.
//

import UIKit
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
