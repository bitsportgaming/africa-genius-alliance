//
//  ImpactMarketplaceView.swift
//  AGA
//
//  Created by AGA Team on 1/4/26.
//

import SwiftUI

// MARK: - Impact Product Model
struct ImpactProduct: Identifiable, Codable {
    let id: String
    let productId: String
    let title: String
    let description: String
    let price: Double
    let currency: String
    let category: String
    let sellerId: String
    let sellerName: String
    let imageURL: String?
    let impactDescription: String
    let soldCount: Int
    let inStock: Bool
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case productId, title, description, price, currency, category
        case sellerId, sellerName, imageURL, impactDescription, soldCount, inStock, createdAt
    }
}

struct ImpactMarketplaceView: View {
    @Environment(AuthService.self) private var authService

    @State private var products: [ImpactProduct] = []
    @State private var isLoading = true
    @State private var selectedCategory: String? = nil
    @State private var selectedProduct: ImpactProduct? = nil

    let categories = ["All", "Crafts", "Food", "Fashion", "Art", "Tech", "Services"]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0a4d3c").ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    headerSection

                    // Category Filter
                    categoryFilter

                    // Content
                    if isLoading {
                        loadingView
                    } else if products.isEmpty {
                        emptyStateView
                    } else {
                        productsGrid
                    }
                }
            }
            .navigationTitle("Impact Marketplace")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await loadProducts()
            }
            .sheet(item: $selectedProduct) { product in
                ProductDetailSheet(product: product)
                    .environment(authService)
            }
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("SUPPORT LOCAL GENIUSES")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(hex: "f59e0b"))
                .tracking(1)

            Text("Buy products that create real impact")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    // MARK: - Category Filter
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(categories, id: \.self) { category in
                    Button(action: {
                        HapticFeedback.selection()
                        selectedCategory = category == "All" ? nil : category.lowercased()
                        Task { await loadProducts() }
                    }) {
                        Text(category)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(isSelected(category) ? .black : .white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(isSelected(category) ? Color(hex: "f59e0b") : Color.white.opacity(0.15))
                            )
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 16)
    }

    private func isSelected(_ category: String) -> Bool {
        if category == "All" { return selectedCategory == nil }
        return selectedCategory == category.lowercased()
    }

    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            Spacer()
            ProgressView()
                .scaleEffect(1.2)
                .tint(Color(hex: "f59e0b"))
            Text("Loading products...")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))
            Spacer()
        }
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "bag.fill")
                .font(.system(size: 50))
                .foregroundColor(.white.opacity(0.3))
            Text("No products available")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            Text("Check back later for new impact products")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))
            Spacer()
        }
    }

    // MARK: - Products Grid
    private var productsGrid: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(products) { product in
                    ProductCard(product: product) {
                        selectedProduct = product
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
    }

    // MARK: - Load Products
    private func loadProducts() async {
        isLoading = true

        // Mock data for now - would connect to API
        products = [
            ImpactProduct(id: "1", productId: "prod1", title: "Handwoven Kente Cloth", description: "Traditional Ghanaian kente cloth made by local artisans", price: 150, currency: "USD", category: "crafts", sellerId: "seller1", sellerName: "Akua Textiles", imageURL: nil, impactDescription: "Supports 5 local weavers", soldCount: 45, inStock: true, createdAt: "2025-12-01"),
            ImpactProduct(id: "2", productId: "prod2", title: "Organic Shea Butter", description: "Pure unrefined shea butter from Northern Ghana", price: 25, currency: "USD", category: "food", sellerId: "seller2", sellerName: "Shea Cooperative", imageURL: nil, impactDescription: "Empowers women farmers", soldCount: 120, inStock: true, createdAt: "2025-12-01"),
            ImpactProduct(id: "3", productId: "prod3", title: "Ankara Fashion Set", description: "Modern African print clothing set", price: 85, currency: "USD", category: "fashion", sellerId: "seller3", sellerName: "AfroStyle", imageURL: nil, impactDescription: "Trains young designers", soldCount: 67, inStock: true, createdAt: "2025-12-01"),
            ImpactProduct(id: "4", productId: "prod4", title: "Beaded Jewelry Set", description: "Handcrafted beaded necklace and earrings", price: 45, currency: "USD", category: "crafts", sellerId: "seller4", sellerName: "Bead Masters", imageURL: nil, impactDescription: "Supports artisan families", soldCount: 89, inStock: true, createdAt: "2025-12-01")
        ]

        if let category = selectedCategory {
            products = products.filter { $0.category == category }
        }

        isLoading = false
    }
}

