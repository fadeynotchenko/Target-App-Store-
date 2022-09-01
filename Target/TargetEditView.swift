//
//  TargetEditView.swift
//  Target
//
//  Created by Fadey Notchenko on 27.08.2022.
//

import SwiftUI
import AnyFormatKitSwiftUI

struct TargetEditView: View {
    
    @Binding var showEditView: Bool
    var target: Target
    
    @State private var newName: String = ""
    @State private var newPrice: NSNumber?
    @State private var newTagIndex: Int = 0
    @State private var newTimeIndex = 0
    @State private var newReplenishment: NSNumber?
    @State private var error = false
    
    @State var addReplenishment = false
    @State var timeIndex = 0
    @State var notify = true
    @State var replenishment: NSNumber?
    
    @State private var backToMainView = false
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.presentationMode) var present
    
    @EnvironmentObject var vm: ViewModel
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section {
                        TextField("newname", text: $newName)
                            .onChange(of: newName, perform: {
                                newName = String($0.prefix(30))
                            })
                            .onAppear {
                                newName = target.name ?? ""
                            }
                    }
                    
                    Section {
                        FormatSumTextField(numberValue: $newPrice, placeholder: "Сколько стоит Ваша цель?", numberFormatter: Constants.formatter())
                            .keyboardType(.numberPad)
                            .onAppear {
                                newPrice = (target.price) as NSNumber
                            }
                    }
                    
                    addReplenishmentSection
                    
                    LazyColorHStack(tagIndex: $newTagIndex)
                        .onAppear {
                            newTagIndex = Int(target.colorIndex)
                        }
                    
                    Section {
                        Button {
                            withAnimation {
                                backToMainView = true
                            }
                            
                            NotificationHandler.deleteNotification(by: target.id?.uuidString ?? UUID().uuidString)
                            
                            PersistenceController.deleteTarget(target: target, context: managedObjectContext)
                        } label: {
                            Text("Удалить цель")
                                .foregroundColor(.red)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .onAppear {
                print("call ")
                if target.dateNext != nil {
                    addReplenishment = true
                }
                
                timeIndex = Int(target.timeIndex)
                if target.replenishment > 0 {
                    replenishment = target.replenishment as NSNumber
                }
            }
            .navigationTitle(Text("Изменить цель"))
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $backToMainView) {
                ContentView()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        showEditView.toggle()
                    }
                }
                
                ToolbarItem {
                    Button {
                        showEditView.toggle()
                        DispatchQueue.main.async {
                            target.name = newName
                            target.price = Int64(truncating: newPrice ?? 0)
                            target.colorIndex = Int16(newTagIndex)
                            if addReplenishment, let replenishment = replenishment{
                                target.replenishment = replenishment as! Int64
                                target.timeIndex = Int16(timeIndex)
                                
                                NotificationHandler.deleteNotification(by: target.id?.uuidString ?? UUID().uuidString)
                                
                                NotificationHandler.sendNotification(target, context: managedObjectContext)
                            }
                            
                            PersistenceController.save(target: target, context: managedObjectContext)
                        }
                        
                    } label: {
                        Text("Сохранить")
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .disabled(newName.isEmpty || newPrice == nil)
                }
            }
        }
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
                .onChange(of: addReplenishment) { toggle in
                    if toggle {
                        NotificationHandler.requestPermission()
                    }
                }
                .onChange(of: replenishment) { _ in
                    if let replenishment = replenishment {
                        target.replenishment = replenishment as! Int64
                    }
                    PersistenceController.save(target: target, context: managedObjectContext)
                }
                .onChange(of: timeIndex) { _ in
                    target.timeIndex = Int16(timeIndex)
                    PersistenceController.save(target: target, context: managedObjectContext)
                }
                .onReceive(timer) { _ in
                    Task {
                        notify = await vm.checkCurrentAuthorizationSetting()
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

