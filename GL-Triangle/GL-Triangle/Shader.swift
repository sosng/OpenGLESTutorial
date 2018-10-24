//
//  Shader.swift
//  GL-Triangle
//
//  Created by naver on 2018/10/24.
//  Copyright © 2018 naver. All rights reserved.
//

import Foundation
import GLKit

class Shader {
    
    private var program = GLuint()
    
    init(vertexShader: String, fragShader: String) {
        program = compile(vertextShader: vertexShader, fragShader: fragShader)
    }
    
    func use() {
        glUseProgram(program)
    }
    
    private func compile(vertextShader: String, fragShader: String) -> GLuint {
        
        return 0
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
                
                print("=============\nshader compile status info: \(info)\n=============")
                exit(0)
                
            }
            
            return shaderHandler
        } catch {
            exit(0)
        }
        
    }
    
}
