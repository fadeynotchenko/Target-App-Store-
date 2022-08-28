//
//  TargetDetailView.swift
//  Target
//
//  Created by Fadey Notchenko on 26.08.2022.
//

import SwiftUI

struct TargetDetailView: View {
    
    @ObservedObject var target: Target
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.presentationMode) var presentation
    
    @EnvironmentObject var vm: ViewModel
    
    @State private var showActionView = false
    @State private var showEditView = false
    @State private var showFinishView = false
    
    @State private var progress: CGFloat = 0
    @State private var selection = 0
    
    @State private var sortSelection = 0
    
    @State private var circleWidth: CGFloat = 0
    
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
    
    private var showPlaceholder: Bool {
        Constants.IDIOM == .pad && vm.id == nil
    }
    
    var body: some View {
        if showPlaceholder {
            Text("Placeholder")
        } else {
            GeometryReader { reader in
                ScrollView {
                    VStack(spacing: Constants.IDIOM == .pad ? 50 : 30) {
                        circleProgressWithActionButtons(reader)
                            .padding(.top)
                        
                        Text("\(target.current) / \(target.price) \(symbol)")
                            .bold()
                            .font(.title2)
                    }
                    
                }
                .navigationTitle(Text(target.name ?? ""))
                .sheet(isPresented: $showEditView) {
                    TargetEditView(showEditView: $showEditView, target: target)
                }
                .sheet(isPresented: $showActionView) {
                    TargetActionView(showActionView: $showActionView, selection: selection, target: target)
                }
                .fullScreenCover(isPresented: $showFinishView) {
                    TargetFinishView(target: target, showFinishView: $showFinishView)
                }
                .toolbar {
                    ToolbarItem {
                        if !showPlaceholder {
                            Button("Изменить") {
                                showEditView = true
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func circleProgressWithActionButtons(_ reader: GeometryProxy) -> some View {
        HStack(spacing: Constants.IDIOM == .pad ? 40 : 0) {
            Spacer()
            
            sideButton(systemName: "minus") {
                selection = 0
                showActionView = true
            }
            
            if Constants.IDIOM == .phone { Spacer() }
            
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
                .frame(width: circleWidth, height: circleWidth)
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
            .frame(width: circleWidth, height: circleWidth)
            .onAppear {
                circleWidth = calculateCircleWidth(reader)
            }
            .onChange(of: reader.size.width) { new in
                circleWidth = calculateCircleWidth(reader)
            }
            
            if Constants.IDIOM == .phone { Spacer() }
            
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
                showFinishView = true
            }
        }
    }
    
    private func calculateCircleWidth(_ reader: GeometryProxy) -> CGFloat {
        if Constants.IDIOM == .pad {
            switch reader.size.width {
            case 0..<400: return 150
            case 400..<1000: return 220
            default:
                return 300
            }
        }
        
        return 200
    }
}
