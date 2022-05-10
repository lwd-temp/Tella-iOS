//
//  LockViewModel.swift
//  Tella
//
//   
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
class LockViewModel: ObservableObject {
    
    @Published var loginPassword : String = CalculatorData.initialCharacter
    @Published var password : String = CalculatorData.initialCharacter
    @Published var confirmPassword : String = CalculatorData.initialCharacter
    @Published var oldPassword : String = ""
    @Published var shouldShowUnlockError : Bool = false
    @Published var isValid : Bool = true
    
    var privateKey : SecKey?
    var unlockType : UnlockType = .new
    var shouldDismiss = CurrentValueSubject<Bool, Never>(false)
    
    func validatePinMatch()  {
        isValid = password == confirmPassword
    }
    
    init() {
    }
    
    init(unlockType: UnlockType) {
        self.unlockType = unlockType
    }
    
    func login() {
        self.privateKey = CryptoManager.shared.recoverKey(.PRIVATE, password: loginPassword)
        shouldShowUnlockError = privateKey == nil
    }
    
    func initUnlockData() {
        loginPassword = CalculatorData.initialCharacter
        password = CalculatorData.initialCharacter
        confirmPassword = CalculatorData.initialCharacter
        shouldShowUnlockError = false
        self.shouldDismiss.send(false)
        isValid = true
    }
    
    func initLockData() {
        password = CalculatorData.initialCharacter
        confirmPassword = CalculatorData.initialCharacter
        shouldShowUnlockError = false
    }
}
