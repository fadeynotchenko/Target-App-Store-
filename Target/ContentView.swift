//
//  ContentView.swift
//  Target
//
//  Created by Fadey Notchenko on 26.08.2022.
//

import SwiftUI
import StoreKit
import Lottie

struct ContentView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "date", ascending: true)]) private var targets: FetchedResults<Target>
    
    @State private var showNewTargetView = false
    @State private var showProVersionView = false
    
    @State private var id: UUID?
    
    @AppStorage("VN.Target.fullversion") private var fullVersion = false
    
    @EnvironmentObject private var storeVM: StoreViewModel
    
    @State private var adViewControllerRepresentable = AdViewControllerRepresentable()
    @State private var adCoordinator = AdCoordinator()
    
    var body: some View {
        GeometryReader { reader in
            NavigationView {
                ZStack {
                    List {
                        //archiveButton
                        
                        targetList
                    }
                }
                .listStyle(.plain)
                .accentColor(Color(UIColor.systemGroupedBackground))
                .navigationTitle(Text("appname"))
                .sheet(isPresented: $showNewTargetView) {
                    NewTargetView(showNewTargetView: $showNewTargetView)
                }
                .sheet(isPresented: $showProVersionView) {
                    ProVersion(showProVersionView: $showProVersionView, showNewTargetView: $showNewTargetView)
                }
                .toolbar {
                    ToolbarItem {
                        showNewTargetViewButton
                    }
                    
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("PRO") {
                            showProVersionView.toggle()
                        }
                    }
                }
                .onAppear {
                    if storeVM.purchased.isEmpty {
                        adCoordinator.loadAd()
                    }
                }
                
                Text("placeholder")
            }
            .currentNavigationStyle(width: reader.size.width)
        }
    }
    
    @ViewBuilder
    private var targetList: some View {
        if Constants.IDIOM == .pad {
            ForEach(targets.filter({ $0.isFinished == false })) { target in
                NavigationLink(tag: target.id ?? UUID(), selection: $storeVM.id) {
                    TargetDetailView(adViewControllerRepresentable: $adViewControllerRepresentable, adCoordinator: $adCoordinator, target: target)
                } label: {
                    TargetRow(target: target)
                }
                .swipeActions {
                    deleteButton(target)
                }
            }
        } else {
            ForEach(targets.filter({ $0.isFinished == false })) { target in
                NavigationLink {
                    TargetDetailView(adViewControllerRepresentable: $adViewControllerRepresentable, adCoordinator: $adCoordinator, target: target)
                } label: {
                    TargetRow(target: target)
                }
                .swipeActions {
                    deleteButton(target)
                }
            }
        }
    }
    
    private var showNewTargetViewButton: some View {
        Button {
            if targets.filter( { $0.isFinished == false }).count > 0 && storeVM.purchased.isEmpty {
                showProVersionView = true
            } else {
                showNewTargetView = true
            }
        } label: {
            Image(systemName: "plus")
        }
    }
    
//    private var archiveButton: some View {
//        NavigationLink {
//            ArchiveTargetsView()
//        } label: {
//            Label {
//                HStack(spacing: 5) {
//                    Text("Архив")
//                        .bold()
//
//                    Text("(\(targets.filter( { $0.isFinished }).count))")
//                        .bold()
//                }
//            } icon: {
//                Image(systemName: "archivebox.fill")
//            }
//            .font(.title3)
//            .foregroundColor(.gray)
//            .padding(.vertical)
//        }
//    }
    
    private func deleteButton(_ target: Target) -> some View {
        Button(role: .destructive) {
            NotificationHandler.deleteNotification(by: target.id?.uuidString ?? UUID().uuidString)
            
            withAnimation {
                PersistenceController.deleteTarget(target: target, context: viewContext)
            }
        } label: {
            Image(systemName: "trash")
        }
    }
}

struct ProVersion: View {
    
    @Binding var showProVersionView: Bool
    @Binding var showNewTargetView: Bool
    
    @EnvironmentObject private var storeVM: StoreViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "star.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .foregroundColor(.yellow)
                
                
                Text("pro1")
                    .bold()
                    .font(.headline)
                    .padding()
                    .multilineTextAlignment(.center)
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("pro2")
                        .bold()
                    
                    Text("pro3")
                        .bold()
                }
                .padding(.horizontal)
                
                Spacer()
                
                Button {
                    Task {
                        let bool = await storeVM.purchase()
                        
                        if bool {
                            dismiss()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                showNewTargetView = true
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 5) {
                        Text(storeVM.purchased.isEmpty ? "buy" : "purchased")
                            .bold()
                        
                        if let product = storeVM.products.first {
                            Text(product.displayPrice)
                                .bold()
                        }
                    }
                }
                .padding()
                .background(Color("Color"))
                .cornerRadius(15)
                .disabled(!storeVM.purchased.isEmpty)
                
                Button("restore") {
                    Task {
                        let _ = await storeVM.restore()
                    }
                }
                
                Text("pro4")
                    .padding()
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
            }
            .navigationTitle(Text("protitle"))
            .toolbar {
                ToolbarItem {
                    Button("close") {
                        showProVersionView = false
                    }
                }
            }
        }
    }
}

extension View {
    @ViewBuilder
    func currentNavigationStyle(width: CGFloat) -> some View {
        if Constants.IDIOM == .pad && width > 400 {
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

