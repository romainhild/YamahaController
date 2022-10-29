//
//  Icon.swift
//  YamahaController
//
//  Created by Romain Hild on 20/08/2022.
//

import Foundation

struct Icon: Hashable {
    var width: Int
    var height: Int
    var mimetype: String
    var name: String
    var path: String
    var url: URL?
    var size: Int {
        width*height
    }
    
    init(width: Int, height: Int, mimetype: String, path: String) {
        self.width = width
        self.height = height
        self.mimetype = mimetype
        self.name = path.components(separatedBy: "/").last!
        self.path = path
    }
    
    static func less(lhs: Icon, rhs: Icon) -> Bool {
        return lhs.size < rhs.size || (lhs.size == rhs.size && lhs.mimetype == "image/png")
    }
}
