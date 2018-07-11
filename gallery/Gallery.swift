//
//  Gallery.swift
//  gallery
//
//  Created by Alex Hunsader on 4/9/18.
//  Copyright © 2018 Alex Hunsader. All rights reserved.
//

import Foundation

class Gallery: Codable {
    var arr = [Image_url]()
    
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    init?(json: Data) {
        if let newValue = try? JSONDecoder().decode(Gallery.self, from: json) {
            arr = newValue.arr
        } else {
            return nil
        }
    }
    
    init() {
        arr = [Image_url]()
    }
}
