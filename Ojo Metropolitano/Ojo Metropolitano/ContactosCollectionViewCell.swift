//
//  ContactosCollectionViewCell.swift
//  Ojo Metropolitano
//
//  Created by Jesus Reynaga Rodriguez on 14/05/18.
//  Copyright © 2018 Silicon Bear. All rights reserved.
//

import UIKit

class ContactosCollectionViewCell: UICollectionViewCell
{
    @IBOutlet weak var imgImagen: UIImageView!
    @IBOutlet weak var etiqueta: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.etiqueta.numberOfLines = 1
        self.etiqueta.minimumScaleFactor = 0.5
        self.etiqueta.adjustsFontSizeToFitWidth = true
        self.etiqueta.lineBreakMode = .byWordWrapping
    }
}
