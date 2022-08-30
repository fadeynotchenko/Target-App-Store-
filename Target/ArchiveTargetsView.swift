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
        NavigationLink {
            archiveDetail(target)
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                Text(target.name ?? "")
                    .bold()
                    .font(.title3)
                
                HStack(spacing: 5) {
                    Text("Накопленно:")
                        .foregroundColor(.gray)
                    
                    Text("\(target.current) \(getSymbol(target))")
                        .bold()
                        .gradientForeground(colors: [Constants.colorArray[Int(target.colorIndex)], .purple])
                }
                
                HStack(spacing: 5) {
                    Text("Накопили за:")
                        .foregroundColor(.gray)
                    
                    Text(Constants.globalFunc.calculateDate(date: target.date ?? Date()))
                        .bold()
                        .gradientForeground(colors: [Constants.colorArray[Int(target.colorIndex)], .purple])
                }
                
                HStack(spacing: 5) {
                    Text("Дата создания:")
                        .foregroundColor(.gray)
                    
                    Text(target.date ?? Date(), format: .dateTime.day().month().year())
                        .bold()
                        .gradientForeground(colors: [Constants.colorArray[Int(target.colorIndex)], .purple])
                }
            }
            .padding()
        }
    }
    
    private func archiveDetail(_ target: Target) -> some View {
        ZStack {
        List {
            ForEach(target.actionArrayByDate) { action in
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 5) {
                        if action.value < 0 {
                            Image(systemName: "arrow.down")
                                .foregroundColor(.red)
                        } else {
                            Image(systemName: "arrow.up")
                                .foregroundColor(.green)
                        }
                        
                        Text(action.value < 0 ? "\(action.value) \(getSymbol(target))" : "+\(action.value) \(getSymbol(target))")
                            .bold()
                            .font(.title3)
                            .foregroundColor(action.value < 0 ? .red : .green)
                        
                        Spacer()
                        
                        Text(action.date ?? Date(), format: .dateTime.day().month().year())
                            .foregroundColor(.gray)
                    }
                    
                    if let comment = action.comment, !comment.isEmpty {
                        Text(comment)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color("Color"))
                .cornerRadius(15)
            }
        }
        }
    }
}
