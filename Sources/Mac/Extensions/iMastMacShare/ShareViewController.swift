//
//  ShareViewController.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2019/11/10.
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

import Cocoa
import Social

class ShareViewController: SLComposeServiceViewController {

    override func loadView() {
        super.loadView()
    
        // Insert code here to customize the view
        self.title = NSLocalizedString("iMastMacShare", comment: "Title of the Social Service")
    
        NSLog("Input Items = %@", self.extensionContext!.inputItems as NSArray)
    }

    override func didSelectPost() {
        // Perform the post operation
        // When the operation is complete (probably asynchronously), the service should notify the success or failure as well as the items that were actually shared
    
        let inputItem = self.extensionContext!.inputItems[0] as! NSExtensionItem
    
        let outputItem = inputItem.copy() as! NSExtensionItem
        outputItem.attributedContentText = NSAttributedString(string: self.contentText)
        // Complete implementation by setting the appropriate value on the output item
    
        let outputItems = [outputItem]
    
        self.extensionContext!.completeRequest(returningItems: outputItems, completionHandler: nil)
    }

    override func didSelectCancel() {
        // Cleanup
    
        // Notify the Service was cancelled
        let cancelError = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil)
        self.extensionContext!.cancelRequest(withError: cancelError)
    }

    override func isContentValid() -> Bool {
        let messageLength = self.contentText.trimmingCharacters(in: CharacterSet.whitespaces).utf8.count
        let charactersRemaining = 140 - messageLength
        self.charactersRemaining = charactersRemaining as NSNumber
        
        if charactersRemaining >= 0 {
            return true
        }
        
        return false
    }

}
