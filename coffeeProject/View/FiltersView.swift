import SwiftUI

struct FiltersView: View {
    @Binding var searchRadius: Int
    
    var body: some View {
        VStack(spacing: 20) {
            Text(LocalizedStringKey("Search Radius"))
                .font(.title2.bold())
            
            Slider(value: Binding(
                get: { Double(searchRadius) },
                set: { searchRadius = Int($0) }
            ), in: 200...4000, step: 100)
            
            Text(String(format: NSLocalizedString("%d meters", comment: ""), searchRadius))
                .font(.headline)
            
            
            Button(LocalizedStringKey("Apply")) {
                
            }
            Spacer()
        }
        .padding()
    }
}

struct FiltersView_Previews: PreviewProvider {
    @State static var radius = 1000
    
    static var previews: some View {
        FiltersView(searchRadius: $radius)
    }
}
