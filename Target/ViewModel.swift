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
    @Published var purchased: [String] = []
    
    func fetchProducts() async {
        do {
            let products = try await Product.products(for: ["VN.Target.fullversion"])
            self.products = products
            
            if let product = products.first {
                await isPurchased(product: product)
            }
        } catch {
            print(error)
        }
    }
    
    func isPurchased(product: Product) async {
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
    
    func getPermissionState() async throws -> Bool {
        var ans = false
        let current = UNUserNotificationCenter.current()
        
        let result = await current.notificationSettings()
        switch result.authorizationStatus {
        case .notDetermined:
            break
        case .denied:
            ans = false
        case .authorized:
            ans = true
        case .provisional:
            ans = true
        case .ephemeral:
            break
        @unknown default:
            break
        }
        
        return ans
    }
}
