//
//  TargetApp.swift
//  Target
//
//  Created by Fadey Notchenko on 26.08.2022.
//

import SwiftUI

@main
struct TargetApp: App {
    
    @StateObject private var vm = ViewModel()
    
    private let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(vm)
                .onAppear(perform: UIApplication.shared.addTapGestureRecognizer)
                .onAppear {
                    Task {
                        await vm.fetchProducts()
                    }
                }
        }
    }
}

extension UIApplication {
    func addTapGestureRecognizer() {
        guard let window = windows.first else { return }
        let tapGesture = UITapGestureRecognizer(target: window, action: #selector(UIView.endEditing))
        tapGesture.requiresExclusiveTouchType = false
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        window.addGestureRecognizer(tapGesture)
    }
}

extension UIApplication: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

