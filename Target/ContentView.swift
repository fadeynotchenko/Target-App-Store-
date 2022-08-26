//
//  ContentView.swift
//  Target
//
//  Created by Fadey Notchenko on 26.08.2022.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "date", ascending: true)]) var targets: FetchedResults<Target>
    
    @State private var showNewTargetView = false
    
    var body: some View {
        GeometryReader { reader in
            NavigationView {
                List {
                    archiveButton
                    
                    ForEach(targets) { target in
                        TargetRow(target: target, reader: reader)
                            .swipeActions {
                                deleteButton(target)
                            }
                    }
                }
                .currentListStyle()
                .navigationTitle(Text("Моя Копилка"))
                .sheet(isPresented: $showNewTargetView) {
                    NewTargetView(showNewTargetView: $showNewTargetView)
                }
                .toolbar {
                    ToolbarItem {
                        showNewTargetViewButton
                    }
                }
            }
        }
    }
    
    private var showNewTargetViewButton: some View {
        Button {
            showNewTargetView = true
        } label: {
            Image(systemName: "plus")
        }
    }
    
    private var archiveButton: some View {
        NavigationLink {
            //archive
        } label: {
            Label {
                Text("Архив (\(targets.filter( { $0.isFinished }).count))")
                    .bold()
                    .foregroundColor(.gray)
            } icon: {
                Image(systemName: "archivebox.fill")
                    .foregroundColor(.gray)
            }
            .font(.title3)
            .padding(.vertical)
        }
    }
    
    private func deleteButton(_ target: Target) -> some View {
        Button(role: .destructive) {
            withAnimation(.linear) {
                PersistenceController.deleteTarget(target: target, context: viewContext)
            }
        } label: {
            Image(systemName: "trash")
        }
    }
}

struct TargetRow: View {
    
    var target: Target
    var reader: GeometryProxy
    
    @State private var percent: CGFloat = 0
    @State private var txtPercent = 0
    
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var vm: ViewModel
    
    var body: some View {
        //vm selection need only for iPad
        if Constants.IDIOM == .pad {
            NavigationLink(tag: target.id ?? UUID(), selection: $vm.id) {
                TargetDetailView(target: target, selected: $vm.id)
            } label: {
                targetBodyLabel
            }
        } else {
            NavigationLink {
                TargetDetailView(target: target, selected: $vm.id)
            } label: {
                targetBodyLabel
            }
        }
    }
    
    private var targetBodyLabel: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(target.name ?? "")
                .bold()
                .font(.title3)
            
            capsuleProgress
            
            Text("\(target.current) / \(target.price) \(Constants.valueArray[Int(target.valueIndex)].symbol)")
                .foregroundColor(.gray)
                .bold()
            
        }
        .padding(.vertical)
    }
    
    private var capsuleProgress: some View {
        ZStack(alignment: .leading) {
            
            ZStack(alignment: .trailing) {
                HStack {
                    Capsule()
                        .fill(.gray.opacity(0.1))
                        .frame(width: Constants.IDIOM == .pad ? 150 : 200, height: 12)
                    
                    Text("\(txtPercent) %")
                        .foregroundColor(.gray)
                        .bold()
                }
            }
            
            Capsule()
                .fill(LinearGradient(colors: [.purple, Constants.colorArray[Int(target.colorIndex)]], startPoint: .leading, endPoint: .trailing))
                .frame(width: percent / 100 * (Constants.IDIOM == .pad ? 150 : 200), height: 12)
        }
        .onAppear {
            calculatePercent(price: target.price, current: target.current)
        }
        .onChange(of: target.current) { new in
            calculatePercent(price: target.price, current: new)
        }
        .onChange(of: target.price) { new in
            calculatePercent(price: new, current: target.current)
        }
    }
    
    private func calculatePercent(price: Int64, current: Int64) {
        guard price != 0 else { return }
        
        txtPercent = min(Int(current * 100 / price), 100)
        
        withAnimation(.linear(duration: 1.0)) {
            percent = min(CGFloat(current * 100 / price), 100.0)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(ViewModel())
    }
}

//need for fix slide row effect
extension View {
    @ViewBuilder
    func currentListStyle() -> some View {
        if Constants.IDIOM == .pad {
            self.listStyle(.automatic)
        } else {
            self.listStyle(.sidebar)
        }
    }
}