// MARK: - Product Card
struct ProductCard: View {
    let product: ImpactProduct
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 10) {
                // Image placeholder
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "f59e0b").opacity(0.2))
                    .frame(height: 120)
                    .overlay(
                        Image(systemName: categoryIcon)
                            .font(.system(size: 30))
                            .foregroundColor(Color(hex: "f59e0b"))
                    )

                // Title
                Text(product.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)

                // Price
                Text("$\(Int(product.price))")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "f59e0b"))

                // Seller
                Text("by \(product.sellerName)")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.5))
                    .lineLimit(1)

                // Impact badge
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 10))
                    Text(product.impactDescription)
                        .font(.system(size: 10))
                }
                .foregroundColor(.green)
                .lineLimit(1)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(0.08))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var categoryIcon: String {
        switch product.category.lowercased() {
        case "crafts": return "hands.sparkles.fill"
        case "food": return "leaf.fill"
        case "fashion": return "tshirt.fill"
        case "art": return "paintpalette.fill"
        case "tech": return "cpu"
        case "services": return "wrench.and.screwdriver.fill"
        default: return "bag.fill"
        }
    }
}

// MARK: - Product Detail Sheet
struct ProductDetailSheet: View {
    @Environment(AuthService.self) private var authService
    @Environment(\.dismiss) private var dismiss

    let product: ImpactProduct
    @State private var showDonation = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0a4d3c").ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Image
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(hex: "f59e0b").opacity(0.2))
                            .frame(height: 200)
                            .overlay(
                                Image(systemName: "bag.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(Color(hex: "f59e0b"))
                            )

                        // Info
                        VStack(alignment: .leading, spacing: 12) {
                            Text(product.category.capitalized)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color(hex: "f59e0b"))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color(hex: "f59e0b").opacity(0.2))
                                .cornerRadius(8)

                            Text(product.title)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)

                            Text("$\(Int(product.price))")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(Color(hex: "f59e0b"))

                            Text(product.description)
                                .font(.system(size: 15))
                                .foregroundColor(.white.opacity(0.8))

                            // Impact
                            HStack(spacing: 8) {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.green)
                                Text(product.impactDescription)
                                    .foregroundColor(.green)
                            }
                            .font(.system(size: 14, weight: .medium))
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(10)

                            // Seller
                            HStack {
                                Circle()
                                    .fill(Color(hex: "f59e0b").opacity(0.2))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Text(String(product.sellerName.prefix(1)))
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(Color(hex: "f59e0b"))
                                    )

                                VStack(alignment: .leading) {
                                    Text("Sold by")
                                        .font(.system(size: 11))
                                        .foregroundColor(.white.opacity(0.5))
                                    Text(product.sellerName)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }

                            // Stats
                            HStack {
                                Label("\(product.soldCount) sold", systemImage: "bag.fill")
                                Spacer()
                                Text(product.inStock ? "In Stock" : "Out of Stock")
                                    .foregroundColor(product.inStock ? .green : .red)
                            }
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        // Buy Button
                        Button(action: { showDonation = true }) {
                            HStack {
                                Image(systemName: "bag.fill")
                                Text("Purchase for $\(Int(product.price))")
                            }
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color(hex: "f59e0b"))
                            )
                        }
                        .disabled(!product.inStock)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Product Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
        }
        .sheet(isPresented: $showDonation) {
            DonationFlowView(
                recipientId: product.productId,
                recipientName: product.title,
                recipientType: "product",
                recipientImage: product.imageURL
            )
        }
    }
}

#Preview {
    ImpactMarketplaceView()
        .environment(AuthService.shared)
}
