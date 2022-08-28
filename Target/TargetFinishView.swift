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
    
    @Environment(\.presentationMode) var presentation
    @Environment(\.managedObjectContext) var viewContext
    
    @EnvironmentObject var vm: ViewModel
    
    @State private var backToMainView = false
    
    var body: some View {
        GeometryReader { reader in
            NavigationView {
                VStack(spacing: 0) {
                    
                    Text("Поздравляем!")
                        .bold()
                        .font(.largeTitle)
                    
                    Text("Ваша цель достигнута - ")
                        .bold()
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: 350)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                    
                    Text("'\(target.name ?? "")'")
                        .bold()
                        .font(.largeTitle)
                        .gradientForeground(colors: [Constants.colorArray[Int(target.colorIndex)], .purple])
                    
                    HStack(spacing: 15) {
                        DetailButton(color: Constants.colorArray[Int(target.colorIndex)], title: "Накопленно", subtitle: Text("\(target.price) \(Constants.valueArray[Int(target.valueIndex)].symbol)"), reader: reader)
                        
                        DetailButton(color: Constants.colorArray[Int(target.colorIndex)], title: "Понадобилось", subtitle: Text("\(Constants.globalFunc.calculateDate(date: target.date ?? Date()))"), reader: reader)
                    }
                    .padding(.top, 25)
                    
                    Spacer()
                    
                    Text("Посмотреть весь прогресс можно в разделе 'Архив'")
                        .frame(width: 300)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                }
                .toolbar {
                    ToolbarItem {
                        Button("Закрыть") {
                            if Constants.IDIOM == .phone {
                                backToMainView = true
                            } else {
                                vm.id = nil
                            }
                            
                            target.isFinished = true
                        }
                    }
                }
                .fullScreenCover(isPresented: $backToMainView) {
                    ContentView()
                }
            }
        }
    }
}

struct DetailButton: View {
    
    var color: Color
    var title: String
    var subtitle: Text
    var reader: GeometryProxy
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 10) {
            Text(title)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .font(.system(size: 16))
            
            subtitle
                .font(.title3)
                .bold()
                .gradientForeground(colors: [color, .purple])
                .multilineTextAlignment(.center)
            
        }
        .padding()
        .frame(maxWidth: 150)
        .frame(width: reader.size.width / 2.5)
        .background(Color("Color"))
        .cornerRadius(15)
        
    }
}

extension View {
    public func gradientForeground(colors: [Color]) -> some View {
        self.overlay(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)).mask(self)
    }
}
