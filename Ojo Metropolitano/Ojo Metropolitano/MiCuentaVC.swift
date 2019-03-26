//
//  MiCuentaVC.swift
//  Prueba 4
//
//  Created by Jesus Reynaga Rodriguez on 15/02/18.
//  Copyright © 2018 Silicon Bear. All rights reserved.
//

import UIKit
import RealmSwift

@available(iOS 10.0, *)
class MiCuentaVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
/*UIImagePickerControllerDelegate, UINavigationControllerDelegate*/
{

    @IBOutlet weak var user:     UILabel!              // variable para mostrar el nombre del usuario
    @IBOutlet weak var email:    UILabel!              // variable para mostrar el correo del usuario
    @IBOutlet weak var phone:    UILabel!              // variable para mostrar el teléfono del usuario
    @IBOutlet weak var nameComp: UILabel!              // variable para mostrar el nombre completo del usuario
    @IBOutlet weak var imagen:   UIImageView!          // variable para mostrar el el perfil del usuario
    let realm = try! Realm()                           // variable para global para la manipular la base de datos
    
    //******************** Main del View Controller ********************//
    override func viewDidLoad()
    {
        DispatchQueue.main.async
        {
            self.ConsultarUsuario()                    // consulta los datos del usuario
        }
        super.viewDidLoad()
    }
    
     //******************** Funación para consultar los datos del usuario ********************//
    func ConsultarUsuario()
    {
        let usuario = realm.objects(Usuario.self)
        for user in usuario
        {
            
            self.user.text     = user.nombreUsuario
            self.email.text    = user.correo
            self.phone.text    = user.celular
            self.nameComp.text = user.nombres + " " +
                                 user.apellidoPaterno + " " +
                                 user.apellidoMaterno;
        }
        self.imagen.layer.cornerRadius = self.imagen.frame.size.width/2
        self.imagen.clipsToBounds      = true
    }
    
    //******************** Cancela la vista de la galería ********************//
    /*func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        dismiss(animated: true, completion: nil)
    }
    
    //******************** Funación para mostrar la nueva imagen de perfil ********************//
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        let selectPhoto = info[UIImagePickerControllerOriginalImage] as! UIImage
        imagen.image = selectPhoto
        dismiss(animated: true, completion: nil)
    }*/
    
    //******************** Funación para abrir la galería ********************//
    @IBAction func photoGalery(_ sender: UITapGestureRecognizer)
    {
        /*let image = UIImagePickerController()
        image.sourceType = .photoLibrary
        image.delegate = self
        present(image, animated: true, completion: nil)*/
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let acctionSheet = UIAlertController(title: "Selecciona una opción", message: " ", preferredStyle: .actionSheet)
        
        acctionSheet.addAction(UIAlertAction(title: "Cámara", style: .default, handler : {(action: UIAlertAction) in
            DispatchQueue.main.async
            {
                if UIImagePickerController.isSourceTypeAvailable(.camera)
                {
                    imagePickerController.sourceType = .camera
                    self.present(imagePickerController, animated: true, completion: nil)
                }
                else
                {
                    self.createAlert(tittle: "¡Error!", message: "No se puede acceder a la cámara")
                }
            }
        }))
        
        acctionSheet.addAction(UIAlertAction(title: "Galería", style: .default, handler : {(action: UIAlertAction) in
            DispatchQueue.main.async
            {
                imagePickerController.sourceType = .photoLibrary
                self.present(imagePickerController, animated: true, completion: nil)
            }
        }))
        
        acctionSheet.addAction(UIAlertAction(title: "ver foto", style: .default, handler : {(action: UIAlertAction) in
            DispatchQueue.main.async
            {
                let mainTabController = self.storyboard?.instantiateViewController(withIdentifier: "WatchImageVC") as! WatchImageVC
                mainTabController.ads_catch = (self.imagen.image)!
                self.present(mainTabController, animated: true, completion: nil)
                
            }
        }))
        
        acctionSheet.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler : nil))
        self.present(acctionSheet, animated: true, completion: nil)
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        DispatchQueue.main.async
        {
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
            self.imagen.image = image
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func createAlert(tittle:String, message:String)
    {
        let alert = UIAlertController(title: tittle, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //******************** Solo una plantilla de una alerta ********************//
    func createAlertTipoError(tittle:String, message:String)
    {
        let alert = UIAlertController(title: tittle, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default, handler: { (action) in
            self.CerrarSesion()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func CerrarSesion()
    {
        try! realm.write {
            realm.deleteAll()
        }
        let mainTabController = storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        present(mainTabController, animated: true, completion: nil)
    }
    
    //******************** Finaliza la sesión ********************//
    @IBAction func CerrarSesion(_ sender: Any)
    {
        createAlertTipoError(tittle: user.text! + ": ¿Estás seguro de eliminar?", message: "¡Al aceptar se borrarán toda información del dispositivo!")
    }

}
