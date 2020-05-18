//
//  Coordinate.swift
//  DungeonBuilder
//
//  Created by Wolfgang Schreurs on 05/09/2018.
//  Copyright © 2018 Wolftrail. All rights reserved.
//

import Foundation

public struct Coordinate {
    var x: Int
    var y: Int
    
    static var zero: Coordinate {
        return Coordinate(0, 0)
    }
    
    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
}
