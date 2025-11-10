import SwiftUI
import MapKit

struct MapSearchView<ViewModel: MapViewModelProtocol>: View {
    @StateObject private var viewModel: ViewModel
    
    @State private var addressInput: String = ""
    @State private var showFilters = false
    @State private var previousRadius: Int = 0
    @State private var showCoffeeList = false
    
    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            
            Map(
                coordinateRegion: $viewModel.region,
                showsUserLocation: true,
                annotationItems: viewModel.coffeeShops
            ) { shop in
                MapAnnotation(coordinate: shop.coordinate) {
                    
                    MapScreenView(shop: shop,
                                  isSelected: viewModel.selectedShop?.id == shop.id) {
                        DispatchQueue.main.async {
                            viewModel.selectedShop = shop
                            showCoffeeList = true
                        }
                    }
                }
            }
            .ignoresSafeArea()
            
            
            VStack {
                HStack {
                    TextField(LocalizedStringKey("Enter office address…"), text: $addressInput)
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
        .sheet(isPresented: $showFilters, onDismiss: {
            if viewModel.searchRadius != previousRadius {
                previousRadius = viewModel.searchRadius
                Task { await viewModel.loadCoffeeShops() }
            }
        }) {
            FiltersView(searchRadius: $viewModel.searchRadius)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            Task {
                previousRadius = viewModel.searchRadius
                viewModel.requestLocationPermission()
            }
        }
        .task {
            if !viewModel.coffeeShops.isEmpty {
                showCoffeeList = true
            }
        }
        
        .sheet(isPresented: $showCoffeeList, onDismiss: {
            withAnimation(.spring()){
                viewModel.selectedShop = nil
            }
            
        }) {
            ListSheetView(
                viewModel: viewModel,
                selectedShop: viewModel.selectedShop
            )
            .presentationDetents([.fraction(0.2), .medium, .large])
            .presentationDragIndicator(.visible)
        }
        .alert(item: $viewModel.alertWrapper) { alert in
            Alert(title: Text(LocalizedStringKey(alert.title)),
                  message: Text(LocalizedStringKey(alert.message)))
        }
    }
}


#Preview {
    MapSearchView(viewModel: MapViewModel(service: YelpNetworkManager()))
}
