import SwiftUI
import MapKit

struct MapSearchView: View {
    @StateObject private var viewModel: MapViewModel
    
    @State private var addressInput: String = ""
    @State private var showFilters = false
    
    init() {
        _viewModel = StateObject(wrappedValue: MapViewModel(service: YelpNetworkManager()))
    }
    
    var body: some View {
        ZStack(alignment: .top) {
           
            Map(coordinateRegion: $viewModel.region,
                annotationItems: viewModel.coffeeShops) { shop in
                MapMarker(coordinate: shop.coordinate, tint: .brown)
            }
            .ignoresSafeArea()
            
           
            VStack {
                HStack {
                    TextField("Enter office address…", text: $addressInput)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 4)
                        .onSubmit {
                            Task { await viewModel.searchAddress(addressInput) }
                        }
                    
                    Button(action: {
                        showFilters.toggle()
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
        .sheet(isPresented: $showFilters) {
            FiltersView(searchRadius: $viewModel.searchRadius)
        }
        .onAppear {
            viewModel.requestLocationPermission()
        }
        .alert(item: $viewModel.alertWrapper) { alert in
            Alert(title: Text(alert.title), message: Text(alert.message))
        }
    }
}


#Preview {
    MapSearchView()
}
