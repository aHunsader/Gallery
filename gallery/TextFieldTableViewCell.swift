//
//  TextFieldTableViewCell.swift
//  gallery
//
//  Created by Alex Hunsader on 4/10/18.
//  Copyright © 2018 Alex Hunsader. All rights reserved.
//

import UIKit

class TextFieldTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    var resignation_handler: (() -> Void)?
    
    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.delegate = self;
        }
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        resignation_handler?()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
