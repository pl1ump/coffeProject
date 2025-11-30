import Foundation
import SwiftUI
struct MapSheetModifier<ViewModel: MapViewModelProtocol>: ViewModifier {
    @ObservedObject var viewModel: ViewModel
    
    @Binding var showFilters: Bool
    @Binding var showCoffeList: Bool
    @Binding var previousRadius: Int
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $showFilters, onDismiss: handleFilterDismiss) {
                            FiltersView(searchRadius: $viewModel.searchRadius)
                                .presentationDetents([.medium])
                                .presentationDragIndicator(.visible)
                        }
                        .sheet(isPresented: $showCoffeList, onDismiss: handleCoffeeDismiss) {
                            ListSheetView(
                                viewModel: viewModel,
                                selectedShop: viewModel.selectedShop
                            )
                            .presentationDetents([.fraction(0.2), .medium, .large])
                            .presentationDragIndicator(.visible)
                        }
                        .alert(item: $viewModel.alertWrapper) { alert in
                            Alert(
                                title: Text(LocalizedStringKey(alert.title)),
                                message: Text(LocalizedStringKey(alert.message))
                            )
                        }
                        .onAppear {
                            previousRadius = viewModel.searchRadius
                            viewModel.requestLocationPermission()
                        }
                        .task {
                            if !viewModel.coffeeShops.isEmpty {
                                showCoffeList = true
                            }
                        }
            
        
    }
    
    private func handleFilterDismiss() {
            if viewModel.searchRadius != previousRadius {
                previousRadius = viewModel.searchRadius
                Task { await viewModel.loadCoffeeShops() }
            }
        }

        private func handleCoffeeDismiss() {
            withAnimation(.spring()) {
                viewModel.selectedShop = nil
            }
        }
}

extension View {
    func mapSheetModifier<ViewModel: MapViewModelProtocol>(
        viewModel: ViewModel,
        showFilters: Binding<Bool>,
        showCoffeeList: Binding<Bool>,
        previousRadius: Binding<Int>
    ) -> some View {
        self.modifier(
            MapSheetModifier(
                viewModel: viewModel,
                showFilters: showFilters,
                showCoffeList: showCoffeeList,
                previousRadius: previousRadius
            )
        )
    }
}
