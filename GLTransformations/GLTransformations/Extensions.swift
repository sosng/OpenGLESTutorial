//
//  Extensions.swift
//  GLTransformations
//
//  Created by naver on 2018/11/8.
//  Copyright © 2018 naver. All rights reserved.
//

import Foundation
import GLKit

extension Array {
    var size: Int {
        return MemoryLayout<Element>.stride * count
    }
}

extension GLKMatrix4 {
    var array: [Float] {
        return (0...16).map{ self[$0] }
    }
}
