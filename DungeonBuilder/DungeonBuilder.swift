//
//  DungeonBuilder.swift
//  DungeonBuilder
//
//  Created by Wolfgang Schreurs on 04/09/2018.
//  Copyright © 2018 Wolftrail. All rights reserved.
//

import Foundation

class DungeonBuilder {
    let configuration: Configuration
    let numberGenerator: NumberGeneratable
    
    init(configuration: Configuration, numberGenerator: NumberGeneratable? = nil) {
        self.configuration = configuration
        self.numberGenerator = numberGenerator ?? RandomNumberGenerator()
    }
    
    func build(name: String) -> Dungeon {
        let data = name.data(using: .utf8)!
        self.numberGenerator.seed(data: data)
        
        let size = self.configuration.dungeonSize.rawValue
        let aspectRatio = self.configuration.dungeonLayout.aspectRatio
        
        let height = Int(Float(size) * aspectRatio)
        let width = size

        let dungeon = Dungeon(width: width, height: height)
        applyMask(to: dungeon)
        addRooms(to: dungeon)
        
        return dungeon
    }
    
    private func applyMask(to dungeon: Dungeon) {
        guard let mask = self.configuration.dungeonLayout.mask else {
            return
        }
        
        let c = Float(mask.count) / Float(dungeon.n_rows)
        let d = Float(mask[0].count) / Float(dungeon.n_cols)
        
        for e in 0 ..< dungeon.n_rows {
            let y = Int(Float(e) * c)
            var g = mask[y]
            for f in 0 ..< dungeon.n_cols {
                let x = Int(Float(f) * d)
                if g[x] == 0 {
                    dungeon.nodes[e][f].insert(.blocked)
                }
            }
        }
    }
    
    private func addRooms(to dungeon: Dungeon) {
        switch self.configuration.roomLayout {
        case .dense: addDenseRooms(to: dungeon)
        default: addScatteredRooms(to: dungeon)
        }
    }
    
    private func addDenseRooms(to dungeon: Dungeon) {
        for i in 0 ..< dungeon.n_i {
            let r = i * 2 + 1
            for j in 0 ..< dungeon.n_j {
                let c = j * 2 + 1
                
                guard dungeon.nodes[r][c].isDisjoint(with: .room) else {
                    continue
                }
                
                guard (i != 0 && j != 0) && numberGenerator.nextInt(maxValue: 2) != 0 else {
                    continue
                }

                emplaceRoom(
                    in: dungeon,
                    roomSize: self.configuration.roomSize,
                    position: Position(i: i, j: j)
                )
            }
        }
    }
    
    private func addScatteredRooms(to dungeon: Dungeon) {
        var roomCount = allocateRooms(for: dungeon, roomSize: self.configuration.roomSize)
        
        for _ in (0 ..< roomCount) {
            emplaceRoom(in: dungeon, roomSize: self.configuration.roomSize)
        }
        
        if self.configuration.roomSize.isHuge {
            roomCount = allocateRooms(for: dungeon, roomSize: .medium)
            for _ in (0 ..< roomCount) {
                emplaceRoom(in: dungeon, roomSize: .medium)
            }
        }
    }
    
