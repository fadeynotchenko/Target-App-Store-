//
//  ViewModel.swift
//  Target
//
//  Created by Fadey Notchenko on 26.08.2022.
//

import SwiftUI
import StoreKit

@MainActor
class StoreViewModel: ObservableObject{
    @Published var id: UUID?
    
    @Published var products: [Product] = []
    @Published var purchased: [String] = []
    
    func fetchProducts() async {
        do {
            let products = try await Product.products(for: ["com.temporary.VN.Target"])
            self.products = products
            
            await isPurchased()
        } catch {
            print(error)
        }
    }
    
    func isPurchased() async {
        guard let product = products.first else { return }
        
        guard let state = await product.currentEntitlement else { return }
        
        switch state {
        case .verified(let transaction):
            purchased.append(transaction.productID)
        case .unverified:
            break
        }
        
    }
    
    func purchase() async -> Bool{
        guard let product = products.first else { return false }
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verify):
                switch verify {
                case .verified(let transaction):
                    purchased.append(transaction.productID)
                    return true
                case .unverified:
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
        
        return false
    }
    
    func restore() async -> Bool {
        ((try? await AppStore.sync()) != nil)
    }
}
