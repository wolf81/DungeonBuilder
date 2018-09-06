//
//  Dungeon.swift
//  DungeonBuilder
//
//  Created by Wolfgang Schreurs on 04/09/2018.
//  Copyright © 2018 Wolftrail. All rights reserved.
//

import Foundation

open class Dungeon: CustomStringConvertible {
    let n_i: Int
    let n_j: Int
    
    lazy var n_rows: Int = { return self.n_i * 2 + 1 }()
    lazy var n_cols: Int = { return self.n_j * 2 + 1 }()
    lazy var max_row: Int = { return self.n_rows - 1 }()
    lazy var max_col: Int = { return self.n_cols - 1 }()
    
    var nodes: [[Node]] = [[]]
    var rooms: [UInt: Room] = [:]
    var connections: [String] = []
    
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
                count: self.n_cols),
            count: self.n_rows
        )
    }
    
    func node(at position: Position) -> Node {
        return self.nodes[position.i][position.j]
    }
        
    public var description: String {
        var output = ""
        
        for y in 0 ..< self.n_rows {
            for x in 0 ..< self.n_cols {
                let node = self.nodes[y][x]
                output += (node.contains(.blocked)
                    ? "  " : (node.label != nil
                        ? " \(node.label!)"
                        : (node.contains(.room)
                            ? " ·" : (node.contains(.corridor)
                                ? " +"
                                : (node.contains(.perimeter)
                                    ? " #"
                                    : "  "
                                )
                            )
                        )
                    )
                )
            }
            output += "\n"
        }
        
        return output
    }
}
