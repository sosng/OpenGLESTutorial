//
//  Shader.swift
//  Model
//
//  Created by naver on 2018/11/5.
//  Copyright © 2018 naver. All rights reserved.
//

import Foundation
import GLKit

class Shader {
    
    var programHandle: GLuint = 0
    
    init(vertextShader: String, fragShader: String) {
        load(vertexShader: vertextShader, fragShader: fragShader)
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
        
    func uniformMatrix(_ location: GLint, value: inout GLKMatrix4) {
        let components = MemoryLayout.size(ofValue: value.m) / MemoryLayout.size(ofValue: value.m.0)
        withUnsafePointer(to: &value.m) {
            $0.withMemoryRebound(to: GLfloat.self, capacity: components, {
                        glUniformMatrix4fv(location, 1, GLboolean(GL_FALSE), $0)
            })
        }
    }
    
    private func load(vertexShader: String, fragShader: String) {
        // compile
        var vertexShaderHandler = compile(shaderPath: vertexShader, type: GLenum(GL_VERTEX_SHADER))
        var fragShaderHandler = compile(shaderPath: fragShader, type: GLenum(GL_FRAGMENT_SHADER))
        
        programHandle = glCreateProgram()
        glAttachShader(programHandle, vertexShaderHandler)
        glAttachShader(programHandle, fragShaderHandler)
        
        // link
        glLinkProgram(programHandle)
        
        var linkStatus = GLint()
        glGetProgramiv(programHandle, GLenum(GL_LINK_STATUS), &linkStatus)
        if linkStatus == GL_FALSE {
            var infoLength : GLsizei = 0
            let bufferLength : GLsizei = 1024
            glGetProgramiv(programHandle, GLenum(GL_INFO_LOG_LENGTH), &infoLength)
            
            let info: [GLchar] = Array(repeating: GLchar(0), count: Int(bufferLength))
            var actualLength : GLsizei = 0
            
            glGetProgramInfoLog(programHandle, bufferLength, &actualLength, UnsafeMutablePointer(mutating: info))
            print("=============\nshader link status info: \(String(describing: String(validatingUTF8: info)))\n=============")
            
            exit(0)
        }
        
        
    }
    
    private func compile(shaderPath: String, type: GLenum) -> GLuint {
        
        guard let path = Bundle.main.path(forResource: shaderPath, ofType: nil) else {
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
