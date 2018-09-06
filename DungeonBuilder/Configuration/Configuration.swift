//
//  Configuration.swift
//  DungeonBuilder
//
//  Created by Wolfgang Schreurs on 04/09/2018.
//  Copyright © 2018 Wolftrail. All rights reserved.
//

import Foundation

open class Configuration {
    let dungeonLayout: DungeonLayout
    let dungeonSize: DungeonSize
    let roomLayout: RoomLayout
    let roomSize: RoomSize
    let corridorLayout: CorridorLayout
    let deadEndRemoval: DeadEndRemoval
    
    var closeArcs: Bool {
        let closeArcCorridors: [CorridorLayout] = [.straight, .errant]
        return closeArcCorridors.contains(self.corridorLayout)
    }
    
    init(dungeonSize: DungeonSize,
         dungeonLayout: DungeonLayout,
         roomSize: RoomSize,
         roomLayout: RoomLayout,
         corridorLayout: CorridorLayout,
         deadEndRemoval: DeadEndRemoval) {
        self.dungeonSize = dungeonSize
        self.dungeonLayout = dungeonLayout
        self.roomSize = roomSize
        self.roomLayout = roomLayout
        self.corridorLayout = corridorLayout
        self.deadEndRemoval = deadEndRemoval
    }
    
    static var Default: Configuration {
        return Configuration(
            dungeonSize: .small,
            dungeonLayout: .rectangle,
            roomSize: .medium,
            roomLayout: .scattered,
            corridorLayout: .errant,
            deadEndRemoval: .some
        )
    }
}
