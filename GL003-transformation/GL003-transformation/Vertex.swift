//
//  Vertex.swift
//  GL003-transformation
//
//  Created by naver on 2018/10/29.
//  Copyright © 2018 naver. All rights reserved.
//

import Foundation
import GLKit

struct Vertex {
    var x: GLfloat
    var y: GLfloat
    var z: GLfloat
    var w: GLfloat
    var r: GLfloat
    var g: GLfloat
    var b: GLfloat
    var a: GLfloat
    
    init(_ x: GLfloat, _ y: GLfloat, _ z: GLfloat, _ w: GLfloat, _ r: GLfloat, _ g: GLfloat, _ b: GLfloat, _ a: GLfloat) {
        self.x = x
        self.y = y
        self.z = z
        self.w = w
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }
    
}
