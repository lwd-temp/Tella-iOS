//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//
import SwiftUI


enum ReportPaths {
    case reportMain
    case draft
    case outbox
    case submitted
}

struct ReportsView: View {
    
    @EnvironmentObject var mainAppModel : MainAppModel
    @StateObject private var reportsViewModel : ReportsViewModel
    
    init(mainAppModel:MainAppModel) {
        _reportsViewModel = StateObject(wrappedValue: ReportsViewModel(mainAppModel: mainAppModel))
    }
    
    var body: some View {
        
        contentView
            .navigationBarTitle(LocalizableReport.reportsTitle.localized, displayMode: .large)
            .environmentObject(reportsViewModel)
    }
    
    private var contentView :some View {
        
        ContainerView {
            
            VStack(alignment: .center) {
                
                PageView(selectedOption: self.$reportsViewModel.selectedCell, pageViewItems: $reportsViewModel.pageViewItems)
                    .frame(maxWidth: .infinity, maxHeight: 40, alignment: .leading)
                
                VStack (spacing: 0) {
                    Spacer()
                    
                    switch self.reportsViewModel.selectedCell {
                        
                    case .draft:
                        ReportListView(reportArray: $reportsViewModel.draftReports,
                                       message: LocalizableReport.reportsDraftEmpty.localized)
                        
                    case .outbox:
                        
                        ReportListView(reportArray: $reportsViewModel.outboxedReports,
                                       message: LocalizableReport.reportsOutboxEmpty.localized)
                        
                    case .submitted:
                        ReportListView(reportArray: $reportsViewModel.submittedReports,
                                       message: LocalizableReport.reportsSubmitedEmpty.localized)
                    }
                    
                    Spacer()
                }
                
                TellaButtonView<AnyView> (title: LocalizableReport.reportsCreateNew.localized,
                                          nextButtonAction: .action,
                                          buttonType: .yellow,
                                          isValid: .constant(true)) {
                    navigateTo(destination: newDraftReportView)
                } .padding(EdgeInsets(top: 30, leading: 0, bottom: 0, trailing: 0))
                
            }.background(Styles.Colors.backgroundMain)
                .padding(EdgeInsets(top: 15, leading: 20, bottom: 16, trailing: 20))
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
    }
    
    private var newDraftReportView: some View {
        DraftReportView(mainAppModel: mainAppModel).environmentObject(reportsViewModel)
    }
    
    var backButton : some View {
        Button {
            self.popToRoot()
        } label: {
            Image("back")
                .padding(EdgeInsets(top: -3, leading: -8, bottom: 0, trailing: 12))
        }
    }
    
}

struct ReportsView_Previews: PreviewProvider {
    
    static var previews: some View {
        ReportsView(mainAppModel: MainAppModel())
    }
}

extension Int: Identifiable {
    public var id: Int { self }
}
