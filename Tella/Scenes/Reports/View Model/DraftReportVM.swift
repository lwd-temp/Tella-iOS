//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import Combine

class DraftReportVM: ObservableObject {
    
    var mainAppModel : MainAppModel
    
    // Report
    @Published var id : Int?
    @Published var title : String = ""
    @Published var description : String = ""
    @Published var files : [VaultFile] = []
    @Published var server : Server?
    @Published var status : ReportStatus?
    
    // Fields validation
    @Published var isValidTitle : Bool = false
    @Published var isValidDescription : Bool = false
    @Published var shouldShowError : Bool = false
    @Published var reportIsValid : Bool = false
    @Published var reportIsDraft : Bool = false
    
    
    var serverArray : [Server] = []
    
    var cancellable : Cancellable? = nil
    private var subscribers = Set<AnyCancellable>()
    
    var serverName : String {
        guard let serverName = server?.name else { return "Select your project" }
        return serverName
    }
    
    var hasMoreServer: Bool {
        return serverArray.count > 1
    }
    
    init(mainAppModel : MainAppModel, report:Report? = nil) {
        
        self.mainAppModel = mainAppModel
        
        cancellable = $server.combineLatest( $isValidTitle, $isValidDescription).sink(receiveValue: { server, isValidTitle, isValidDescription in
            self.reportIsValid = (server != nil) && isValidTitle && isValidDescription
        })
        
        $isValidTitle.combineLatest($isValidDescription, $files).sink(receiveValue: { isValidTitle, isValidDescription, files in
            self.reportIsDraft = isValidTitle || isValidDescription || !files.isEmpty
        }).store(in: &subscribers)
        
        getServers()
        
        initcurrentReportVM()
        
        fillReportVM(report: report)
    }
    
    func getServers()  {
        serverArray = mainAppModel.vaultManager.tellaData.servers.value
    }
    
    func initcurrentReportVM() {
        if serverArray.count == 1 {
            server = serverArray.first
        }
    }
    
    func fillReportVM(report: Report?) {
        if let report = report {
            self.id = report.id
            self.title = report.title ?? ""
            self.description = report.description ?? ""
            self.server = report.server
        }
    }
    
    func saveReport() {
        
        guard let server = server else { return }
        
        let report = Report(id: id, title: title, description: description, date: Date(), status: status, server: server)
        
        do {
            if let _ = id {
                let _ = try mainAppModel.vaultManager.tellaData.updateReport(report: report)
            } else {
                let _ = try mainAppModel.vaultManager.tellaData.addReport(report: report)
            }
        } catch {
            
        }
    }
}
