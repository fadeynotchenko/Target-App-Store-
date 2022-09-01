//
//  TargetRow.swift
//  Target
//
//  Created by Fadey Notchenko on 30.08.2022.
//

import SwiftUI

struct TargetRow: View {
    
    @ObservedObject var target: Target
    
    @State private var percent: CGFloat = 0
    @State private var txtPercent = 0
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject var vm: ViewModel
    
    var body: some View {
        label
    }
    
    private var label: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(target.name ?? "")
                .bold()
                .font(.title3)
            
            capsuleProgress
            
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
    
    private func calculatePercent(price: Int64, current: Int64) {
        guard price != 0 else { return }
        
        txtPercent = min(Int(current * 100 / price), 100)
        
        withAnimation(.easeInOut(duration: 1.0)) {
            percent = min(CGFloat(current * 100 / price), 100.0)
        }
    }
}
