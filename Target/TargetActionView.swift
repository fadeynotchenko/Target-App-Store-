//
//  Ta.swift
//  Target
//
//  Created by Fadey Notchenko on 28.08.2022.
//

import SwiftUI
import AnyFormatKitSwiftUI

struct TargetActionView: View {
    
    @Binding var showActionView: Bool
    @Binding var selection: Int
    var target: Target
    
    @State private var plusCurrent: NSNumber?
    @State private var minusCurrent: NSNumber?
    @State private var dateIsOn = false
    @State private var date = Date()
    @State private var comment = ""
    
    private let titles = ["Вычесть", "Добавить"]
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    FormatSumTextField(numberValue: selection == 0 ? $minusCurrent : $plusCurrent, placeholder: selection == 0 ? "Какую сумму достать из копилки?" : "Какую сумму положить в копилку?", numberFormatter: Constants.formatter())
                        .keyboardType(.numberPad)
                        .onChange(of: minusCurrent, perform: { _ in
                            if Int64(truncating: minusCurrent ?? 0) > target.current {
                                minusCurrent = target.current as NSNumber?
                            }
                        })
                        .onChange(of: plusCurrent, perform: { _ in
                            if Int64(truncating: plusCurrent ?? 0) > target.price - target.current {
                                plusCurrent = target.price - target.current as NSNumber?
                            }
                        })
                } footer: {
                    Text(selection == 0 ? "Максимум: \(target.current)" : "Максимум: \(target.price - target.current)")
                }
                
                Section {
                    TextField("Комментарий:", text: $comment)
                }
                
                Section {
                    Toggle("Дата", isOn: $dateIsOn)
                    
                    if dateIsOn {
                        DatePicker("", selection: $date, displayedComponents: .date)
                            .environment(\.locale, Locale.init(identifier: String(Locale.preferredLanguages[0].prefix(2))))
                            .datePickerStyle(.graphical)
                    }
                }
                
                
            }
            .navigationTitle(selection == 0 ? Text(titles[0]) : Text(titles[1]))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("close") {
                        showActionView.toggle()
                    }
                }
                
                ToolbarItem {
                    saveButton
                }
            }
        }
        .accentColor(.purple)
    }
    
    private var saveButton: some View {
        Button {
            showActionView = false
            
            let action = Action(context: managedObjectContext)
            action.date = date
            action.id = UUID()
            action.comment = comment
            
            if selection == 0 {
                let minus: Int64
                if Int64(truncating: minusCurrent ?? 0) > target.current {
                    minus = target.current
                } else {
                    minus = Int64(truncating: minusCurrent ?? 0)
                }
                
                action.value = -minus
                target.current -= minus
            } else {
                let plus: Int64
                if Int64(truncating: plusCurrent ?? 0) > target.price - target.current {
                    plus = target.price - target.current
                } else {
                    plus = Int64(truncating: plusCurrent ?? 0)
                }
                action.value = plus
                target.current += plus
            }
            
            target.addToAction(action)
            
            PersistenceController.save(target: target, context: managedObjectContext)
            
            
        } label: {
            Text("Сохранить")
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .disabled(selection == 0 && minusCurrent == nil ? true : false)
        .disabled(selection == 1 && plusCurrent == nil ? true : false)
    }
}
