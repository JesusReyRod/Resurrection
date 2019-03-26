//
//  AgregarAmigosVC.swift
//  OjoMetropolitano
//
//  Created by Jesus Reynaga Rodriguez on 15/06/18.
//  Copyright © 2018 Silicon Bear. All rights reserved.
//

import UIKit
import RealmSwift

class AgregarAmigosVC: UIViewController, UITableViewDataSource, UITableViewDelegate
{

    @IBOutlet weak var viewPopup: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var ok: UIButton!
    var rows: Int = 0
    var amigosDetele: [String] = []
    let realm = try! Realm()
    var nombre_catch:String = ""
    
    struct Contactos {
        var imagen = UIImage()
        var nomUser: String
    }
    var my_Contactos: [Contactos] = []
    
    override func viewDidLoad()
    {
        DispatchQueue.main.async
        {
            self.viewPopup.layer.cornerRadius   = 10                // aplica bordes curvos
            self.tableView.delegate             = self              // muestra el mapa en el popup
            self.tableView.dataSource           = self
            self.AgregarInstacias()
        }
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        self.ok?.isEnabled = false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return my_Contactos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactosTableViewCell", for: indexPath) as! ContactosTableViewCell
        cell.imagen.image = my_Contactos[indexPath.row].imagen
        cell.usuario.text = my_Contactos[indexPath.row].nomUser
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCellAccessoryType.checkmark
        {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
            rows = rows - 1
            let found: String = self.my_Contactos[indexPath.row].nomUser
            print(found)
            amigosDetele = amigosDetele.filter{$0 != found}
            print("********************")
            printArray()
            print("********************")
            if rows == 0
            {
                self.ok?.isEnabled = false
            }
        }
        else
        {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
            self.ok?.isEnabled = true
            rows = rows + 1
            amigosDetele.append(self.my_Contactos[indexPath.row].nomUser)
            print("________________________")
            printArray()
            print("________________________")
        }
    }
    
    func printArray()
    {
        for e in amigosDetele{
            print(e)
        }
    }
    
    func AgregarInstacias()
    {
        
        /*self.my_Contactos.append(Contactos(imagen: UIImage.init(named: "rostro1")!,
                                           nomUser: "Delta"))
        self.my_Contactos.append(Contactos(imagen: UIImage.init(named: "rostro2")!,
                                           nomUser: "Hilter"))
        self.my_Contactos.append(Contactos(imagen: UIImage.init(named: "rostro3")!,
                                           nomUser: "Kronos"))
        self.my_Contactos.append(Contactos(imagen: UIImage.init(named: "rostro4")!,
                                           nomUser: "Paulina"))*/
        
        let friends = self.realm.objects(Respuesta.self)
        for contactos in (friends.first?.amigos)!
        {
            self.my_Contactos.append(Contactos(imagen: UIImage.init(named: "rostro1")!, nomUser: contactos))
            print(contactos)
            self.tableView.reloadData()
        }
    }
    
    func PeticionAddToGrupo(nombreGrupo: String)
    {
        DispatchQueue.main.async
            {
                let parameters      = ["nombreUsuario": nomUser, "nombreGrupo": self.nombre_catch, "listaAmigos": self.amigosDetele, "tokenSiliconBear": tokenSB, "ubicacionUsuario": userLocation] as [String : Any]  // variable para el cuerpo de la petición
                guard let url       = URL(string: URLPeticion + ":3030/Modular/API/contactos/AgregarAmigosAGrupo") else { return }       // URL a quien se hace la petición
                var request         = URLRequest(url: url)                                                                      // No supe bien xD
                request.httpMethod  = "POST"                                                                                    // Selección del tipo de método
                request.addValue(   "application/json", forHTTPHeaderField: "Content-Type")                                     // aplica un formato especial para el cuerpo
                guard let httpBody  = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }      // conversión de parámetros a JSON
                request.httpBody    = httpBody                                                                                  // envío de parámetros
                self.JSONAddToGrupo(request: request)                                                                             // Respuesta de cliente HTTP
        }
    }
    
    func JSONAddToGrupo(request:URLRequest)
    {
        let seccion = URLSession.shared
        seccion.dataTask(with: request)
        {   (data, response, error) in
            guard let data  = data else { return }
            do
            {
                guard let json  = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else { return }
                let respuesta     = RespuestaDeleteFriend(value: json)
                DispatchQueue.main.async                                                                // Hilo para comprobar que se realizó bien la petición
                    {
                        if respuesta.codigoRespuesta == 200                                                // Para el caso correcto
                        {
                            let alert = UIAlertController(title: "¡Correcto!", message: respuesta.mensaje, preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
                                alert.dismiss(animated: true, completion: nil)
                            }))
                            self.present(alert, animated: true, completion: nil)
                        }
                        else{
                            let alert = UIAlertController(title: "¡Upps!", message: respuesta.mensaje, preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
                                alert.dismiss(animated: true, completion: nil)
                            }))
                            self.present(alert, animated: true, completion: nil)
                        }
                }
            }
            catch let jsonErr
            {
                print("Error de serialización json:", jsonErr)
            }
            }.resume()
    }
    
    override func didReceiveMemoryWarning()
    {
        
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func cancelar(_ sender: UIButton)
    {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func aceptar(_ sender: UIButton)
    {
        let alert = UIAlertController(title: "Confirmación", message: "¿Estás seguro de eliminar?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default, handler: { (action) in
            self.PeticionAddToGrupo(nombreGrupo: self.nombre_catch)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
