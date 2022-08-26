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
    
    @State private var name = ""
    @State private var price: NSNumber?
    @State private var current: NSNumber?
    @State private var valueIndex = 0
    @State private var colorIndex = 0
    @State private var addReplenishment = false
    @State private var addNotifications = false
    @State private var timeIndex = 0
    @State private var replenishment: NSNumber?
    
    private var region: String {
        String(Locale.preferredLanguages[0].prefix(2))
    }
    
    private var value: Value {
        Constants.valueArray[Int(valueIndex)]
    }
    
    var body: some View {
        NavigationView {
            Form {
                nameSection
                
                priceSection
                
                addReplenishmentSection
                
                LazyColorHStack(tagIndex: $colorIndex)
            }
            .navigationTitle(Text("new"))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("close") {
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
            TextField("namehint", text: $name)
                .onChange(of: name) { _ in
                    if name.count > 20 {
                        name = String(name.prefix(20))
                    }
                }
        }
    }
    
    private var priceSection: some View {
        Section {
            Picker("value", selection: $valueIndex) {
                ForEach(0..<Constants.valueArray.count, id: \.self) { i in
                    Text(Constants.valueArray[i].rawValue)
                }
                .onAppear {
                    if region != "ru" {
                        valueIndex = 1
                    }
                }
            }
            
            FormatSumTextField(numberValue: $price, placeholder: region == "ru" ? "Цена в \(value.symbol)" : "Price in \(value.symbol)", numberFormatter: Constants.formatter(value: value))
                .keyboardType(.numberPad)
                .onChange(of: price, perform: { _ in
                    if Int(truncating: price ?? 0) > Constants.MAX {
                        price = Constants.MAX as NSNumber?
                    }
                })
            
            FormatSumTextField(numberValue: $current, placeholder: region == "ru" ? "Уже накоплено (Необязательно)" : "Already accumulated (Optional)", numberFormatter: Constants.formatter(value: value))
                .keyboardType(.numberPad)
                .onChange(of: current, perform: { _ in
                    if Int(truncating: current ?? 0) > Int(truncating: price ?? 0) {
                        current = price
                    }
                })
            
        }
    }
    
    private var addGoalButton: some View {
        Section {
            Button("add") {
                showNewTargetView.toggle()
                
                let target = Target(context: managedObjectContext)
                target.id = UUID()
                target.name = name
                target.price = price as! Int64
                target.current = Int64(truncating: current ?? 0)
                target.colorIndex = Int16(colorIndex)
                target.valueIndex = Int16(valueIndex)
                target.date = Date()
                
                if let replenishment = replenishment {
                    target.replenishment = Int64(truncating: replenishment)
                    target.timeIndex = Int16(timeIndex)
                    
                    let dateComponents = Constants.globalFunc.nextRep(selection: timeIndex)
                    target.dateNext = Calendar.current.date(from: dateComponents)
                }
                
                PersistenceController.save(target: target, context: managedObjectContext)
            }
            .disabled(name.isEmpty)
            .disabled(price == nil)
        }
    }
    
    private var addReplenishmentSection: some View {
        Section {
            NavigationLink {
                addReplenishmentView
            } label: {
                VStack(alignment: .leading) {
                    Text("replenishment")
                    
                    HStack(spacing: 5) {
                        if addReplenishment {
                            Text("once a")
                                .foregroundColor(.gray)
                        }
                        
                        Text(addReplenishment ? Constants.timeEnumArray[timeIndex].key : "never")
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
                    Text("addrep")
                }
                .onChange(of: addReplenishment) { toggle in
                    if toggle {
                        //NotificationHandler.requestPermission()
                    }
                }
            }
            
            if addReplenishment {
                Section {
                    Picker("", selection: $timeIndex) {
                        ForEach(0..<Constants.timeEnumArray.count, id: \.self) { i in
                            Text(Constants.timeEnumArray[i].key)
                        }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("in")
                }
                
                Section {
                    FormatSumTextField(numberValue: $replenishment, placeholder: "Число в \(value.symbol)", numberFormatter: Constants.formatter(value: value))
                        .keyboardType(.numberPad)
                } header: {
                    Text("sum")
                }
                
            }
        }
        .navigationTitle(Text("replenishment"))
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
        } header: {
            Text("tags")
        }
    }
}

struct Previews_NewTargetView_Previews: PreviewProvider {
    static var previews: some View {
        NewTargetView(showNewTargetView: .constant(true))
    }
}
