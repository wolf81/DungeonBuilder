//
//  Room.swift
//  DungeonBuilder
//
//  Created by Wolfgang Schreurs on 04/09/2018.
//  Copyright © 2018 Wolftrail. All rights reserved.
//

import Foundation

class Room {
    let width: Int
    let height: Int
    let i: Int
    let j: Int
    
    lazy var north: Int = { return self.i * 2 + 1 }()
    lazy var south: Int = { return (self.i + self.height) * 2 + 1 }()
    lazy var east: Int = { return (self.j + self.width) * 2 + 1 }()
    lazy var west: Int = { return self.j * 2 + 1 }()
//    var area: Int { return self.width * self.height }
    
    init(i: Int, j: Int, width: Int, height: Int) {
        self.i = i
        self.j = j
        self.width = width
        self.height = height
    }
}
