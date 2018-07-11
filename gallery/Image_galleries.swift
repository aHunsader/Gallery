//
//  image_galleries.swift
//  gallery
//
//  Created by Alex Hunsader on 4/9/18.
//  Copyright © 2018 Alex Hunsader. All rights reserved.


import Foundation

class Image_galleries {
    static var untitled = 0
    private var galleries = [Int:Gallery]()
    private var filenames: [String] {
        didSet {
            print(filenames)
            UserDefaults.standard.set(filenames, forKey: "filenames")
        }
    }
    private var ids: [Int] {
        didSet {
            print(ids)
            UserDefaults.standard.set(galleries, forKey: "ids")
        }
    }
    private var alive: [Bool] {
        didSet {
            print(alive)
            UserDefaults.standard.set(alive, forKey: "alive")
        }
    }
    
    init() {
        let defaults = UserDefaults.standard
        if let names = defaults.array(forKey: "filenames") as? [String] {
            filenames = names
        } else {
            filenames = [String]()
            defaults.set([String](), forKey: "filenames")
        }
        
        if let living = defaults.array(forKey: "alive") as? [Bool] {
            alive = living
        } else {
            alive = [Bool]()
            defaults.set([Bool](), forKey: "alive")
        }
        
        if let identifiers = defaults.array(forKey: "ids") as? [Int] {
            ids = identifiers
        } else {
            ids = [Int]()
            defaults.set([Int](), forKey: "ids")
        }
        
        Image_galleries.untitled = count + 1
    }
    
    var count: Int {
        return filenames.count
    }
    var dead: Int {
        var count = 0
        for a in alive {
            if !a { count += 1 }
        }
        return count
    }
    func get_gallery(name:String) -> Gallery {
        if get_id(name) == nil {
            let x = Image_galleries.u()
            galleries[x] = Gallery()
            Image_galleries.inc()
            filenames.append("Untitled \(x)")
            ids.append(x)
            alive.append(true)
            Image_galleries.save(id: x, gallery: galleries[x]!)
            return galleries[x]!
        }
        else if galleries[get_id(name)!] != nil {
            return galleries[get_id(name)!]!
        }
        if let url = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("\(get_id(name)!).json") {
            if let jsonData = try? Data(contentsOf: url) {
                return Gallery(json: jsonData) ?? Gallery()
            }
        }
        return Gallery()
    }
    func get_gallery_num(name: String) -> Int {
        var i = 0
        for file in filenames {
            if file == name {
                return i
            }
            i += 1
        }
        return 0
    }
    func set_gallery(name: String, images: [Image_url]){
        if let id = get_id(name) {
            galleries[id] = Gallery()
            galleries[id]?.arr = images
        }
    }
    func change_name(old: String, new: String, index: Int) {
        filenames[index] = new
    }
    func get_alive_at(_ num: Int) -> Bool {
        return alive[num]
    }
    func set_alive_at(_ num: Int, _ living: Bool) {
        alive[num] = living
    }
    
    func get_dead(num: Int) -> String {
        var count = -1
        for i in 0..<alive.count {
            if !alive[i] { count += 1 }
            if count == num { return filenames[i] }
        }
        return ""
    }
    func get_alive(num: Int) -> String {
        var count = -1
        for i in 0..<alive.count {
            if alive[i] { count += 1 }
            if count == num { return filenames[i] }
        }
        return ""
    }
    func get_index(indexPath: IndexPath) -> Int{
        var count = -1
        for i in 0..<alive.count {
            if alive[i], indexPath.section == 0 { count += 1 }
            if !alive[i], indexPath.section == 1 { count += 1 }
            if count == indexPath.row { return i }
        }
        return 0
    }
    
    func get_id(_ filename: String) -> Int? {
        for i in 0..<filenames.count {
            if filenames[i] == filename {
                return ids[i]
            }
        }
        return nil
    }
    
    func get_name(_ id: Int) -> String {
        for i in 0..<ids.count {
            if ids[i] == id { return filenames[i]; }
        }
        return ""
    }
    
    static func save(id: Int, gallery: Gallery) {
        if let json = gallery.json {
            if let url = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("\(id).json") {
                do {
                    try json.write(to: url)
                } catch let error {
                    print(error)
                }
            }
        }
    }
    
    static func inc() {
        untitled += 1
    }
    static func u() -> Int {
        return untitled
    }

}

