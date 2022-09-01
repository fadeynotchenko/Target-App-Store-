//
//  TargetFinishView.swift
//  Target
//
//  Created by Fadey Notchenko on 27.08.2022.
//

import SwiftUI

struct TargetFinishView: View {
    
    let target: Target
    @Binding var showFinishView: Bool
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var viewContext
    
    @EnvironmentObject var vm: ViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                
                Text("Поздравляем!")
                    .bold()
                    .font(.largeTitle)
                
                Text("Ваша цель достигнута -")
                    .bold()
                    .font(.title2)
                    .frame(maxWidth: 350)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                
                Text("'\(target.name ?? "")'")
                    .bold()
                    .font(.largeTitle)
                    .gradientForeground(colors: [Constants.colorArray[Int(target.colorIndex)], .purple])
                
                DetailView(title1: "Накоплено:", subtitle1: Int(target.price), title2: "Потребовалось:", subtitle2: Constants.globalFunc.calculateDate(date: target.date ?? Date()), color: Constants.colorArray[Int(target.colorIndex)], symbol: Constants.valueArray[Int(target.valueIndex)].symbol)
                
                Spacer()
                
//                Text("hint")
//                    .frame(width: 300)
//                    .multilineTextAlignment(.center)
//                    .foregroundColor(.gray)
//                    .padding()
            }
            .toolbar {
                ToolbarItem {
                    Button("Закрыть") {
                        if Constants.IDIOM == .phone {
                            dismiss()
                        } else {
                            vm.id = nil
                        }
                        
                        target.isFinished = true
                        
                        PersistenceController.save(target: target, context: viewContext)
                    }
                }
            }
        }
    }
}

extension View {
    public func gradientForeground(colors: [Color]) -> some View {
        self.overlay(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)).mask(self)
    }
}
