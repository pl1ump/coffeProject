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
                    
                    
                    VStack(spacing: 4) {
                        Text(shop.name)
                            .font(.caption2)
                            .padding(4)
                            .background(Color(.systemBackground).opacity(0.9))
                            .cornerRadius(6)
                        
                        Image(systemName: viewModel.selectedShop?.id == shop.id ? "mappin.circle" : "mappin.circle.fill")
                            .font(viewModel.selectedShop?.id == shop.id ? .system(size: 35) : .title2)
                            .foregroundColor(viewModel.selectedShop?.id == shop.id ? .red : .brown)
                            .scaleEffect(viewModel.selectedShop?.id == shop.id ? 1.3 : 1.0)
                            .animation(.spring(), value: viewModel.selectedShop?.id == shop.id)
                            .onTapGesture {
                                DispatchQueue.main.async {
                                    viewModel.selectedShop = shop
                                    showCoffeeList = true
                                }
                            }
                    }
                }
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
        .sheet(isPresented: $showFilters, onDismiss: {
            if viewModel.searchRadius != previousRadius {
                previousRadius = viewModel.searchRadius
                Task { await viewModel.loadCoffeeShops() }
            }
        }) {
            FiltersView(searchRadius: $viewModel.searchRadius)
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
            Alert(title: Text(alert.title), message: Text(alert.message))
        }
    }
}


#Preview {
    MapSearchView(viewModel: MapViewModel(service: YelpNetworkManager()))
}
