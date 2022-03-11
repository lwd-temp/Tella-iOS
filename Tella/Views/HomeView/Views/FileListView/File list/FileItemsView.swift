//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct FileItemsView: View {
    
    @EnvironmentObject var fileListViewModel : FileListViewModel
    var files : [VaultFile]
    
    private var gridLayout: [GridItem] {
        [GridItem(.adaptive(minimum: 80),spacing: 6)]
    }
    
    private var maxHeight: CGFloat {
        return (UIScreen.screenWidth / 4) - 6
    }
    
    var body: some View {
        if fileListViewModel.viewType == .list {
            itemsListView
        } else {
            itemsGridView
        }
    }
    
    @available(iOS 14.0, *)
    var itemsGridView: some View {
        ScrollView {
            LazyVGrid(columns: gridLayout, alignment: .center, spacing: 6) {
                ForEach(files, id: \.self) { file in
                    
                    switch file.type {
                    case .folder:
                        
                        FileGridItem(file: file)
                            .frame( minHeight: maxHeight)
                            .onTapGesture {
                                fileListViewModel.rootFile = file
                                fileListViewModel.folderArray.append(file)
                            }
                    default:
                        ZStack {
                            FileGridItem(file: file)
                                .frame( minHeight: maxHeight)
                                .onTapGesture {
                                    fileListViewModel.showFileDetails = true
                                    self.fileListViewModel.currentSelectedVaultFile = file
                                }
                        }
                    }
                }
            }.padding(EdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 6))
        }
    }
    
    private var itemsListView: some View {
        ScrollView {
            LazyVStack(spacing: 1) {
                ForEach(files, id: \.self) { file in
                    switch file.type {
                    case .folder:
                        FileListItem(file: file)
                            .frame(height: 60)
                            .onTapGesture {
                                fileListViewModel.rootFile = file
                                fileListViewModel.folderArray.append(file)
                            }
                        
                    default:
                        FileListItem(file: file)
                            .frame(height: 60)
                            .onTapGesture {
                                fileListViewModel.showFileDetails = true
                                self.fileListViewModel.currentSelectedVaultFile = file
                            }
                    }
                }
                .listRowBackground(Color.green)
            }
        }
        .background(Styles.Colors.backgroundMain)
    }
}

struct FileItemsView_Previews: PreviewProvider {
    static var previews: some View {
        FileItemsView(files: [VaultFile.stub(type: .folder),
                              VaultFile.stub(type: .folder)])
            .environmentObject(FileListViewModel.stub())
        
    }
}
