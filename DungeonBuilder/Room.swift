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
    
    init(i: Int, j: Int, width: Int, height: Int) {
        self.i = i
        self.j = j
        self.width = width
        self.height = height
    }
}
