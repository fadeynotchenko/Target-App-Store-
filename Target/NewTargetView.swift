//
//  NewGoalView.swift
//  GoalApp
//
//  Created by Fadey Notchenko on 17.07.2022.
//

import SwiftUI
import AnyFormatKitSwiftUI

struct NewTargetView: View {
    
    @Binding var showNewTargetView: Bool
    
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "date", ascending: true)]) var targets: FetchedResults<Target>
    
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var name = ""
    @State private var price: NSNumber?
    @State private var current: NSNumber?
    @State private var valueIndex = 0
    @State private var colorIndex = 0
    @State private var addReplenishment = false
    @State private var timeIndex = 0
    @State private var replenishment: NSNumber?
    
    @State private var notify = true
    
    @EnvironmentObject var vm: ViewModel
    
    private var region: String {
        String(Locale.preferredLanguages[0].prefix(2))
    }
    
    private var value: Value {
        Constants.valueArray[Int(valueIndex)]
    }
    
    //timer need for call check notification permission every second
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView {
            Form {
                nameSection
                
                priceSection
                
                addReplenishmentSection
                
                LazyColorHStack(tagIndex: $colorIndex)
            }
            .navigationTitle(Text("Новая цель"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        showNewTargetView = false
                    }
                }
                
                ToolbarItem {
                    addGoalButton
                }
            }
            
        }
        .accentColor(.purple)
        .navigationViewStyle(.stack)
    }
    
    private var nameSection: some View {
        Section {
            TextField("Название Вашей цели", text: $name)
                .onChange(of: name) { _ in
                    if name.count > 20 {
                        name = String(name.prefix(20))
                    }
                }
        }
    }
    
    private var priceSection: some View {
        Section {
            Picker("Изменить валюту", selection: $valueIndex) {
                ForEach(0..<Constants.valueArray.count, id: \.self) { i in
                    Text(Constants.valueArray[i].rawValue)
                }
                .onAppear {
                    if region != "ru" {
                        valueIndex = 1
                    }
                }
            }
            
            FormatSumTextField(numberValue: $price, placeholder: "Cколько стоит Ваша цель?", numberFormatter: Constants.formatter())
                .keyboardType(.numberPad)
                .onChange(of: price, perform: { _ in
                    if Int(truncating: price ?? 0) > Constants.MAX {
                        price = Constants.MAX as NSNumber?
                    }
                })
            
            FormatSumTextField(numberValue: $current, placeholder: "Сколько уже накоплено?", numberFormatter: Constants.formatter())
                .keyboardType(.numberPad)
                .onChange(of: current, perform: { _ in
                    if Int(truncating: current ?? 0) > Int(truncating: price ?? 0) {
                        current = price
                    }
                })
            
        }
    }
    
    private var addGoalButton: some View {
        Button("Добавить") {
            showNewTargetView.toggle()
            
            let target = Target(context: managedObjectContext)
            target.id = UUID()
            target.name = name
            target.price = price as! Int64
            target.current = Int64(truncating: current ?? 0)
            target.colorIndex = Int16(colorIndex)
            target.valueIndex = Int16(valueIndex)
            target.date = Date()
            
            if let replenishment = replenishment, addReplenishment {
                target.replenishment = Int64(truncating: replenishment)
                target.timeIndex = Int16(timeIndex)
                
                NotificationHandler.sendNotification(target, context: managedObjectContext)
            }
            
            PersistenceController.save(target: target, context: managedObjectContext)
        }
        .disabled(name.isEmpty)
        .disabled(price == nil)
    }
    
    private var addReplenishmentSection: some View {
        Section {
            NavigationLink {
                addReplenishmentView
            } label: {
                VStack(alignment: .leading) {
                    Text("Напоминания")
                    
                    HStack(spacing: 5) {
                        if addReplenishment {
                            Text("Раз в")
                                .foregroundColor(.gray)
                        }
                        
                        Text(addReplenishment ? Constants.timeEnumArray[timeIndex].key.lowercased() : "Никогда")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 5)
            }
        }
    }
    
    private var addReplenishmentView: some View {
        Form {
            Section {
                Toggle(isOn: $addReplenishment) {
                    Text("Добавить напоминания")
                }
                .onAppear {
                    NotificationHandler.requestPermission()
                }
                .onReceive(timer) { _ in
                    Task {
                        notify = try await vm.getPermissionState()
                        
                        if !notify {
                            addReplenishment = false
                        }
                    }
                }
                .disabled(!notify)
            } footer: {
                if !notify {
                    Text("Для работы напоминаний требуется доступ к уведомлениям. \n 'Настройки' -> 'Target' -> 'Уведомления'")
                        .foregroundColor(.red)
                }
            }
            
            if addReplenishment, notify {
                Section {
                    Picker("", selection: $timeIndex) {
                        ForEach(0..<Constants.timeEnumArray.count, id: \.self) { i in
                            Text(Constants.timeEnumArray[i].key)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                } header: {
                    Text("Раз в")
                }
                
                Section {
                    FormatSumTextField(numberValue: $replenishment, placeholder: "Сколько хотите откладывать?", numberFormatter: Constants.formatter())
                        .keyboardType(.numberPad)
                }
            }
        }
        .navigationTitle(Text("Напоминания"))
    }
}

struct LazyColorHStack: View {
    
    @Binding var tagIndex: Int
    
    var body: some View {
        Section {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach(0..<Constants.colorArray.count, id: \.self) { i in
                        ZStack {
                            if tagIndex == i {
                                Circle()
                                    .fill(.gray)
                                    .frame(width: 36, height: 36)
                            }
                            
                            Circle()
                                .fill(Constants.colorArray[i])
                                .frame(width: 30, height: 30)
                                .onTapGesture {
                                    tagIndex = i
                                }
                                .padding(5)
                        }
                    }
                }
            }
        } footer: {
            Text("Цвет прогресса")
        }
    }
}
