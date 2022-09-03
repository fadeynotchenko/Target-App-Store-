//
//  TargetActionHistoryView.swift
//  Target
//
//  Created by Fadey Notchenko on 03.09.2022.
//

import SwiftUI

struct TargetActionHistoryView: View {
    
    let target: Target
    @Binding var showActionHistoryView: Bool
    
    @State private var sortSelection = 0
    
    private var actionArray: [Action] {
        switch sortSelection {
        case 1: return target.actionArrayByMaxValue
        case 2: return target.actionArrayByMinValue
        case 3: return target.actionArrayByComment
        default:
            return target.actionArrayByDate
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(actionArray) { action in
                    actionRow(action: action)
                }
            }
            .listStyle(.plain)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    menu
                }
                
                ToolbarItemGroup(placement: .principal) {
                    VStack {
                        Text(target.name ?? "")
                            .font(.headline)
                        
                        Text("История операций")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
    
    var menu: some View {
        Menu("Сортировать") {
            Picker("", selection: $sortSelection) {
                Text("по Дате").tag(0)
                Text("по Убыванию").tag(1)
                Text("по Возрастанию").tag(2)
                Text("по Длине комментария").tag(3)
            }
        }
    }
    
    @ViewBuilder
    private func actionRow(action: Action) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 5) {
                if action.value < 0 {
                    Image(systemName: "arrow.down")
                        .foregroundColor(.red)
                } else {
                    Image(systemName: "arrow.up")
                        .foregroundColor(.green)
                }
                
                Text(action.value < 0 ? "\(action.value) \(Constants.valueArray[Int(target.valueIndex)].symbol)" : "+\(action.value) \(Constants.valueArray[Int(target.valueIndex)].symbol)")
                    .bold()
                    .font(.title3)
                    .foregroundColor(action.value < 0 ? .red : .green)
                
                Spacer()
                
                Text(action.date ?? Date(), format: .dateTime.day().month().year())
                    .foregroundColor(.gray)
            }
            
            if let comment = action.comment, !comment.isEmpty {
                Text(comment)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }
}

