//
//  SearchBarView.swift
//  coffeeProject
//
//  Created by Vladick  on 11/11/2025.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var adressInput: String
    let onFilterTap: () -> Void
    let onSubmit: () -> Void
    var body: some View {
        VStack {
            HStack {
                TextField(LocalizedStringKey("Enter office address…"), text: $adressInput)
                    .onChange(of: adressInput) { _, newValue in
                        adressInput = newValue
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                            .replacingOccurrences(of: "  ", with: " ")
                            .prefix(60)
                            .description
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 4)
                    .onSubmit {
                        onSubmit()
                    }
                
                Button(action: {
                    onFilterTap()
                }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.title2)
                            .padding(8)
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(radius: 4)
                    }
            }
            .padding()
            
            Spacer()
        }
    }
}

