//
//  Room.swift
//  DungeonBuilder
//
//  Created by Wolfgang Schreurs on 04/09/2018.
//  Copyright © 2018 Wolftrail. All rights reserved.
//

import Foundation

public class Room {
    let i: Int
    let j: Int

    public var coord: Coordinate { return Coordinate(i, j) }    
    
    public let width: Int
    public let height: Int
            
    public lazy var north: Int = { return self.i * 2 + 1 }()
    public lazy var south: Int = { return (self.i + self.height) * 2 + 1 }()
    public lazy var east: Int = { return (self.j + self.width) * 2 + 1 }()
    public lazy var west: Int = { return self.j * 2 + 1 }()
    public lazy var area: Int = { return self.width * self.height }()
    
    var doors: [Direction: [Door]] = [:]

    init(i: Int, j: Int, width: Int, height: Int) {
        self.i = i
        self.j = j
        self.width = width
        self.height = height
        
        for dir in Direction.cardinal {
            self.doors[dir] = []
        }
    }
}
