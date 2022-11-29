//
//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct ReportFileGridView: View {
    
    var file: VaultFile
    
    @EnvironmentObject var appModel: MainAppModel
    @EnvironmentObject var draftReportVM: DraftReportVM
    
    var body: some View {
            fileGridView
            .overlay(deleteButton, alignment: .topTrailing)
    }
    
    var fileGridView : some View {
        ZStack {
            file.gridImage
            self.fileNameText
        }
    }
    
    var deleteButton : some View {
        Button {
            draftReportVM.deleteFile(fileId: file.id)
        } label: {
            Image("report.delete")
                .padding(.all, 10)
        }
    }
    
    
    @ViewBuilder
    var fileNameText: some View {

        if self.file.type != .image || self.file.type != .video {
            VStack {
                Spacer()
                Text(self.file.fileName)
                    .font(.custom(Styles.Fonts.regularFontName, size: 11))
                    .foregroundColor(.white)
                    .lineLimit(1)
                Spacer()
                    .frame(height: 6)
            }.padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
        }
    }
    
    @ViewBuilder
    var selectionButton: some View {
        
        VStack(alignment: .trailing) {
            Spacer()
            HStack {
                Spacer()
                //                if !fileListViewModel.showingMoveFileView {
                //                    if !fileListViewModel.selectingFiles && !fileListViewModel.shouldHideViewsForGallery {
                MoreFileActionButton(file: file, moreButtonType: .grid)
                //                    }
                //                }
            }
        }
    }
    
    
}
//
//struct ReportFileGridView_Previews: PreviewProvider {
//    static var previews: some View {
//        ReportFileGridView()
//    }
//}
