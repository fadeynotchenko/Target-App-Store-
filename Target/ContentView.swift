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
    
    @State private var id: UUID?
    
    @EnvironmentObject var vm: ViewModel
    
    var body: some View {
            NavigationView {
                ZStack {
                    List {
                        archiveButton
                        
                        ForEach(targets.filter({ $0.isFinished == false })) { target in
                            TargetRow(target: target)
                                .swipeActions {
                                    deleteButton(target)
                                }
                            
                        }
                    }
                    
                    if targets.filter({ $0.isFinished == false }).isEmpty {
                        Text("empty")
                    }
                }
                .listStyle(.automatic)
                .navigationTitle(Text("appname"))
                .sheet(isPresented: $showNewTargetView) {
                    NewTargetView(showNewTargetView: $showNewTargetView)
                }
                .toolbar {
                    ToolbarItem {
                        showNewTargetViewButton
                    }
                }
                
                Text("placeholder")
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
            ArchiveTargetsView()
        } label: {
            Label {
                HStack(spacing: 5) {
                    Text("archive")
                        .bold()
                    
                    Text("(\(targets.filter( { $0.isFinished }).count))")
                        .bold()
                }
            } icon: {
                Image(systemName: "archivebox.fill")
            }
            .font(.title3)
            .foregroundColor(.gray)
            .padding(.vertical)
        }
    }
    
    private func deleteButton(_ target: Target) -> some View {
        Button(role: .destructive) {
            withAnimation {
                PersistenceController.deleteTarget(target: target, context: viewContext)
            }
        } label: {
            Image(systemName: "trash")
        }
    }
}

struct TargetRow: View {
    
    @ObservedObject var target: Target
    
    @State private var percent: CGFloat = 0
    @State private var txtPercent = 0
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject var vm: ViewModel
    
    var body: some View {
        if Constants.IDIOM == .pad {
            NavigationLink(tag: target.id ?? UUID(), selection: $vm.id) {
                TargetDetailView(target: target)
            } label: {
                label
            }
        } else {
            NavigationLink {
                TargetDetailView(target: target)
            } label: {
                label
            }
        }
    }
    
    private var label: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(target.name ?? "")
                .bold()
                .font(.title3)
            
            if target.isFinished {
                capsuleFinish
            } else {
                capsuleProgress
            }
            
            Text("\(target.current) / \(target.price) \(Constants.valueArray[Int(target.valueIndex)].symbol)")
                .bold()
                .foregroundColor(.gray)
            
        }
        .padding(.vertical)
        .padding(.horizontal, Constants.IDIOM == .pad ? 10 : 0)
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
    
    private var capsuleFinish: some View {
        ZStack(alignment: .leading) {
            
            ZStack(alignment: .trailing) {
                HStack {
                    Capsule()
                        .fill(.gray.opacity(0.1))
                        .frame(width: Constants.IDIOM == .pad ? 150 : 200, height: 12)
                    
                    Text("100 %")
                        .foregroundColor(.gray)
                        .bold()
                }
            }
            
            Capsule()
                .fill(LinearGradient(colors: [.purple, Constants.colorArray[Int(target.colorIndex)]], startPoint: .leading, endPoint: .trailing))
                .frame(width: (Constants.IDIOM == .pad ? 150 : 200), height: 12)
        }
    }
    
    private func calculatePercent(price: Int64, current: Int64) {
        guard price != 0 else { return }
        
        txtPercent = min(Int(current * 100 / price), 100)
        
        withAnimation(.easeInOut(duration: 1.0)) {
            percent = min(CGFloat(current * 100 / price), 100.0)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(ViewModel())
            .colorScheme(.dark)
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
    
    @ViewBuilder
    func currentNavigationStyle() -> some View {
        if Constants.IDIOM == .pad {
            self.navigationViewStyle(.automatic)
        } else {
            self.navigationViewStyle(.stack)
        }
    }
}

extension UINavigationController {
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        navigationBar.topItem?.backButtonDisplayMode = .minimal
    }
}
