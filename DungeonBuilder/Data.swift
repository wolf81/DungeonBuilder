//
//  Data.swift
//  DungeonBuilder
//
//  Created by Wolfgang Schreurs on 06/09/2018.
//  Copyright © 2018 Wolftrail. All rights reserved.
//

import Foundation

var closeEndInfo: [Direction: [CloseType: [Any]]] = [
    .north: [
        .walled: [
            [0, -1],
            [1, -1],
            [1, 0],
            [1, 1],
            [0, 1],
        ],
        .close: [
            [0, 0]
        ],
        .recurse: [-1, 0],
    ],
    .south: [
        .walled: [
            [0, -1],
            [-1, -1],
            [-1, 0],
            [-1, 1],
            [0, 1],
        ],
        .close: [
            [0, 0]
        ],
        .recurse: [1, 0],
    ],
    .west: [
        .walled: [
            [-1, 0],
            [-1, 1],
            [0, 1],
            [1, 1],
            [1, 0],
        ],
        .close: [
            [0, 0]
        ],
        .recurse: [0, -1],
    ],
    .east: [
        .walled: [
            [-1, 0],
            [-1, -1],
            [0, -1],
            [1, -1],
            [1, 0],
        ],
        .close: [
            [0, 0]
        ],
        .recurse: [0, 1],
    ],
]
