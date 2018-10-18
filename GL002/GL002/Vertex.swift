//
//  Vertex.swift
//  GL002
//
//  Created by naver on 2018/10/18.
//  Copyright © 2018 naver. All rights reserved.
//
import Foundation
import GLKit

struct Vertex {
    var x: GLfloat
    var y: GLfloat
    var z: GLfloat
    var s: GLfloat
    var t: GLfloat
    
    init(_ x: GLfloat, _ y: GLfloat, _ z: GLfloat, _ s: GLfloat, _ t: GLfloat) {
        self.x = x
        self.y = y
        self.z = z
        self.s = s
        self.t = t
    }
}



extension Array {
    var size: Int {
        return MemoryLayout<Element>.stride * count
    }
}


