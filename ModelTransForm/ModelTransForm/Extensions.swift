//
//  Extensions.swift
//  Model
//
//  Created by naver on 2018/11/5.
//  Copyright © 2018 naver. All rights reserved.
//

import Foundation
import GLKit

extension Array {
    
    var size: Int {
        return MemoryLayout<Element>.stride * count
    }

}

extension GLKMatrix2 {
    
    var array: [Float] {
        return (0...3).map{ self[$0] }
    }
}


extension GLKMatrix3 {
    
    var array: [Float] {
        return (0...8).map{ self[$0] }
    }
}

extension GLKMatrix4 {
    
    var array: [Float] {
        return (0...15).map{ self[$0] }
    }
}
