import SwiftUI
import MapKit

struct MapScreenView: View {
    let shop: Business
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 4) {
            Text(shop.name)
                .font(.caption2)
                .padding(4)
                .background(Color(.systemBackground).opacity(0.9))
                .cornerRadius(6)
            
            Image(systemName: isSelected ? "mappin.circle" : "mappin.circle.fill")
                .font(isSelected ? .system(size: 35) : .title2)
                .foregroundColor(isSelected ? .red : .brown)
                .scaleEffect(isSelected ? 1.3 : 1.0)
                .animation(.spring(), value: isSelected)
                .onTapGesture {
                    onTap()
                }
        }
    }
}


