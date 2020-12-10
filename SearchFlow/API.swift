//
//  API.swift
//  SearchFlow
//
//  Created by David on 12/10/20.
//

import Foundation

enum ProductType: String {
    case VC = "Vacuum"
    case HD = "Hair Dryer"
}

struct Product: Identifiable {
    var id = UUID()
    var brand: String
    var name: String
    var type: ProductType
    var inStock: Bool
    var price: Decimal
}

struct GroupedProduct: Identifiable {
    var id = UUID()
    var name: String
    var products: [Product]
}

class API {
    static let sharedAPI = API()
    func requestDataWith(text: String) -> [GroupedProduct] {
        if text == "Dyson" {
            let one = [Product(brand: "Dyson", name: "V11", type: .VC, inStock: true, price: 599.99),
                    Product(brand: "Dyson", name: "V10", type: .VC, inStock: false, price: 399.99)]
            let two = [Product(brand: "Dyson", name: "Supersonic", type: .HD, inStock: true, price: 399.99)]
            return [GroupedProduct(name: "Vacuum", products: one), GroupedProduct(name: "Hair Dryer", products: two)]
        } else {
            return []
        }
    }
    
    
}
    

