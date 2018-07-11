//
//  Image_url.swift
//  gallery
//
//  Created by Alex Hunsader on 4/9/18.
//  Copyright © 2018 Alex Hunsader. All rights reserved.
//

import Foundation

struct Image_url: Codable {
    var url: URL
    var width: Double = 0.0
    var height: Double = 0.0
}
