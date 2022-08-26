//
//  TargetDetailView.swift
//  Target
//
//  Created by Fadey Notchenko on 26.08.2022.
//

import SwiftUI

struct TargetDetailView: View {
    
    @ObservedObject var target: Target
    @Binding var selected: UUID?
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.presentationMode) var presentation
    
    @State private var showActionView = false
    @State private var showEditView = false
    @State private var showFinishView = false
    
    @State private var progress: CGFloat = 0
    @State private var selection = 0
    
    @State private var sortSelection = 0
    
    private var actionArray: [Action] {
        switch sortSelection {
        case 1: return target.actionArrayByMaxValue
        case 2: return target.actionArrayByMinValue
        case 3: return target.actionArrayByComment
        default:
            return target.actionArrayByDate
        }
    }
    
    private var percent: Int {
        guard target.price != 0 else { return 0 }
        
        return Int(target.current * 100 / target.price)
    }
    
    private var symbol: String {
        Constants.valueArray[Int(target.valueIndex)].symbol
    }
    
    private var color: Color {
        Constants.colorArray[Int(target.colorIndex)]
    }
    
    private var region: String {
        String(Locale.preferredLanguages[0].prefix(2))
    }
    
    var body: some View {
        if Constants.IDIOM == .pad && selected == nil {
            Text("Placeholder")
        } else {
            GeometryReader { reader in
                ScrollView {
                    VStack(spacing: 30) {
                        circleProgressWithActionButtons(reader: reader)
                            .frame(minWidth: 300)
                            .frame(width: reader.size.width / 2)
                            .padding(.top)
                        
                    }
                    .frame(width: reader.size.width)
                }
                .frame(width: reader.size.width)
                .navigationTitle(Text(target.name ?? ""))
            }
        }
    }
    
    private func circleProgressWithActionButtons(reader: GeometryProxy) -> some View {
        HStack(spacing: 0) {
            Spacer()
            
            sideButton(systemName: "minus") {
                selection = 0
                showActionView = true
            }
            
            ZStack(alignment: .center) {
                ZStack {
                    Circle()
                        .stroke(lineWidth: 16)
                        .foregroundColor(Color("Color"))
                    
                    Circle()
                        .trim(from: 0.0, to: min(progress, 1.0))
                        .stroke(style: StrokeStyle(lineWidth: 16, lineCap: .round, lineJoin: .round))
                        .fill(LinearGradient(colors: [color, .purple], startPoint: .leading, endPoint: .trailing))
                        .rotationEffect(Angle(degrees: 270))
                    
                }
                .frame(minWidth: 150, maxWidth: 280, minHeight: 150, maxHeight: 280)
                .frame(width: Constants.IDIOM == .pad ? reader.size.width / 4 : reader.size.width / 1.9, height: Constants.IDIOM == .pad ? reader.size.width / 4 : reader.size.width / 1.9)
                .onChange(of: target.current) { newCurrent in
                    calculateProgress(target.price, newCurrent)
                }
                .onChange(of: target.price) { newPrice in
                    calculateProgress(newPrice, target.current)
                }
                .onAppear {
                    calculateProgress(target.price, target.current)
                }
                
                Text("\(percent) %")
                    .bold()
                    .font(.title)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            sideButton(systemName: "plus") {
                selection = 1
                showActionView = true
            }
            
            Spacer()
        }
    }
    
    private func sideButton(systemName: String, action: @escaping () -> ()) -> some View {
        Button(action: { action() }) {
            Image(systemName: systemName)
                .frame(width: 50, height: 50)
                .font(.system(size: 15))
                .background(Color("Color"))
                .clipShape(Circle())
        }
        
    }
    
    private func calculateProgress(_ price: Int64, _ current: Int64) {
        guard price != 0 else { return }
        
        withAnimation(.easeInOut(duration: 2.0)) {
            progress = CGFloat(current * 100 / price) / 100
        }
        
        checkFinish(price, current)
    }
    
    private func checkFinish(_ price: Int64, _ current: Int64) {
        if current >= price {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showFinishView.toggle()
            }
        }
    }
}
