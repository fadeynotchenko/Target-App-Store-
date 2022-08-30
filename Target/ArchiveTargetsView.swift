//
//  ArchiveTargetsView.swift
//  Target
//
//  Created by Fadey Notchenko on 29.08.2022.
//

import SwiftUI

struct ArchiveTargetsView: View {
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "date", ascending: true)]) var targets: FetchedResults<Target>
    
    private func getSymbol(_ target: Target) -> String {
        Constants.valueArray[Int(target.valueIndex)].symbol
    }
    
    var body: some View {
        ZStack {
            List {
                ForEach(targets.filter({ $0.isFinished })) { target in
                    archiveRow(target)
                }
            }
            .listStyle(.inset)
            
            if targets.filter({ $0.isFinished }).isEmpty {
                Text("archiveempty")
            }
        }
        .navigationTitle(Text("archive"))
    }
    
    private func archiveRow(_ target: Target) -> some View {
            VStack(alignment: .leading, spacing: 10) {
                Text(target.name ?? "")
                    .bold()
                    .font(.title3)
                
                HStack(spacing: 5) {
                    Text("accumulated")
                        .foregroundColor(.gray)
                    
                    Text("\(target.current) \(getSymbol(target))")
                        .bold()
                        .gradientForeground(colors: [Constants.colorArray[Int(target.colorIndex)], .purple])
                }
                
                HStack(spacing: 5) {
                    Text("per")
                        .foregroundColor(.gray)
                    
                    Text(Constants.globalFunc.calculateDate(date: target.date ?? Date()))
                        .bold()
                        .gradientForeground(colors: [Constants.colorArray[Int(target.colorIndex)], .purple])
                }
                
                HStack(spacing: 5) {
                    Text("date2")
                        .foregroundColor(.gray)
                    
                    Text(target.date ?? Date(), format: .dateTime.day().month().year())
                        .bold()
                        .gradientForeground(colors: [Constants.colorArray[Int(target.colorIndex)], .purple])
                }
            }
            .padding()
    }
}
