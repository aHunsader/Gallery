//
//  AboutViewController.swift
//  gallery
//
//  Created by Alex Hunsader on 4/14/18.
//  Copyright © 2018 Alex Hunsader. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var number: UILabel!
    @IBOutlet weak var creation: UILabel!
    @IBOutlet weak var modified: UILabel!
    
    var name_temp = ""
    var number_temp = ""
    var creation_temp = ""
    var modified_temp = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        name.text = name_temp
        number.text = number_temp
        creation.text = creation_temp
        modified.text = modified_temp
    }
}
