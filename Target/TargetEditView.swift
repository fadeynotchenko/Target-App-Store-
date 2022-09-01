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
    
    @State private var backToMainView = false
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.presentationMode) var present
    
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
                        FormatSumTextField(numberValue: $newPrice, placeholder: "newprice", numberFormatter: Constants.formatter())
                            .keyboardType(.numberPad)
                            .onAppear {
                                newPrice = (target.price) as NSNumber
                            }
                    }
                    
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
                            Text("delete")
                                .foregroundColor(.red)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle(Text("edit"))
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $backToMainView) {
                ContentView()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("close") {
                        showEditView.toggle()
                    }
                }
                
                ToolbarItem {
                    Button {
                        showEditView.toggle()
                        target.name = newName
                        target.price = Int64(truncating: newPrice ?? 0)
                        target.colorIndex = Int16(newTagIndex)
                        
                        PersistenceController.save(target: target, context: managedObjectContext)
                        
                        
                    } label: {
                        Text("save")
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .disabled(newName.isEmpty || newPrice == nil)
                }
            }
        }
    }
    
}

