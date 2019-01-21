//
//  AVAssetExportSession+exportPromise.swift
//  iMast
//
//  Created by user on 2019/01/21.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import AVFoundation
import Hydra

extension AVAssetExportSession {
    func exportPromise() -> Promise<Void> {
        return Promise { resolve, reject, _ in
            self.exportAsynchronously {
                if let error = self.error {
                    return reject(error)
                }
                resolve(())
            }
        }
    }
}
