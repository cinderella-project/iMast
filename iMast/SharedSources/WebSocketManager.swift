//
//  WebSocketManager.swift
//  iMast
//
//  Created by user on 2018/01/10.
//  Copyright © 2018年 rinsuki. All rights reserved.
//

import Foundation
import Starscream

var websockets:[WebSocket] = []
func allDisconnectWebSocket() {
    websockets.forEach { (socket) in
        print("disconnect "+socket.currentURL.absoluteString)
        socket.disconnect()
    }
    websockets = []
}
