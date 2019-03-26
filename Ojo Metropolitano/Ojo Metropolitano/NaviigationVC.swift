//
//  NaviigationVC.swift
//  Ojo Metropolitano
//
//  Created by Jesus Reynaga Rodriguez on 15/03/18.
//  Copyright © 2018 Silicon Bear. All rights reserved.
//

import UIKit

class NaviigationVC: UINavigationController {

    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
    }
}
