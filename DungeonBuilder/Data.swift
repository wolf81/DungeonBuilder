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

var closeArcInfo: [Direction: [CloseType: [Any]]] = [
    .northWest: [
        .corridor: [
            [0, 0],
            [-1, 0],
            [-2, 0],
            [-2, -1],
            [-2, -2],
            [-1, -2],
            [0, -2],
        ],
        .walled: [
            [-1, 1],
            [-2, 1],
            [-3, 1],
            [-3, 0],
            [-3, -1],
            [-3, -2],
            [-3, -3],
            [-2, -3],
            [-1, -3],
            [0, -1],
            [-1, -1],
        ],
        .close: [
            [-1, 0],
            [-2, 0],
            [-2, -1],
            [-2, -2],
            [-1, -2],
        ],
        .open: [0, -1],
        .recurse: [2, 0]
    ],
    .northEast: [
        .corridor: [
            [0, 0],
            [-1, 0],
            [-2, 0],
            [-2, 1],
            [-2, 2],
            [-1, 2],
            [0, 2],
        ],
        .walled: [
            [-1, -1],
            [-2, -1],
            [-3, -1],
            [-3, 0],
            [-3, 1],
            [-3, 2],
            [-3, 3],
            [-2, 3],
            [-1, 3],
            [0, 1],
            [-1, 1],
        ],
        .close: [
            [-1, 0],
            [-2, 0],
            [-2, 1],
            [-2, 2],
            [-1, 2],
        ],
        .open: [0, 1],
        .recurse: [2, 0]
    ],
    .southWest: [
        .corridor: [
            [0, 0],
            [1, 0],
            [2, 0],
            [2, -1],
            [2, -2],
            [1, -2],
            [0, -2],
        ],
        .walled: [
            [1, 1],
            [2, 1],
            [3, 1],
            [3, 0],
            [3, -1],
            [3, -2],
            [3, -3],
            [2, -3],
            [1, -3],
            [0, -1],
            [1, -1],
        ],
        .close: [
            [1, 0],
            [2, 0],
            [2, -1],
            [2, -2],
            [1, -2],
        ],
        .open: [0, -1],
        .recurse: [-2, 0]
    ],
    .southEast: [
        .corridor: [
            [0, 0],
            [1, 0],
            [2, 0],
            [2, 1],
            [2, 2],
            [1, 2],
            [0, 2],
        ],
        .walled: [
            [1, -1],
            [2, -1],
            [3, -1],
            [3, 0],
            [3, 1],
            [3, 2],
            [3, 3],
            [2, 3],
            [1, 3],
            [0, 1],
            [1, 1],
        ],
        .close: [
            [1, 0],
            [2, 0],
            [2, 1],
            [2, 2],
            [1, 2],
        ],
        .open: [0, 1],
        .recurse: [-2, 0]
    ],
    .westNorth: [
        .corridor: [
            [0, 0],
            [0, -1],
            [0, -2],
            [-1, -2],
            [-2, -2],
            [-2, -1],
            [-2, 0],
        ],
        .walled: [
            [1, -1],
            [1, -2],
            [1, -3],
            [0, -3],
            [-1, -3],
            [-2, -3],
            [-3, -3],
            [-3, -2],
            [-3, -1],
            [-1, 0],
            [-1, -1],
        ],
        .close: [
            [0, -1],
            [0, -2],
            [-1, -2],
            [-2, -2],
            [-2, -1],
        ],
        .open: [-1, 0],
        .recurse: [0, 2]
    ],
    .westSouth: [
        .corridor: [
            [0, 0],
            [0, -1],
            [0, -2],
            [1, -2],
            [2, -2],
            [2, -1],
            [2, 0],
        ],
        .walled: [
            [-1, -1],
            [-1, -2],
            [-1, -3],
            [0, -3],
            [1, -3],
            [2, -3],
            [3, -3],
            [3, -2],
            [3, -1],
            [1, 0],
            [1, -1],
        ],
        .close: [
            [0, -1],
            [0, -2],
            [1, -2],
            [2, -2],
            [2, -1],
        ],
        .open: [1, 0],
        .recurse: [0, 2]
    ],
    .eastNorth: [
        .corridor: [
            [0, 0],
            [0, 1],
            [0, 2],
            [-1, 2],
            [-2, 2],
            [-2, 1],
            [-2, 0],
        ],
        .walled: [
            [1, 1],
            [1, 2],
            [1, 3],
            [0, 3],
            [-1, 3],
            [-2, 3],
            [-3, 3],
            [-3, 2],
            [-3, 1],
            [-1, 0],
            [-1, 1],
        ],
        .close: [
            [0, 1],
            [0, 2],
            [-1, 2],
            [-2, 2],
            [-2, 1],
        ],
        .open: [-1, 0],
        .recurse: [0, -2]
    ],
    .eastSouth: [
        .corridor: [
            [0, 0],
            [0, 1],
            [0, 2],
            [1, 2],
            [2, 2],
            [2, 1],
            [2, 0],
        ],
        .walled: [
            [-1, 1],
            [-1, 2],
            [-1, 3],
            [0, 3],
            [1, 3],
            [2, 3],
            [3, 3],
            [3, 2],
            [3, 1],
            [1, 0],
            [1, 1],
        ],
        .close: [
            [0, 1],
            [0, 2],
            [1, 2],
            [2, 2],
            [2, 1],
        ],
        .open: [1, 0],
        .recurse: [0, -2]
    ]
]
