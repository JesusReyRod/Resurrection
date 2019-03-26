//
//  DetallesVC.swift
//  Medical Care
//
//  Created by Jesus Reynaga Rodriguez on 27/05/18.
//  Copyright © 2018 Jesus Reynaga Rodriguez. All rights reserved.
//

import UIKit
import RealmSwift

class DetallesVC: UIViewController, UITableViewDataSource, UITableViewDelegate
{

    @IBOutlet weak var nombre: UILabel!
    @IBOutlet weak var publicidad: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var rows: Int = 0
    var nombre_catch:String = ""
    var publicidad_catch = UIImage()
    let realm = try! Realm()
    
   /* struct Amigos {
        var nomUser: String
    }*/
    var amigosDetele: [String] = []
    
    struct Contactos {
        var imagen = UIImage()
        var nomUser: String
    }
    var my_Contactos: [Contactos] = []
    
    override func viewDidLoad()
    {
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.cargarDato()
        self.getFriendsYTeams()
        super.viewDidLoad()
        //self.tableView.reloadData()
        //self.setupLongPressGesture()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(tapContactos))
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        self.my_Contactos.removeAll()
        print("Saliendo")
    }
    
    func getFriendsYTeams()
    {
        let friends = self.realm.objects(Respuesta.self)
        
        for grupos in (friends.first?.grupos)!
        {
            if grupos.nombreGrupo == nombre_catch
            {
                print(grupos.nombreGrupo)
                for miembros in grupos.miembros
                {
                    self.my_Contactos.append(Contactos(imagen: UIImage.init(named: "rostro2")!, nomUser: miembros))
                    self.tableView.reloadData()
                    print(miembros)
                }
            }
        }
    }
    
    @objc func tapContactos(_ sender: UIBarButtonItem)
    {
        let alert = UIAlertController(title: "Confirmación", message: "¿Estás seguro de eliminar?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default, handler: { (action) in
            /*let parameters      = ["nombreUsuario": nomUser, "nombreGrupo": self.nombre_catch, "listaAmigos": self.amigosDetele, "tokenSiliconBear": tokenSB, "ubicacionUsuario": userLocation] as [String : Any]
            print(parameters)*/
            self.PeticionDeleteDeGrupo(nombreGrupo: self.nombre_catch)
        }))
        self.present(alert, animated: true, completion: nil)
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
                self.navigationItem.rightBarButtonItem?.isEnabled = false
            }
        }
        else
        {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
            self.navigationItem.rightBarButtonItem?.isEnabled = true
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if (editingStyle == .delete)
        {
            let alert = UIAlertController(title: "Confirmación", message: "¿Estás seguro de eliminar?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
                
            }))
            
            alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default, handler: { (action) in
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func cargarDato()
    {
        self.nombre.text  = nombre_catch
        self.publicidad.image = publicidad_catch
    }
    
    func AgregarInstacias()
    {

        self.my_Contactos.append(Contactos(imagen: UIImage.init(named: "rostro1")!,
                                           nomUser: "Delta"))
        self.my_Contactos.append(Contactos(imagen: UIImage.init(named: "rostro2")!,
                                           nomUser: "Hilter"))
        self.my_Contactos.append(Contactos(imagen: UIImage.init(named: "rostro3")!,
                                           nomUser: "Kronos"))
        self.my_Contactos.append(Contactos(imagen: UIImage.init(named: "rostro4")!,
                                           nomUser: "Paulina"))
    }
    
    @IBAction func showImage(_ sender: UITapGestureRecognizer)
    {
        let mainTabController = storyboard?.instantiateViewController(withIdentifier: "WatchImageVC") as! WatchImageVC
        mainTabController.ads_catch = (self.publicidad.image)!
        self.present(mainTabController, animated: true, completion: nil)
    }
    
    func PeticionDeleteDeGrupo(nombreGrupo: String)
    {
        DispatchQueue.main.async
        {
            let parameters      = ["nombreUsuario": nomUser, "nombreGrupo": self.nombre_catch, "listaAmigos": self.amigosDetele, "tokenSiliconBear": tokenSB, "ubicacionUsuario": userLocation] as [String : Any]  // variable para el cuerpo de la petición
                guard let url       = URL(string: URLPeticion + ":3030/Modular/API/contactos/BorrarAmigosDeGrupo") else { return }       // URL a quien se hace la petición
                var request         = URLRequest(url: url)                                                                      // No supe bien xD
                request.httpMethod  = "POST"                                                                                    // Selección del tipo de método
                request.addValue(   "application/json", forHTTPHeaderField: "Content-Type")                                     // aplica un formato especial para el cuerpo
                guard let httpBody  = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }      // conversión de parámetros a JSON
                request.httpBody    = httpBody                                                                                  // envío de parámetros
                self.JSONDeleteDeGrupo(request: request)                                                                             // Respuesta de cliente HTTP
        }
    }
    
    func JSONDeleteDeGrupo(request:URLRequest)
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
    
    @IBAction func addFriends(_ sender: UIButton)
    {
        let mainTabController = storyboard?.instantiateViewController(withIdentifier: "AgregarAmigosVC") as! AgregarAmigosVC
        mainTabController.nombre_catch = (self.nombre_catch)
        present(mainTabController, animated: true, completion: nil)
    }
    
}
