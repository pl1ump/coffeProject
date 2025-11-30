import SwiftUI
import MapKit

struct MapSearchView<ViewModel: MapViewModelProtocol>: View {
    @StateObject private var viewModel: ViewModel
    
    @State private var adressInput: String = ""
    @State private var showFilters = false
    @State private var previousRadius: Int = 0
    @State private var showCoffeeList = false
    
    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack(alignment: .top) {

            MapView
            SearchBar
                
        }.mapSheetModifier(viewModel: viewModel,
                           showFilters: $showFilters,
                           showCoffeeList: $showCoffeeList,
                           previousRadius: $previousRadius)
        
    }
    
    private var MapView: some View {
        Map(
            coordinateRegion: $viewModel.region,
            showsUserLocation: true,
            annotationItems: viewModel.coffeeShops
        ) { shop in
            MapAnnotation(coordinate: shop.coordinate) {
                MapScreenView(
                    shop: shop,
                    isSelected: viewModel.selectedShop?.id == shop.id
                ) {
                    DispatchQueue.main.async {
                        viewModel.selectedShop = shop
                        showCoffeeList = true
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
    
    private var SearchBar: some View {
        SearchBarView(adressInput: $adressInput) {
            showFilters.toggle()
        } onSubmit: {
            Task {
                await viewModel.searchAddress(adressInput)
            }
        }
    }
    
    
    
}

#Preview {
    MapSearchView(viewModel: MapViewModel(service: YelpNetworkManager()))
}
