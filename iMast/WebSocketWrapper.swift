//
//  WebSocketWrapper.swift
//  iMast
//
//  Created by user on 2017/12/29.
//  Copyright © 2017年 rinsuki. All rights reserved.
//

import Foundation
import Starscream
import Hydra

var webSockets: [WebSocketWrapper] = []

class WebSocketWrapper {
    let webSocket: WebSocket
    var reconnect: Bool = true
    var reconnectWait: Int8 = 0
    
    let event = WebSocketWrapperEvents()
    class WebSocketWrapperEvents {
        let connect = Event<Void>()
        let disconnect = Event<NSError?>()
        let message = Event<String>()
    }
    
    init(webSocket: WebSocket) {
        self.webSocket = webSocket
        self.event.connect.on {
            self.reconnectWait = 0
        }
        self.event.disconnect.onBackground {_ in
            if !self.reconnect {
                return
            }
            sleep(UInt32(self.reconnectWait))
            if self.reconnectWait < 10 {
                self.reconnectWait += 1
            }
            self.webSocket.connect()
        }
        self.webSocket.onConnect = {
            self.event.connect.emit()
        }
        self.webSocket.onDisconnect = { error in
            self.event.disconnect.emit(error)
        }
        self.webSocket.onText = { content in
            self.event.message.emit(content)
        }
    }
    
    func disconnect() {
        self.reconnect = false
        self.webSocket.disconnect()
    }
    
    func connect() {
        self.reconnect = true
        self.webSocket.connect()
    }
}

func getWebSocket(endpoint: String) -> Promise<WebSocketWrapper> {
    let userToken = MastodonUserToken.getLatestUsed()!
    return userToken.app.instance.getInfo().then { info in
        var streamingUrlString = ""
        streamingUrlString += info["urls"]["streaming_api"].string ?? "wss://"+userToken.app.instance.hostName
        streamingUrlString += "/api/v1/streaming/?access_token=" + userToken.token
        streamingUrlString += "&stream=" + endpoint
        let webSocket = WebSocket(url: URL(string: streamingUrlString)!)
        let wrap = WebSocketWrapper(webSocket: webSocket)
        _ = wrap.event.connect.on {
            print("WebSocket::Connect", endpoint)
        }
        _ = wrap.event.disconnect.on { error in
            print("WebSocket::Disconnect", endpoint, error?.localizedDescription ?? "no desc")
        }
        wrap.connect()
        return Promise(resolved: wrap)
    }
}

func allWebSocketDisconnect() {
    webSockets.forEach { value in
        value.disconnect()
    }
    webSockets = []
}
