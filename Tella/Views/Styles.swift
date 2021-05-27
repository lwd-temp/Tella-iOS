//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import UIKit
import SwiftUI

struct Styles {
    
    struct Colors {
        static let backgroundFileButton = UIColor(hexValue: 0x4e4a74)
        static let backgroundMain = UIColor(hexValue: 0x2C275A)
        static let backgroundTab = UIColor(hexValue: 0x46407D)
    }

}

public extension UIColor {
    
    convenience init(redInt: Int, greenInt: Int, blueInt: Int, alpha: CGFloat=1.0) {
        self.init(red: CGFloat(redInt)/255.0, green: CGFloat(greenInt)/255.0, blue: CGFloat(blueInt)/255.0, alpha: alpha)
    }
    
    convenience init(hexValue: Int) {
        let red = (hexValue >> 16) & 0xFF
        let green = (hexValue >> 8) & 0xFF
        let blue = hexValue & 0xFF
        
        self.init(redInt: red, greenInt: green, blueInt: blue)
    }
}
