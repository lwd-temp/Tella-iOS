//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation


class LockTimeoutOptionsStatus :Hashable{
    
    var lockTimeoutOption :  LockTimeoutOption
    var isSelected :  Bool
    
    init(lockTimeoutOption :  LockTimeoutOption, isSelected :  Bool) {
        self.lockTimeoutOption = lockTimeoutOption
        self.isSelected = isSelected
    }
    
    static func == (lhs: LockTimeoutOptionsStatus, rhs: LockTimeoutOptionsStatus) -> Bool {
        lhs.lockTimeoutOption  == rhs.lockTimeoutOption
    }
    
    func hash(into hasher: inout Hasher){
        hasher.combine(lockTimeoutOption.hashValue)
    }
    
}