    private func emplaceRoom(in dungeon: Dungeon, roomSize: RoomSize, position: Position = .zero) {
        if dungeon.rooms.count > 999 {
            return
        }
        
        let room = makeRoom(for: dungeon, roomSize: roomSize, position: position)

        let r1 = room.i * 2 + 1
        let c1 = room.j * 2 + 1
        let r2 = (room.i + room.height) * 2 + 1
        let c2 = (room.j + room.width) * 2 + 1
        
        guard (r1 > 0 && r2 < dungeon.max_row) &&
            (c1 > 0 && c2 < dungeon.max_col) else {
            return
        }
        
        guard let hitInfo = soundRoom(for: dungeon, r1: r1, c1: c1, r2: r2, c2: c2) else {
            return
        }
        
        print("hitInfo: \(hitInfo)")
        
        let hitCount = hitInfo.count
        
        guard hitCount == 0 else {
            print(hitInfo.forEach({ print("\($0): \($1)")}))
            return
        }
        
        let roomId = UInt(dungeon.rooms.count + 1)
        
        for r in (r1 ... r2) {
            for c in (c1 ... c2) {
                var node = dungeon.nodes[r][c]
                
                if node.contains(.entrance) {
                   node.remove(.espace)
                } else if node.contains(.perimeter) {
                    node.remove(.perimeter)
                }
                
                node.setRoom(roomId: roomId)
                dungeon.nodes[r][c] = node
            }
        }
        
        // TODO: Add room to rooms array of dungeon
        
        for r in (r1 - 1 ... r2 + 1) {
            var node = dungeon.nodes[r][c1 - 1]
            if node.contains([.room, .entrance]) == false {
                node.insert(.perimeter)
            }
            dungeon.nodes[r][c1 - 1] = node
            
            node = dungeon.nodes[r][c2 + 1]
            if node.contains([.room, .entrance]) == false {
                node.insert(.perimeter)
            }
            dungeon.nodes[r][c2 + 1] = node
        }

        for c in (c1 - 1 ... c2 + 1) {
            var node = dungeon.nodes[r1 - 1][c]
            if node.contains([.room, .entrance]) == false {
                node.insert(.perimeter)
            }
            dungeon.nodes[r1 - 1][c] = node
            
            node = dungeon.nodes[r2 + 1][c]
            if node.contains([.room, .entrance]) == false {
                node.insert(.perimeter)
            }
            dungeon.nodes[r2 + 1][c] = node
        }
        
        dungeon.rooms[roomId] = room
        print("add room \(roomId) @ \(r1).\(c1) -> \(r2).\(c2) ")
    }
    
    private func makeRoom(for dungeon: Dungeon, roomSize: RoomSize, position: Position) -> Room {
        let radixBase = roomSize.radix
        let size = roomSize.size
        
        var height: Int = 0
        var width: Int = 0

        var i = position.i
        var j = position.j
        
        if i != 0 {
            let radix = min(max(dungeon.n_i - size - position.i, 0), radixBase)
            height = self.numberGenerator.nextInt(maxValue: radix) + size
        } else {
            height = self.numberGenerator.nextInt(maxValue: radixBase) + size
        }
        
        if j != 0 {
            let radix = min(max(dungeon.n_j - size - position.j, 0), radixBase)
            width = self.numberGenerator.nextInt(maxValue: radix) + size
        } else {
            width = self.numberGenerator.nextInt(maxValue: radixBase) + size
        }
        
        if i == 0 {
            i = self.numberGenerator.nextInt(maxValue: dungeon.n_i - height)
        }
        
        if j == 0 {
            j = self.numberGenerator.nextInt(maxValue: dungeon.n_j - width)
        }

        return Room(i: i, j: j, width: width, height: height)
    }
    
    private func soundRoom(for dungeon: Dungeon, r1: Int, c1: Int, r2: Int, c2: Int) -> [UInt: UInt]? {
        var hitInfo: [UInt: UInt] = [:]
        
        for r in (r1 ... r2) {
            for c in (c1 ... c2) {
                let node = dungeon.nodes[r][c]
                
                if node.contains(.blocked) {
                    return nil
                }
                
                if node.contains(.room) {
                    print("\(r).\(c) hit room: \(node.roomId)")
                    let hitCount = hitInfo[node.roomId] ?? 0
                    hitInfo[node.roomId] = hitCount + 1
                }
            }
        }
        
        return hitInfo
    }
    
    private func allocateRooms(for dungeon: Dungeon, roomSize: RoomSize) -> Int {
        let size = roomSize.size
        let radix = roomSize.radix
        let dungeonArea = dungeon.n_cols * dungeon.n_rows
        let roomArea = (size + radix + 1) ^ 2
        var roomCount = Int(dungeonArea / roomArea) * 2
        if self.configuration.roomLayout == .sparse {
            roomCount /= 13
        }
        return roomCount
    }
}
