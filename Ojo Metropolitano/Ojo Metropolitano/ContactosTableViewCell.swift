//
//  ContactosTableViewCell.swift
//  Ojo Metropolitano
//
//  Created by Jesus Reynaga Rodriguez on 14/05/18.
//  Copyright © 2018 Silicon Bear. All rights reserved.
//

import UIKit

class ContactosTableViewCell: UITableViewCell
{

    @IBOutlet weak var imagen: UIImageView!
    @IBOutlet weak var usuario: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imagen.layer.cornerRadius = self.imagen.frame.size.width/2
        self.imagen.clipsToBounds = true
    }
        
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
