//
//  Extensions.swift
//  Model
//
//  Created by naver on 2018/11/5.
//  Copyright © 2018 naver. All rights reserved.
//

import Foundation

extension Array {
    
    var size: Int {
        return MemoryLayout<Element>.stride * count
    }

}
