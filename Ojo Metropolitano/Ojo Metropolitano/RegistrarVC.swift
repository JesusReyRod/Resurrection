//
//  RegistrarVC.swift
//  Prueba 4
//
//  Created by Jesus Reynaga Rodriguez on 04/02/18.
//  Copyright © 2018 Silicon Bear. All rights reserved.
//

import UIKit

class RegistrarVC: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    @IBAction func cancelarRegistro(_ sender: Any)
    {
        dismiss(animated: true, completion: nil)
    }

}
