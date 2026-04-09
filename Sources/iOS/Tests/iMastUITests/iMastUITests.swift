//
//  iMastUITests.swift
//  iMastUITests
//
//  Created by rinsuki on 2017/04/22.
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
import XCTest

class iMastUITests: XCTestCase {
    let app = XCUIApplication()
    let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
    
    override func setUp() async throws {
        try await super.setUp()
        var req = URLRequest(url: URL(string: "http://localhost:3000/api/internal/set_status_bar")!)
        req.httpMethod = "POST"
        let res = try? await URLSession.shared.data(for: req)
        print(res)
    }
        
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app.launchEnvironment["IMAST_ALLOW_HTTP_SUFFIX_HOST"] = "yes"
        app.launchEnvironment["IMAST_USE_IN_MEMORY_SQLITE"] = "yes"
        app.launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // ログインパート
        if true {
            let instance = app.textFields["mastodon.example"]
            instance.tap()
            instance.typeText("localhost.http.devonly.invalid:3000")
            shot()
            let loginButton = app.buttons["loginButton"]
            loginButton.tap()
            shot()
            // ASWebのアラートを真面目に突破するのはできなさそうだったので
            let loginWithSafari = app.buttons["loginWithSafari_Ephemeral"]
            loginWithSafari.waitForExistence(timeout: 60) // Safari はときどき信じられないくらい遅い
            loginWithSafari.tap()
            let openTimeline = app.buttons["toTimeline"]
            openTimeline.waitForExistence(timeout: 10)
            shot()
            openTimeline.tap()
        }
        // ログイン後パート
        if true {
            let tabBar = app.tabBars.element // TODO: use identifier?
            tabBar.buttons.firstMatch.tap()
            app.navigationBars.buttons.containing(.image, identifier: "bolt.fill").firstMatch.waitForExistence(timeout: 10)
            shot(name: "AppStore_Home")
            tabBar.buttons.containing(.image, identifier: "ellipsis").element.tap()
            let othersMenu = app.tables["otherMenuTableView"]
            othersMenu.waitForExistence(timeout: 10)
            shot()
            othersMenu.cells["openMyProfile"].tap()
            app.staticTexts["relationshipLabel_loaded"].waitForExistence(timeout: 10)
            shot(name: "AppStore_Others")
        }
    }
    
    func shot(name: String? = nil) {
        let screenshot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        screenshot.name = name
        screenshot.lifetime = .keepAlways
        add(screenshot)
    }
}
