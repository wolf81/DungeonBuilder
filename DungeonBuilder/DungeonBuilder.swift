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
        openRooms(in: dungeon)
        addCorridors(to: dungeon)
        clean(dungeon: dungeon)
        
        return dungeon
    }
    
    private func clean(dungeon: Dungeon) {
        removeDeadEnds(in: dungeon)
        removePerimeters(in: dungeon)
//        fixDoors(in: dungeon)
    }
    
    private func removeDeadEnds(in dungeon: Dungeon) {
        collapseTunnels(in: dungeon, closeInfo: closeEndInfo)
    }
    
    private func collapseTunnels(in dungeon: Dungeon, closeInfo: [Direction: [CloseType: [Any]]]) {
        let deadEndRemoval = self.configuration.deadEndRemoval
        let percentage = deadEndRemoval.percentage
        
        guard percentage > 0 else { return }
        
        for i in (0 ..< dungeon.n_i) {
            let r = i * 2 + 1
            for j in (0 ..< dungeon.n_j) {
                let c = j * 2 + 1
                let node = dungeon.nodes[r][c]
                
                if node.isDisjoint(with: .openspace), node.contains(.stairs) {
                    continue
                }
                
                if (deadEndRemoval == .all) || (self.numberGenerator.nextInt(maxValue: 100) < percentage) {
                    let position = Position(i: r, j: c)
                    collapseTunnel(in: dungeon, position: position, closeInfo: closeInfo)
                }
            }
        }
    }
    
    private func collapseTunnel(in dungeon: Dungeon, position: Position, closeInfo: [Direction: [CloseType: [Any]]]) {
        if dungeon.node(at: position).isDisjoint(with: .openspace) {
            return
        }
        
        for g in closeInfo.keys {
            let dg = closeInfo[g]!
            
            if checkTunnel(in: dungeon, position: position, closeInfo: dg) {
//            if checkTunnel(cell: dungeon.cell, b: b, c: c, d: dg) {
                if let f = dg[.close] as? [[Int]] {
                    for h in f {
                        let bh = position.i + h[0]
                        let ch = position.j + h[1]
                        if !(0 ..< dungeon.n_rows).contains(bh) || !(0 ..< dungeon.n_cols).contains(ch) {
                            continue
                        }
                        
                        dungeon.nodes[bh][ch] = .nothing
                    }
                }
                
                if let f = dg[.open] as? [Int] {
                    let bf = position.i + f[0]
                    let cf = position.j + f[1]
                    if !(0 ..< dungeon.n_rows).contains(bf) || !(0 ..< dungeon.n_cols).contains(cf) {
                        continue
                    }
                    
                    dungeon.nodes[bf][cf].insert(.corridor)
                }
                
                if let g = dg[.recurse] as? [Int] {
                    let bg = position.i + g[0]
                    let cg = position.j + g[1]
                    if !(0 ..< dungeon.n_rows).contains(bg) || !(0 ..< dungeon.n_cols).contains(cg) {
                        continue
                    }
                    
                    collapseTunnel(in: dungeon, position: Position(i: bg, j: cg), closeInfo: closeInfo)
                }
            }
        }
    }
    
    private func checkTunnel(in dungeon: Dungeon, position: Position, closeInfo: [CloseType: [Any]]) -> Bool {
        if let d = closeInfo[.corridor] as? [[Int]] {
            for f in d {
                let bf = position.i + f[0]
                let cf = position.j + f[1]
                
                if bf < 0 || bf >= dungeon.nodes.count || cf < 0 || cf >= dungeon.nodes[0].count {
                    continue
                }
                
                let isCorridor = dungeon.nodes[bf][cf] == .corridor
                if !isCorridor {
                    return false
                }
            }
        }
        
        if let d = closeInfo[.walled] as? [[Int]] {
            for f in d {
                let bf = position.i + f[0]
                let cf = position.j + f[1]
                
                if bf < 0 || bf >= dungeon.nodes.count || cf < 0 || cf >= dungeon.nodes[0].count {
                    continue
                }
                
                if dungeon.nodes[bf][cf].intersection(.openspace) != .nothing {
                    return false
                }
            }
        }
        
        return true
    }
    
    private func removePerimeters(in dungeon: Dungeon) {
        for i in 0 ..< dungeon.n_rows {
            for j in 0 ..< dungeon.n_cols {
                if dungeon.nodes[i][j].contains(.perimeter) {
                    dungeon.nodes[i][j] = .nothing
                }
            }
        }
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
    
    private func addCorridors(to dungeon: Dungeon) {
        for i in (0 ..< dungeon.n_i) {
            let r = i * 2 + 1
            
            for j in (0 ..< dungeon.n_j) {
                let c = i * 2 + 1
                
                guard dungeon.nodes[r][c].isDisjoint(with: .corridor) else {
                    continue
                }
                
                makeTunnel(in: dungeon, position: Position(i: i, j: j))
            }
        }
    }
    
    private func openRooms(in dungeon: Dungeon) {
        for roomId in dungeon.rooms.keys.sorted() {
            openRoom(in: dungeon, roomId: roomId)
        }
    }
    
    private func openRoom(in dungeon: Dungeon, roomId: UInt) {
        var sills = doorSills(for: dungeon, roomId: roomId)
        
        guard let room = dungeon.rooms[roomId], sills.count > 0 else {
            return
        }
        
        let openCount = allocOpens(for: dungeon, room: room)
        
        for _ in (0 ..< openCount) {
            guard sills.count > 0 else {
                return
            }
            
            let sillIdx = self.numberGenerator.nextInt(maxValue: sills.count)
            let sill = sills.remove(at: sillIdx)
            let i = sill.door_r
            let j = sill.door_c
            guard dungeon.nodes[i][j].isDisjoint(with: .doorspace) else {
                continue
            }
            
            if let out_id = sill.out_id {
                let ids = [roomId, out_id].sorted()
                let cid = "\(ids[0]),\(ids[1])"
                if dungeon.connections.contains(cid) == false {
                    openDoor(for: dungeon, room: room, sill: sill)
                    dungeon.connections.append(cid)
                }
                // TODO
            } else {
                openDoor(for: dungeon, room: room, sill: sill)
            }
        }
    }
    
    private func openDoor(for dungeon: Dungeon, room: Room, sill: Sill) {
        for n in (0 ..< 3) {
            let i = sill.sill_r + di[sill.direction]! * n
            let j = sill.sill_c + dj[sill.direction]! * n
            dungeon.nodes[i][j].remove(.perimeter)
            dungeon.nodes[i][j].insert(.entrance)
        }
    }
    
    private func allocOpens(for dungeon: Dungeon, room: Room) -> Int {
        let n = Int(sqrt(Double(room.width + 1) * Double(room.height + 1)))
        return n + numberGenerator.nextInt(maxValue: n)
    }
    
    private func doorSills(for dungeon: Dungeon, roomId: UInt) -> [Sill] {
        var sills: [Sill] = []
        
        guard let room = dungeon.rooms[roomId] else {
            return []
        }
        
        if room.north >= 3 {
            for c in stride(from: room.west, to: room.east, by: 2) {
                let position = Position(i: room.north, j: c)
                if let sill = checkSill(for: dungeon, roomId: roomId, position: position, direction: .north) {
                    sills.append(sill)
                }
            }
        }
        
        if room.south <= (dungeon.n_rows - 3) {
            for c in stride(from: room.west, to: room.east, by: 2) {
                let position = Position(i: room.south, j: c)
                if let sill = checkSill(for: dungeon, roomId: roomId, position: position, direction: .south) {
                    sills.append(sill)
                }
            }
        }

        if room.west >= 3 {
            for r in stride(from: room.north, to: room.south, by: 2) {
                let position = Position(i: r, j: room.west)
                if let sill = checkSill(for: dungeon, roomId: roomId, position: position, direction: .west) {
                    sills.append(sill)
                }
            }
        }
        
        if room.east <= (dungeon.n_cols - 3) {
            for r in stride(from: room.north, to: room.south, by: 2) {
                let position = Position(i: r, j: room.east)
                if let sill = checkSill(for: dungeon, roomId: roomId, position: position, direction: .east) {
                    sills.append(sill)
                }
            }
        }

        return sills
    }
    
    private func checkSill(for dungeon: Dungeon, roomId: UInt, position: Position, direction: Direction) -> Sill? {
        let door_r = position.i + di[direction]!
        let door_c = position.j + dj[direction]!
        let door_cell = dungeon.nodes[door_r][door_c]
        
        guard door_cell.contains(.perimeter), door_cell.isDisjoint(with: .blockDoor) else {
            return nil
        }
        
        let out_r = door_r + di[direction]!
        let out_c = door_r + dj[direction]!
        let out_cell = dungeon.nodes[out_r][out_c]
        
        guard out_cell.isDisjoint(with: .blocked) else {
            return nil
        }
        
        var out_id: UInt?
        
        if out_cell.contains(.room) {
            out_id = out_cell.roomId
            
            if out_id == roomId {
                return nil
            }
        }
        
        return Sill(
            sill_r: position.i,
            sill_c: position.j,
            direction: direction,
            door_r: door_r,
            door_c: door_c,
            out_id: out_id
        )
    }
    
    private func makeTunnel(in dungeon: Dungeon, position: Position, with direction: Direction? = nil) {
        let randomDirections = tunnelDirections(with: direction)
        
        for randomDirection in randomDirections {
            if openTunnel(in: dungeon, position: position, direction: randomDirection) {
                let r = position.i + di[randomDirection]!
                let c = position.j + dj[randomDirection]!
                makeTunnel(in: dungeon, position: Position(i: r, j: c), with: randomDirection)
            }
        }
    }
    
    private func openTunnel(in dungeon: Dungeon, position: Position, direction: Direction) -> Bool {
        let r1 = position.i * 2 + 1
        let c1 = position.j * 2 + 1
        let r2 = (position.i + di[direction]!) * 2 + 1
        let c2 = (position.j + dj[direction]!) * 2 + 1
        let rMid = (r1 + r2) / 2
        let cMid = (c1 + c2) / 2
        
        let origin = Position(i: rMid, j: cMid)
        let destination = Position(i: r2, j: c2)
        if soundTunnel(in: dungeon, origin: origin, destination: destination) {
            delveTunnel(in: dungeon, origin: origin, destination: destination)
            return true
        }
        
        return false
    }
    
    private func delveTunnel(in dungeon: Dungeon, origin: Position, destination: Position) {
        var b = [origin.i, destination.i].sorted()
        var c = [origin.j, destination.j].sorted()
        
        for e in b[0] ... b[1] {
            for d in c[0] ... c[1] {
                dungeon.nodes[e][d].remove(.entrance)
                dungeon.nodes[e][d].insert(.corridor)
            }
        }
    }
    
    private func soundTunnel(in dungeon: Dungeon, origin: Position, destination: Position) -> Bool {
        guard (0 ..< dungeon.n_rows).contains(destination.i) else { return false }
        guard (0 ..< dungeon.n_cols).contains(destination.j) else { return false }
        
        var bn = [origin.i, destination.i].sorted()
        var cn = [origin.j, destination.j].sorted()
        
        for e in bn[0] ... bn[1] {
            for d in cn[0] ... cn[1] {
                let cell = dungeon.nodes[e][d]
                if !cell.isDisjoint(with: .blockCorr) {
                    return false
                }
            }
        }
        
        return true
    }
    
    private func tunnelDirections(with direction: Direction?) -> [Direction] {
        let directions: [Direction] = [.north, .west, .south, .east]
        var shuffledDirections = shuffle(items: directions)

        if let direction = direction {
            let randomPercent = self.numberGenerator.nextInt(maxValue: 100)
            if  randomPercent < self.configuration.corridorLayout.straightPercent {
                shuffledDirections.insert(direction, at: 0)
            }
        }
        return shuffledDirections
    }
    
    private func shuffle<T: Comparable>(items: [T]) -> [T] {
        var shuffledItems = items
        
        for i in (0 ..< shuffledItems.count).reversed() {
            let j = self.numberGenerator.nextInt(maxValue: i + 1)
            let k = shuffledItems[i]
            shuffledItems[i] = shuffledItems[j]
            shuffledItems[j] = k
        }
        
        return shuffledItems
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
        
        guard
            (r1 > 0 && r2 < dungeon.max_row) &&
            (c1 > 0 && c2 < dungeon.max_col) else {
            return
        }
        
        guard
            let hitInfo = soundRoom(for: dungeon, r1: r1, c1: c1, r2: r2, c2: c2),
            hitInfo.count == 0 else {
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
        
        // TODO: Add room data to rooms array of dungeon
        
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
