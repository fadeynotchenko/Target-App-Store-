//
//  ViewModel.swift
//  Target
//
//  Created by Fadey Notchenko on 26.08.2022.
//

import SwiftUI
import StoreKit

class ViewModel: ObservableObject {
    @Published var id: UUID?
    
    @Published var products: [Product] = []
    
    func fetchProducts() async {
        do {
            let products = try await Product.products(for: ["VN.Target.full-version-2"])
            DispatchQueue.main.async {
                self.products = products
            }
            
            if let product = products.first {
                await isPurchased(product: product)
            }
        } catch {
            print(error)
        }
    }
    
    func isPurchased(product: Product) async {
        guard let product = products.first else { return }
        
        let state = await product.currentEntitlement
        
        switch state {
        case .verified(let transaction):
            UserDefaults.standard.set(true, forKey: transaction.productID)
        case .unverified(_):
            break
        case .none:
            break
        }
        
    }
    
    func purchase() async {
        guard let product = products.first else { return }
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verify):
                switch verify {
                case .verified(let transaction):
                    UserDefaults.standard.set(true, forKey: transaction.productID)
                case .unverified(_):
                    break
                }
                
            case .userCancelled:
                break
            case .pending:
                break
            @unknown default:
                break
            }
        } catch {
            print(error)
        }
    }
}
