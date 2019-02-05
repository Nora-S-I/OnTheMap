//
//  Common.swift
//  On The Map
//
//  Created by Norah Al Ibrahim on 1/30/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func alert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message:
            message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
}

class Common {
    class func error(_ message: String, reason: String, code: Int) -> Error {
        let userInfo: [AnyHashable: Any] = [NSLocalizedDescriptionKey: message, NSLocalizedFailureReasonErrorKey: reason]
        return NSError(domain: Bundle.main.bundleIdentifier!, code: code, userInfo: (userInfo as! [String : Any]))
    }
    
}

struct StoryboardID {
    static let addLocation = "addLocationView"
}
