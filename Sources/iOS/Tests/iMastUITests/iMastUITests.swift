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

import XCTest

class iMastUITests: XCTestCase {
    let app = XCUIApplication()
    let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        addUIInterruptionMonitor(withDescription: "hoge") { element -> Bool in
            print("おぴょ！！！！！！！")
            return true
        }
        let instance = app.textFields["mastodon.example"]
        instance.tap()
        instance.typeText("mstdn.otyakai.xyz")
        shot()
        let loginButton = app.cells["loginButton"]
        loginButton.tap()
        shot()
        let loginWithSafari = app.cells["loginWithSafari"]
        loginWithSafari.waitForExistence(timeout: 10)
        loginWithSafari.tap()
        shot()
        let asWebAuthAlert = springboard.alerts.element(matching: .init(format: "label CONTAINS %@", "otyakai.xyz"))
        asWebAuthAlert.buttons["Continue"].tap()
    }
    
    func shot() {
        let screenshot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        screenshot.lifetime = .keepAlways
        add(screenshot)
    }
}
