//
//  ContentView.swift
//  SearchFlow
//
//  Created by David on 12/10/20.
//

import SwiftUI
import Combine

let inputBackgroundColor = Color(.sRGB, red: 235/255, green: 235/255, blue: 235/255, opacity: 1)
let listBackgroundColor = Color(.sRGB, red: 247/255, green: 247/255, blue: 247/255, opacity: 1)


class ResultViewModel: ObservableObject {
    
    private let networkService = ProductService()
    
    @Published var textToSearch = ""
    @Published var groupProductViewModels = [GroupProductViewModel]()
     
    var lastSearch: String = ""
    
    var cancellable: AnyCancellable?

    func fetchDataLocal() {
        guard textToSearch.replacingOccurrences(of: " ", with: "") != "" else {
            return
        }
        guard self.textToSearch != lastSearch else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.groupProductViewModels = (self?.networkService.fetchLocal(text: self?.textToSearch).data.map { GroupProductViewModel($0) }) ?? []
            self?.lastSearch = self?.textToSearch ?? ""
        }
    }
    
    func fetchDataOnline() {
        guard textToSearch.replacingOccurrences(of: " ", with: "") != "" else {
            return
        }
        guard self.textToSearch != lastSearch else {
            return
        }
        cancellable = networkService.fetch(text: textToSearch).sink(receiveCompletion: { (rc) in
            print("receive completion")
            print(rc)
        }, receiveValue: { (dc) in
            self.groupProductViewModels = dc.data.map { GroupProductViewModel($0) }
            print(self.groupProductViewModels)
            self.lastSearch = self.textToSearch
        })
    }

}

struct ContentView: View {

    @ObservedObject private var viewModel = ResultViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                HStack {
                    SearchBar(resultViewModel: viewModel)
                    .padding()
                }
                ForEach (viewModel.groupProductViewModels) { groupViewModel in
                    ProductGroupView(groupViewModel: groupViewModel)
                }

                if viewModel.textToSearch != "" && viewModel.groupProductViewModels.count == 0 {
                    Text("No result")
                        .foregroundColor(Color(.systemGray))
                        .padding(.top, 40)
                }
            }
            .background(listBackgroundColor)
            .navigationTitle("Search")
        }
    }
    
}



struct SearchBar: View {
    
    @ObservedObject var resultViewModel: ResultViewModel
    @State var isSearching = false
    
    var body: some View {
        HStack {
            TextField("Tap here to search", text: $resultViewModel.textToSearch, onEditingChanged: { (value) in
                
            }, onCommit: {
                // keyboard tap 'return'
                if resultViewModel.textToSearch.replacingOccurrences(of: " ", with: "") == "" {
                    DispatchQueue.main.async {
                        isSearching = false
                    }
//                    isSearching = false
                }
            })
            .onReceive(resultViewModel.textToSearch.publisher.collect()) {
                // textfield text change to fetch
                _ = $0.map(String.init).joined()
                resultViewModel.fetchDataLocal()
//                resultViewModel.fetchDataOnline()
            }
            // can also use 'publisher.reduce' to get text
                .padding(.leading, 35)
        }
        .padding(.vertical, 10)
        .background(inputBackgroundColor)
        .cornerRadius(10)
        .onTapGesture(perform: {
            isSearching = true
        })
        .overlay(
            HStack {
                Image(systemName: "magnifyingglass")
                Spacer()
                if isSearching == true {
                    Button(action: {
                        DispatchQueue.main.async {
                            resultViewModel.textToSearch = ""
                            resultViewModel.groupProductViewModels = []
                        }
                    }, label: {
                        Image(systemName: "xmark")
                            .padding(.vertical)
                    })
                }
            }
            .padding(.horizontal, 10)
            .foregroundColor(Color(.systemGray2))
        )
    }
}

// GroupProducView
struct GroupProductViewModel: Identifiable {
    
    private let oneGroup: GroupedProduct
    
    var id: String {
        return oneGroup.id
    }

    var type: ProductType {
        return oneGroup.type
    }
    
    var productViewModels: [ProductViewModel] {
        return oneGroup.products.map { ProductViewModel(oneProduct: $0) }
    }
    
    init(_ oneGroup: GroupedProduct) {
        self.oneGroup = oneGroup
    }
}

struct ProductGroupView: View {
    var groupViewModel: GroupProductViewModel
    var body: some View {
        Section(header:
                    Text(groupViewModel.type.rawValue)
                        .frame(width: 400, height: 30, alignment: .leading)
                        .font(.title3)
                        .background(listBackgroundColor)
                        .foregroundColor(Color(.systemGray))) {
                    Spacer()
            ForEach(groupViewModel.productViewModels) { productViewModel in
                ProductCellView(viewModel: productViewModel)
            }
        }
    }
}

// ProductCellView
struct ProductViewModel: Identifiable {
    private let oneProduct: Product
    init(oneProduct: Product) {
        self.oneProduct = oneProduct
    }

    var id: String {
        return oneProduct.id
    }

    var brand: String {
        return oneProduct.brand
    }

    var name: String {
        return oneProduct.name
    }

    var type: ProductType {
        return oneProduct.type
    }

    var inStock: Bool {
        return oneProduct.inStock
    }

    var formattedPrice: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency

        guard let price = Double(oneProduct.price), let formattedPrice = numberFormatter.string(from: NSNumber(value: price)) else {
            return ""
        }
        return formattedPrice
    }
    
    var priceColor: Color {
        return oneProduct.inStock ? Color(.systemBlue) : Color(.systemGray)
    }
}

struct ProductCellView: View {
    var viewModel: ProductViewModel
    
    var body: some View {
        VStack {
            Spacer(minLength: 15)
            HStack {
                VStack (alignment: .leading) {
                    Text("\(viewModel.name)")
                        .font(.title2)
                    Spacer()
                    Text(viewModel.inStock ? "in-stock" : "out-of-stock" )
                        .font(.body)
                        .foregroundColor(Color(.systemGray))
                }
                Spacer()
                Text(viewModel.formattedPrice)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 10)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .foregroundColor(viewModel.priceColor)
            }
            .padding(.horizontal)
            .contentShape(Rectangle())
            .onTapGesture {
                print("did select cell")
            }
            Spacer(minLength: 15)
            Divider()
        }
        .background(Color.white)

    }
}

struct CellDiveder: View {
    var body: some View {
        GeometryReader { gor in
            Rectangle().fill(listBackgroundColor)
                .frame(width: gor.size.width, height: 1)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
        .previewDevice("iPhone 12 Pro Max")
    }
}


