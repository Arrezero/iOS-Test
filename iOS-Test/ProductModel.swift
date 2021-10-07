//
//  ProductModel.swift
//  iOS-Test
//
//  Created by Renhard SehatQ on 07/10/21.
//

import Foundation

struct ProductModel: Codable {
    let category: String
    let name: String
    let price: Int
    
    enum CodingKeys: String, CodingKey {
        case category, name, price
    }
}

struct ProductByCategory {
    let category: String
    var products: [ProductModel]
}
