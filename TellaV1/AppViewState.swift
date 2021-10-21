//
//  AppViewState.swift
//  Tella
//
//  Created by Rance Tsai on 9/7/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

import SwiftUI

final class AppViewState: ObservableObject {
    var homeViewModel = MainAppModel()

    @Published private var viewStack = [MainViewEnum]()
    init() {
        CryptoManager.shared.keysInitialized() ? self.resetToMain() : self.resetToAuth()

    }
    var currentView: MainViewEnum {
        return viewStack.last ?? .AUTH
    }

    func navigateBack() {
        viewStack.removeLast()
    }

    func navigate(to view: MainViewEnum) {
        viewStack.append(view)
    }

    func resetToAuth() {
        viewStack = [.AUTH]
    }

    func resetToMain() {
        viewStack = [.MAIN]
    }
}
