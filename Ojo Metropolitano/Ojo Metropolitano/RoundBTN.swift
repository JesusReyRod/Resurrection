//
//  RoundBTN.swift
//  Fix My List 1.0
//
//  Created by Jesus Reynaga Rodriguez on 19/04/17.
//  Copyright © 2017 Silicon Bear. All rights reserved.
//

import UIKit

@IBDesignable
class RoundBTN: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 0{
        didSet{
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0{
        didSet{
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet{
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
}
