import SwiftUI

struct ListSheetView<ViewModel: MapViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    let selectedShop: Business?
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 16) {
                    Spacer().frame(height: 16)
                    ForEach(sortedShops) { shop in
                        VStack(alignment: .leading, spacing: 8) {
                            
                            Text(shop.name)
                                .font(.headline)
                            
                            
                            if let url = shop.imageUrl, let imageURL = URL(string: url) {
                                AsyncImage(url: imageURL) { phase in
                                    switch phase {
                                    case .success(let img):
                                        img.resizable().scaledToFill()
                                    default:
                                        Color.gray.opacity(0.2)
                                    }
                                }
                                .frame(height: 150)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            
                            
                            if let distance = shop.distance {
                                Text(String(format: NSLocalizedString("%0.f m away", comment: ""), distance))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            
                            if let rating = shop.rating {
                                HStack {
                                    ForEach(0..<Int(rating), id: \.self) { _ in
                                        Image(systemName: "star.fill").foregroundColor(.yellow)
                                    }
                                    Text(String(format: NSLocalizedString("Rating %.1f", comment: ""), rating))
                                        .font(.subheadline)
                                    
                                    if let reviews = shop.reviewCount {
                                                Text("(\(reviews))")
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                            }
                                }
                            }
                            
                            Divider()
                        }
                        .padding(.horizontal)
                        .id(shop.id)
                        .onTapGesture {
                            viewModel.selectedShop = shop
                        }
                    }
                    .refreshable {
                            await viewModel.loadCoffeeShops()
                        }
                }
                .padding(.top, 8)
            }
            .onChange(of: viewModel.selectedShop) { shop in
                if let shop = shop {
                    withAnimation(.easeInOut) {
                        proxy.scrollTo(shop.id, anchor: .top)
                    }
                }
            }
        }
    }
    
    
    private var sortedShops: [Business] {
        guard let selected = selectedShop else { return viewModel.coffeeShops }
        return [selected] + viewModel.coffeeShops.filter { $0.id != selected.id }
    }
}

#Preview {
    ListSheetView(viewModel: MapViewModel(service: YelpNetworkManager()), selectedShop: .preview)
}
