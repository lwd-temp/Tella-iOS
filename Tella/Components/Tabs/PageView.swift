//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

public struct PageView: View {
    
    @Binding var selectedOption: Pages
    @Binding var outboxCount: Int
    let pageWidth = UIScreen.main.bounds.size.width/5
    var titles = ["Draft","Outbox","Submitted"]
    
   public var body: some View {
        HStack(spacing: 15) {

            
            Button(action: {
                withAnimation(.interactiveSpring()){
                    self.selectedOption = .draft
                }
            }, label: {
                PageViewCell(title: titles[0], width: pageWidth, page: .draft, selectedOption: $selectedOption)
            })
            
            Button(action: {
                withAnimation(.interactiveSpring()){
                    self.selectedOption = .outbox
                }
            }, label: {
                PageViewCellNotification(title: titles[1], width: pageWidth, page: .outbox, selectedOption: $selectedOption, outBoxCount: $outboxCount)
            })
            
            Button(action: {
                withAnimation(.interactiveSpring()){
                    self.selectedOption = .submitted
                }
            }, label: {
                PageViewCell(title: titles[2], width: pageWidth, page: .submitted, selectedOption: $selectedOption)
            })
        }
    }
}
