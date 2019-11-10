//
//  WebSocketWrapper.swift
//  iMast
//
//  Created by rinsuki on 2017/12/29.
//  
//  ------------------------------------------------------------------------
//
//  Copyright 2017-2019 rinsuki and other contributors.
// 
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
// 
//      http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import Starscream
import Hydra
import iMastiOSCore

var webSockets: [WebSocketWrapper] = []

class WebSocketWrapper {
    let webSocket: WebSocket
    var reconnect: Bool = true
    var reconnectWait: Int8 = 0
    
    let event = WebSocketWrapperEvents()
    class WebSocketWrapperEvents {
        let connect = Event<Void>()
        let disconnect = Event<Error?>()
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
            self.event.connect.emit(Void())
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

extension MastodonUserToken {
    func getWebSocket(endpoint: String) -> Promise<WebSocketWrapper> {
        return self.app.instance.getInfo().then { info in
            var streamingUrlString = ""
            streamingUrlString += info["urls"]["streaming_api"].string ?? "wss://"+self.app.instance.hostName
            streamingUrlString += "/api/v1/streaming/?stream=" + endpoint
            let protocols: [String]?
            if MastodonVersionStringToInt(info["version"].stringValue) >= MastodonVersionStringToInt("2.8.4") {
                protocols = [self.token]
            } else {
                streamingUrlString += "&access_token=" + self.token
                protocols = nil
            }
            var urlRequest = URLRequest(url: URL(string: streamingUrlString)!)
            urlRequest.addValue(UserAgentString, forHTTPHeaderField: "User-Agent")
            let webSocket =  WebSocket(request: urlRequest, protocols: protocols)
            let wrap = WebSocketWrapper(webSocket: webSocket)
            _ = wrap.event.connect.on {
                print("WebSocket::Connect", endpoint)
            }
            _ = wrap.event.disconnect.on { error in
                print("WebSocket::Disconnect", endpoint, error?.localizedDescription ?? "no desc")
            }
            wrap.connect()
            webSockets.append(wrap)
            return Promise(resolved: wrap)
        }
    }
}

func allWebSocketDisconnect() {
    webSockets.forEach { value in
        value.disconnect()
    }
    webSockets = []
}
