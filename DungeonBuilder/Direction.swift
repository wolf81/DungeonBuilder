//
//  Direction.swift
//  DungeonBuilder
//
//  Created by Wolfgang Schreurs on 05/09/2018.
//  Copyright © 2018 Wolftrail. All rights reserved.
//

import Foundation

enum Direction: Int {
    case north
    case northWest
    case northEast
    case south
    case southWest
    case southEast
    case west
    case westNorth
    case westSouth
    case east
    case eastNorth
    case eastSouth
    
    var opposite: Direction {
        switch self {
        case .north: return .south
        case .northWest: return .southEast
        case .northEast: return .southWest
        case .south: return .north
        case .southWest: return .northEast
        case .southEast: return .northWest
        case .west: return .east
        case .westNorth: return .eastSouth
        case .westSouth: return .eastNorth
        case .east: return .west
        case .eastNorth: return .westSouth
        case .eastSouth: return .westNorth
        }
    }
}

var di: [Direction: Int] = [
    .north: -1,
    .south: 1,
    .west: 0,
    .east: 0,
]

var dj: [Direction: Int] = [
    .north: 0,
    .south: 0,
    .west: -1,
    .east: 1,
]

var dirs: [Direction] {
    return [.north, .west, .south, .east]
}
