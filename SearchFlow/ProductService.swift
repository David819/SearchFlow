//
//  NetworkService.swift
//  SearchFlow
//
//  Created by David on 12/11/20.
//

import Foundation
import Combine

final class ProductService {
    
    var componentsTest: URLComponents {
        // local nginx
        var components = URLComponents()
        components.scheme = "http"
        components.host = "10.0.1.147"
        components.port = 8976
        components.path = "/searchflow/"

        return components
    }
    
    var componentsOnline: URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "sidt.ai"
        components.port = 8602
        components.path = "/test/searchflow"

        return components
    }
    
    func request(text: String) -> URLRequest {
        var request = URLRequest(url: componentsTest.url!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5)
        request.httpMethod = "POST"
        let dict = ["searchText": text]
        let d = try! JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed)
        request.httpBody = d
        return request
    }
    
    func fetch(text: String) -> AnyPublisher<DataContainer, Error> {
        return URLSession.shared.dataTaskPublisher(for: request(text: text))
            .map{ $0.data }
            .decode(type: DataContainer.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchLocal(text: String?) -> DataContainer {
        guard let t = text, t.lowercased() == "dyson" else { return DataContainer(status: "succed", data: [])}
        let str = "{\"status\": \"succed\", \"data\": [{\"ID\": \"234234\", \"productType\": \"Vacuum\", \"products\": [{\"ID\": \"489458\", \"brand\": \"Dyson\", \"name\": \"V11\", \"productType\": \"Vacuum\", \"inStock\": true, \"price\": \"599.99\"}, {\"ID\": \"334567\", \"brand\": \"Dyson\", \"name\": \"V10\", \"productType\": \"Vacuum\", \"inStock\": false, \"price\": \"399.99\"}]}, {\"ID\": \"234233\", \"productType\": \"Hair Dryer\", \"products\": [{\"ID\": \"898765\", \"brand\": \"Dyson\", \"name\": \"Supersonic\", \"productType\": \"Hair Dryer\", \"inStock\": true, \"price\": \"399.99\"}]}]}"
        let data = str.data(using: .utf8)!
        let dc = try! JSONDecoder().decode(DataContainer.self, from: data)
        return dc
    }
}

struct DataContainer: Decodable {
    let status: String
    let data: [GroupedProduct]
}

enum ProductType: String, Codable{
    case UN = "Unknow"
    case VC = "Vacuum"
    case HD = "Hair Dryer"
}

struct Product: Identifiable, Decodable {
    var id: String
    var brand: String
    var name: String
    var type: ProductType
    var inStock: Bool
    var price: String
    
    private enum CodingKeys: String, CodingKey {
        case id = "ID"
        case brand = "brand"
        case name = "name"
        case type = "productType"
        case inStock = "inStock"
        case price = "price"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? "0"
        brand = try container.decodeIfPresent(String.self, forKey: .brand) ?? "unknow brand"
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? "unknow name"
        type = try container.decodeIfPresent(ProductType.self, forKey: .type) ?? ProductType.UN
        inStock = try container.decodeIfPresent(Bool.self, forKey: .inStock) ?? false
        price = try container.decodeIfPresent(String.self, forKey: .price) ?? "0.00"
    }
}

struct GroupedProduct: Identifiable, Decodable {
    var id: String
    var type: ProductType
    var products: [Product]
    
    private enum CodingKeys: String, CodingKey {
        case id = "ID"
        case type = "productType"
        case products = "products"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? "0"
        type = try container.decodeIfPresent(ProductType.self, forKey: .type) ?? ProductType.UN
        products = try container.decodeIfPresent([Product].self, forKey: .products) ?? []
    }
}
