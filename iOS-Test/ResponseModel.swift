//
//  ResponseModel.swift
//  iOS-Test
//
//  Created by Renhard SehatQ on 07/10/21.
//

import Foundation

struct ResponseModel: Codable {
    let location: String
    let name: String
    let products: [ProductModel]
    
    enum CodingKeys: String, CodingKey {
        case location, name, products
    }
}
