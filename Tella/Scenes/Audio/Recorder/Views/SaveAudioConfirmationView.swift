//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct SaveAudioConfirmationView: View {
    
    @ObservedObject var viewModel : RecordViewModel
    @Binding var showingSaveSuccessView : Bool
    
    @EnvironmentObject var sheetManager: SheetManager
    @EnvironmentObject var mainAppModel : MainAppModel
    
    
    var body: some View {
        
        ConfirmBottomSheet(titleText: Localizable.Audio.saveRecordingTitle,
                           msgText: Localizable.Audio.saveRecordingMessage,
                           cancelText: Localizable.Common.discard,
                           actionText: Localizable.Common.save,
                           withDrag: false) {
            
            sheetManager.hide()
            
            self.viewModel.onStopRecording()
            
            DispatchQueue.main.async {
                showingSaveSuccessView = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                showingSaveSuccessView = false
            }
            
            mainAppModel.selectedTab = .home
            
        } didCancelAction: {
            sheetManager.hide()
            self.viewModel.onResetRecording()
            mainAppModel.selectedTab = .home
        }
    }
}

struct SaveAudioConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        SaveAudioConfirmationView(viewModel: RecordViewModel(mainAppModel: MainAppModel(),
                                                             rootFile: VaultFile.stub(type: .image)),
                                  showingSaveSuccessView: .constant(true))
    }
}
