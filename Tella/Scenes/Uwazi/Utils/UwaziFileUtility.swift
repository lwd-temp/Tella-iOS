//
//  UwaziFileUtility.swift
//  Tella
//
//  Created by Gustavo on 02/11/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation


struct UwaziFileUtility {
    var files: Set<VaultFileDB>?
    var mainAppModel: MainAppModel?
    
    func getFilesInfo() -> [UwaziAttachment] {
        return files?.compactMap { file in
            if let fileData = self.mainAppModel?.vaultManager.loadFileData(file: file) {
                return UwaziAttachment(filename: file.name, data: fileData, fileExtension: file.fileExtension)
            } else {
                return nil
            }
        } ?? []
    }
    
}
