//
//  TargetDetailView.swift
//  Target
//
//  Created by Fadey Notchenko on 26.08.2022.
//

import SwiftUI
import UserNotifications

struct TargetDetailView: View {
    
    @ObservedObject var target: Target
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.presentationMode) var presentation
    
    @EnvironmentObject var vm: ViewModel
    
    @State private var showActionView = false
    @State private var showEditView = false
    @State private var showFinishView = false
    @State private var showActionHistoryView = false
    
    @State private var progress: CGFloat = 0
    @State private var selection = 0
    
    @State private var sortSelection = 0
    
    @State private var circleWidth: CGFloat = 0
    
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
            Text("Выберите цель из списка")
        } else {
            GeometryReader { reader in
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .center, spacing: Constants.IDIOM == .pad ? 30 : 30) {
                        circleProgressWithActionButtons(reader)
                            .padding(.top)
                        
                        Text("\(target.current) / \(target.price) \(symbol)")
                            .bold()
                            .font(.title2)
                            .padding(.top)
                        
                        DetailView(title1: "Осталось:", subtitle1: Int(target.price - target.current), title2: "Прошло:", subtitle2: Constants.globalFunc.calculateDate(date: target.date ?? Date()), color: color, symbol: symbol)
                        
                        remindersView
                        
                        Button {
                            showActionHistoryView = true
                        } label: {
                            Text("История пополнений (\(target.actionArrayByDate.count))")
                                .bold()
                                .gradientForeground(colors: [color, .purple])
                        }
                        .padding()
                        .frame(width: 330)
                        .background(Color("Color"))
                        .cornerRadius(15)
                    }
                }
                .navigationTitle(Text(target.name ?? ""))
                .sheet(isPresented: $showEditView) {
                    TargetEditView(showEditView: $showEditView, target: target)
                }
                .sheet(isPresented: $showActionView) {
                    TargetActionView(showActionView: $showActionView, selection: $selection, target: target)
                }
                .sheet(isPresented: $showActionHistoryView) {
                    TargetActionHistoryView(target: target, showActionHistoryView: $showActionHistoryView)
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
                            .disabled(target.price == target.current)
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var remindersView: some View {
        if let next = target.dateNext {
            VStack(spacing: 10) {
                Text("Следующие запланированное пополнение копилки:")
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                
                Text(next, format: .dateTime.year().month().day())
                    .bold()
                    .font(.title3)
                    .gradientForeground(colors: [color, .purple])
                
                Text("Сумма пополнения:")
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.top)
                
                Text("\(target.replenishment) \(symbol)")
                    .bold()
                    .font(.title3)
                    .gradientForeground(colors: [color, .purple])
                
                Button {
                    let action = Action(context: viewContext)
                    action.id = UUID()
                    action.date = Date()
                    
                    if target.current + target.replenishment > target.price {
                        action.value = target.price - target.current
                        target.current = target.price
                    } else {
                        target.current += target.replenishment
                        action.value = target.replenishment
                    }
                    
                    target.addToAction(action)
                    
                    NotificationHandler.deleteNotification(by: target.id?.uuidString ?? UUID().uuidString)
                    
                    NotificationHandler.sendNotification(target, context: viewContext)
                    
                } label: {
                    Text("Пополнить")
                        .bold()
                    
                }
                .disabled(Date() < target.dateNext ?? Date())
                .padding()
                .frame(width: 300)
                .background(colorScheme == .light ? .white : .black)
                .cornerRadius(15)
                .padding(.top)
            }
            .padding()
            .frame(width: 330)
            .background(Color("Color"))
            .cornerRadius(15)
        }
    }
    
    private func circleProgressWithActionButtons(_ reader: GeometryProxy) -> some View {
        HStack(spacing: 0) {
            ForEach(0..<(Constants.IDIOM == .pad ? 3 : 1), id: \.self) { _ in
                Spacer()
            }
            
            sideButton(systemName: "minus") {
                selection = 0
                showActionView = true
            }
            .disabled(target.price == target.current)
            
            Spacer()
            
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
            .padding(.horizontal)
            .onAppear {
                circleWidth = calculateCircleWidth(reader)
            }
            .onChange(of: reader.size.width) { new in
                circleWidth = calculateCircleWidth(reader)
            }
            
            Spacer()
            
            sideButton(systemName: "plus") {
                selection = 1
                showActionView = true
            }
            .disabled(target.price == target.current)
            
            ForEach(0..<(Constants.IDIOM == .pad ? 3 : 1), id: \.self) { _ in
                Spacer()
            }
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
            case 0..<400: return 180
            case 400..<1000: return 220
            default:
                return 260
            }
        }
        
        return reader.size.width / 1.9
    }
}

struct DetailView: View {
    
    var title1: LocalizedStringKey
    var subtitle1: Int
    var title2: LocalizedStringKey
    var subtitle2: String
    var color: Color
    var symbol: String
    
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 5) {
                    Text(title1)
                        .foregroundColor(.gray)
                    
                    Text("\(subtitle1) \(symbol)")
                        .font(.title3)
                        .bold()
                        .gradientForeground(colors: [color, .purple])
                }
                
                Spacer()
                
                VStack(spacing: 5) {
                    Text(title2)
                        .foregroundColor(.gray)
                    
                    Text(subtitle2)
                        .font(.title3)
                        .bold()
                        .gradientForeground(colors: [color, .purple])
                }
                
                Spacer()
            }
        }
        .padding()
        .frame(width: 330)
        .background(Color("Color"))
        .cornerRadius(15)
    }
}
