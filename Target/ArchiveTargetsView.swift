//
//  ArchiveTargetsView.swift
//  Target
//
//  Created by Fadey Notchenko on 29.08.2022.
//

import SwiftUI

struct ArchiveTargetsView: View {
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "date", ascending: true)]) var targets: FetchedResults<Target>
    
    var body: some View {
        ZStack {
            List {
                ForEach(targets.filter({ $0.isFinished })) { target in
                    TargetRow(target: target)
                }
            }
            
            if targets.filter({ $0.isFinished }).isEmpty {
                Text("archiveempty")
            }
        }
        .listStyle(.automatic)
        .navigationTitle(Text("archive"))
    }
}
