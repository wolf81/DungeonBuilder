//
//  Node.swift
//  DungeonBuilder
//
//  Created by Wolfgang Schreurs on 04/09/2018.
//  Copyright © 2018 Wolftrail. All rights reserved.
//

import Foundation

public struct Node: OptionSet {
    public var rawValue: UInt
    
    static let nothing = Node(rawValue: 0)
    static let blocked = Node(rawValue: 1 << 0)
    static let room = Node(rawValue: 1 << 1)
    static let corridor = Node(rawValue: 1 << 2)
    static let perimeter = Node(rawValue: 1 << 3)
    static let entrance = Node(rawValue: 1 << 4)
    static let roomId = Node(rawValue: (1 << 16) - (1 << 6)) // TODO: verify same as 2^16 - 2^6
    static let arch = Node(rawValue: 1 << 16)
    static let door = Node(rawValue: 1 << 17)
    static let locked = Node(rawValue: 1 << 18)
    static let trapped = Node(rawValue: 1 << 19)
    static let secret = Node(rawValue: 1 << 20)
    static let portcullis = Node(rawValue: 1 << 21)
    static let stairDown = Node(rawValue: 1 << 22)
    static let stairUp = Node(rawValue: 1 << 23)
    static let label = Node(rawValue: (1 << 32) - (1 << 24)) // TODO: verify same as 2^32 - 2^24
    
    static let openspace: Node = [.room, .corridor]
    static let doorspace: Node = [.arch, .door, .locked, .trapped, .secret, .portcullis]
    static let espace: Node = [.entrance, .doorspace, .label]
    static let stairs: Node = [.stairUp, .stairDown]
    static let blockRoom: Node = [.blocked, .room]
    static let blockCorr: Node = [.blocked, .perimeter, .corridor]
    static let blockDoor: Node = [.blocked, .doorspace]
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    public var roomId: UInt {
        get {
            return (self.rawValue & Node.roomId.rawValue) >> 6
        }
    }
    
    public var label: String? {
        get {
            let value = UInt8(self.rawValue >> 24 & 255)
            let scalar = UnicodeScalar(value)
            return value != 0 ? String(scalar) : nil
        }
    }
    
    /// Mark the node as containing a room and set the room id.
    ///
    /// - Parameter roomId: The id of the room.
    mutating func setRoom(roomId: UInt) {
        self.insert(.room)
        
        var value = self.rawValue
        
        // TODO: can probably be improved, not sure how?
        // clear the old room id be clearing bits in range 6 ..< 16
        value = value & 0b1111_1111_1111_1111_0000_0000_0011_1111
        
        // set the new room id
        value |= (Node.roomId.rawValue & (roomId << 6))
        
        // update the node
        self = Node(rawValue: value)
    }
    
    mutating func setLabel(character: Character) {
        var value = self.rawValue
        
        // TODO: clear label?
        
        if let char = character.unicodeScalars.first, char.isASCII {
            print("v: \(char.value)")
            value |= UInt(char.value) << 24
        }
        
        self = Node(rawValue: value)
    }
}

extension Node: Equatable {
    public static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

extension Node: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self)
    }
}
