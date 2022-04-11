//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

class ListActionSheetItem {
    
    var imageName: String = ""
    var content: String = ""
    var action: () -> () = {}
    var isActive : Bool = true
    var viewType : ActionSheetItemType = .item
    var type : ActionType
    
    init(imageName: String = "",
         content: String = "",
         action: @escaping () -> () = {},
         isActive : Bool = true,
         viewType : ActionSheetItemType = .item,
         type : ActionType) {
        self.imageName = imageName
        self.content = content
        self.action = action
        self.isActive = isActive
        self.viewType = viewType
        self.type = type
    }

}
