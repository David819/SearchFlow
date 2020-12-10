//
//  ContentView.swift
//  SearchFlow
//
//  Created by David on 12/10/20.
//

import SwiftUI

struct ContentView: View {
    
    @State var textToSearch = ""
    @State var isSearching = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                
                SearchBar(textToSearch: $textToSearch, isSearching: $isSearching)
                
                ForEach (requestDataWith(text: textToSearch)) { oneGroup in
                    Section(header:
                                Text(oneGroup.type.rawValue)
                                    .frame(width: 400, height: 40, alignment: .leading)
                                    .font(.title)
                                    .foregroundColor(Color(.systemGray))) {
                                Spacer()
                        ForEach(oneGroup.products) { product in
                            HStack {
                                VStack (alignment: .leading) {
                                    Text("\(product.name)")
                                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                                    Spacer()
                                    Text(product.inStock ? "in-stock" : "out-of-stock" )
                                        .font(.body)
                                        .foregroundColor(Color(.systemGray))
                                }
                                Spacer()
                                Text("$\(product.price.description)")
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 10)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                    .foregroundColor(product.inStock ? Color(.systemBlue) : Color(.systemGray))
                            }
                            .padding()
                            Divider()
                                .background(Color(.systemGray6))
                                .padding(.leading)
                        }
                    }
                }
                if textToSearch != "" && requestDataWith(text: textToSearch).count == 0 {
                    Text("No result")
                        .foregroundColor(Color(.systemGray))
                        .padding(.top, 40)
                }
            }
            .navigationTitle("Search")
        }
    }
}

extension ContentView: DataAPI {}

struct SearchBar: View {
    
    @Binding var textToSearch: String
    @Binding var isSearching: Bool
    
    var body: some View {
        HStack {
            TextField("Tap here to search", text: $textToSearch)
                .padding(.leading, 25)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(5)
        .padding(.horizontal)
        .onTapGesture(perform: {
            isSearching = true
        })
        .overlay(
            HStack {
                Image(systemName: "magnifyingglass")
                Spacer()
                if isSearching == true {
                    Button(action: { textToSearch = ""}, label: {
                        Image(systemName: "xmark")
                            .padding(.vertical)
                    })
                }
            }
            .padding(.horizontal, 30)
            .foregroundColor(Color(.systemGray2))
        )
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


