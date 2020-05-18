//
//  DungeonInternal.swift
//  DungeonBuilder
//
//  Created by Wolfgang Schreurs on 04/09/2018.
//  Copyright © 2018 Wolftrail. All rights reserved.
//

import Foundation

/// This class is for internal use only, as use of the class directly can be confusing.
/// The internal coordinate system is smaller than the publicly visible coordinate system
internal class DungeonInternal  {
    let n_i: Int
    let n_j: Int
    
    lazy var height: Int = { return self.n_i * 2 + 1 }()
    lazy var width: Int = { return self.n_j * 2 + 1 }()
    
    lazy var maxRowIndex: Int = { return self.height - 1 }()
    lazy var maxColumnIndex: Int = { return self.width - 1 }()
    
    var nodes: [[Node]] = [[]]
    
    var rooms: [UInt: Room] = [:]
    var doors: [Door] = []
    var connections: [String] = []
    
    // MARK: - Constructors
    
    /// Create a dungeon based on a base width and height.
    /// Please note that the actual width and height is
    /// calculated by multiplying by 2 and adding 1.
    ///
    /// - Parameters:
    ///   - width: The base width
    ///   - height: The base height
    init(width: Int, height: Int) {
        self.n_i = width
        self.n_j = width
        
        self.nodes = Array(
            repeating: Array(
                repeating: .nothing,
                count: self.width),
            count: self.height
        )
    }
        
    subscript(x: Int, y: Int) -> Node {
        self.nodes[x][y]
    }
}
