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
import Hydra
import iMastiOSCore

var webSockets: [WebSocketWrapper] = []

class WebSocketWrapper: NSObject {
    private let request: URLRequest
    private lazy var urlSession = URLSession(configuration: .ephemeral, delegate: self, delegateQueue: nil)
    private var task: URLSessionWebSocketTask!
    var reconnect: Bool = true
    var reconnectWait: Int8 = 0
    var isConnected = false
    var timer: Timer?
    weak var delegate: WebSocketWrapperDelegate?
    
    init(request: URLRequest) {
        self.request = request
        super.init()
    }
    
    func receiveLoop() {
        task.receive { result in
            switch result {
            case .success(let data):
                switch data {
                case .string(let str):
                    DispatchQueue.main.async {
                        self.delegate?.webSocket?(self, received: str)
                    }
                default:
                    print("unknown \(data)")
                }
                self.receiveLoop()
            case .failure(let error):
                self.disconnect(error: error)
            }
        }
    }
    
    func connect() {
        reconnect = true
        task = urlSession.webSocketTask(with: request)
        receiveLoop()
        task.resume()
    }

    func disconnect(error: Error? = nil) {
        print("WebSocket::Disconenct", error)
        guard self.isConnected == true else {
            print("いやisConnected==falseじゃねえか")
            return
        }
        self.isConnected = false
        print("")
        task.cancel(with: .goingAway, reason: nil)
        timer?.invalidate()
        if reconnect {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Int(reconnectWait))) {
                if self.reconnectWait < 10 {
                    self.reconnectWait += 1
                }
                self.connect()
            }
        }
        DispatchQueue.main.async {
            self.delegate?.webSocket?(self, disconnected: error)
        }
    }
    
    @objc func sendPing() {
        print(task.closeCode.rawValue, task.closeReason, task.state.rawValue, task.error)
    }
}

extension WebSocketWrapper: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("WebSocket::Connected")
        self.reconnectWait = 0
        self.isConnected = true
        self.timer = .scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.sendPing), userInfo: nil, repeats: true)
        self.timer?.fire()
        DispatchQueue.main.async {
            self.delegate?.webSocket?(self, connected: `protocol`)
        }
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("urlSession(_:webSocketTask:didCloseWith:reason:)")
        disconnect()
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("urlSession(_:task:didCompleteWithError:)", error)
        print(error)
    }
}

@objc protocol WebSocketWrapperDelegate {
    @objc optional func webSocket(_ wrapper: WebSocketWrapper, connected protocol: String?)
    @objc optional func webSocket(_ wrapper: WebSocketWrapper, disconnected error: Error?)
    @objc optional func webSocket(_ wrapper: WebSocketWrapper, received text: String)
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
            if let protocols = protocols {
                urlRequest.addValue(protocols.joined(separator: ","), forHTTPHeaderField: "Sec-WebSocket-Protocol")
            }
            let wrap = WebSocketWrapper(request: urlRequest)
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
