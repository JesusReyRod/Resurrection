//
//  MisContactosVC.swift
//  Ojo Metropolitano
//
//  Created by Jesus Reynaga Rodriguez on 14/05/18.
//  Copyright © 2018 Silicon Bear. All rights reserved.
//

import UIKit
import RealmSwift

class MisContactosVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource
{
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableSearch: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    let realm = try! Realm()
    
    struct Grupos
    {
        var imageGrupo = UIImage()
        var nombreGrupo: String
    }
    var my_Grupos: [Grupos] = []
    
    struct Contactos
    {
        var imagen = UIImage()
        var nomUser: String
    }
    var my_Contactos: [Contactos] = []
    var userFound: [Contactos] = []
    var amigosDetele: [String] = []
    
    override func viewDidLoad()
    {
        DispatchQueue.main.async
        {
            self.tableView.dataSource = self
            self.tableView.delegate = self
            self.tableSearch.delegate = self
            self.tableSearch.dataSource = self
            self.searchBar.delegate = self
            self.collectionView.dataSource = self
            self.collectionView.delegate = self
            
        }
        super.viewDidLoad()
        self.getFriendsYTeams()
        self.my_Grupos.append(Grupos(imageGrupo: UIImage.init(named: "plus-2")!,
                                     nombreGrupo: ""))
        
        self.collectionView.reloadData()
       
        let longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(longPressGR:)))
        longPressGR.minimumPressDuration = 0.5
        longPressGR.delaysTouchesBegan = true
        self.collectionView.addGestureRecognizer(longPressGR)
        self.setupLongPressGesture()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView.reloadData()
        self.tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    @objc func handleLongPress(longPressGR: UILongPressGestureRecognizer)
    {
        let point = longPressGR.location(in: self.collectionView)
        let indexPath = self.collectionView.indexPathForItem(at: point)
        
        if let indexPath = indexPath
        {
            if(indexPath.row != my_Grupos.count - 1)
            {
                let acctionSheet = UIAlertController(title: "Selecciona una opción", message: " ", preferredStyle: .actionSheet)
                acctionSheet.addAction(UIAlertAction(title: "Editar", style: .default, handler : {(action: UIAlertAction) in
                    let alert = UIAlertController(title: "Editar Grupo", message: "Ingresa el nuevo nombre de tu grupo: " + self.my_Grupos[indexPath.row].nombreGrupo, preferredStyle: .alert)
                    let modiAlumno = UIAlertAction(title: "Modificar Grupo", style: .default, handler: {(action) -> Void in
                        let nombre = alert.textFields![0]
                        self.PeticionEditarGrupo(nombreGrupo: self.my_Grupos[indexPath.row].nombreGrupo, nuevoNombre: nombre.text!)
                    })
                    alert.addTextField{(textField: UITextField) in textField.placeholder = "Nuevo nombre del grupo"}
                    alert.addAction(modiAlumno)
                    let cancelarAction = UIAlertAction(title: "Cancelar", style: .destructive, handler: {(action)-> Void in })
                    alert.addAction(cancelarAction)
                    self.present(alert, animated: true, completion: nil)
                }))
                
                acctionSheet.addAction(UIAlertAction(title: "Eliminar", style: .default, handler : {(action: UIAlertAction) in
                    let alert = UIAlertController(title: "Confirmación", message: "¿Estás seguro de eliminar?", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.default, handler: { (action) in
                    alert.dismiss(animated: true, completion: nil)
                    }))

                    alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default, handler: { (action) in
                        self.PeticionDeleteGrupo(nombreGrupo: self.my_Grupos[indexPath.row].nombreGrupo)
                        /*self.my_Grupos.remove(at: indexPath.row)
                        self.collectionView.reloadData()*/
                    }))
                        self.present(alert, animated: true, completion: nil)
                }))
                
                acctionSheet.addAction(UIAlertAction(title: "Enviar alerta preventiva", style: .default, handler : {(action: UIAlertAction) in
                    self.getFriends(nombre_catch: self.my_Grupos[indexPath.row].nombreGrupo)
                    print("********************")
                    self.printArray()
                    print("********************")
                    self.PeticionAlertPrev()
                }))
                
                acctionSheet.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler : nil))
                self.present(acctionSheet, animated: true, completion: nil)
            }
        }
        else
        {
            print("Could not find index path")
        }
    }
    
    //************************************* Funciones de las Table View *************************************
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tableView  == self.tableView { return my_Contactos.count }
        else { return userFound.count }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
       if tableView  == self.tableView{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ContactosTableViewCell", for: indexPath) as! ContactosTableViewCell
            cell.imagen.image = my_Contactos[indexPath.row].imagen
            cell.usuario.text = my_Contactos[indexPath.row].nomUser
            return cell
        }
       else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ContactosTableViewCell
            cell.imagen.image = userFound[indexPath.row].imagen
            cell.usuario.text = userFound[indexPath.row].nomUser
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if tableView  == self.tableView{
            if editingStyle == .delete
            {
                let alert = UIAlertController(title: "Confirmación", message: "¿Estás seguro de eliminar?", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.default, handler: { (action) in
                    alert.dismiss(animated: true, completion: nil)
                    
                }))
                
                alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default, handler: { (action) in
                    /*self.my_Contactos.remove(at: indexPath.row)
                    self.tableView.reloadData()*/
                    self.PeticionDeleteFriend(amigo: self.my_Contactos[indexPath.row].nomUser)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if tableView  == self.tableSearch{
            let alert = UIAlertController(title: "Enviar Solicitud", message: "¿Quieres agregar a  este usuario a tus amigos?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
                
            }))
            
            alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
                self.PeticionEnviarSolicitud(nombreNewAmigo: self.userFound[indexPath.row].nomUser)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //************************************* Funciones de las Barra de Búsqueda *************************************
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
    {
        UIView.animate(withDuration: 0.3, animations: {
            self.collectionView.isHidden = true
            searchBar.showsCancelButton = true
            //self.tableConstraint.constant  = -100
            self.tableView.isHidden = true
            self.tableSearch.isHidden = false
            self.view.layoutIfNeeded()
        })
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        UIView.animate(withDuration: 0.3, animations: {
            searchBar.text = nil
            searchBar.showsCancelButton = false
            searchBar.endEditing(true)
            self.collectionView.isHidden = false
            //self.tableConstraint.constant = 8
            self.tableView.isHidden = false
            self.tableSearch.isHidden = true
            self.view.layoutIfNeeded()
        })
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        self.PeticionBuscar(usuario: searchBar.text!)
        if !(searchBar.text?.isEmpty)!
        {
            _ = userFound.filter { (usuario) -> Bool in
            guard let text = searchBar.text else { return false }
            return usuario.nomUser.contains(text)
        }
            self.tableSearch.reloadData()
        }
        else
        {
            self.userFound.removeAll()
            self.tableSearch.reloadData()
        }
    }
    
     //************************************* Funciones de la Collection *************************************
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return my_Grupos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContactosCollectionViewCell", for: indexPath) as! ContactosCollectionViewCell
        cell.imgImagen.image = my_Grupos[indexPath.row].imageGrupo /*UIImage.init(named: "grupo1")*/
        cell.etiqueta.text = my_Grupos[indexPath.row].nombreGrupo
        
        if(indexPath.row == my_Grupos.count - 1)
        {
            cell.imgImagen.image = UIImage.init(named: "plus-2")
            cell.etiqueta.text = "Agregar grupo"
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if(indexPath.row == my_Grupos.count - 1)
        {
            let alert = UIAlertController(title: "Crear Grupo", message: "Ingresa el nombre de tu nuevo grupo", preferredStyle: .alert)
            let modiAlumno = UIAlertAction(title: "Crear Grupo", style: .default, handler: {(action) -> Void in
                let nombre = alert.textFields![0]
                self.PeticionCreateTeam(nombre: nombre.text!)
            })
            alert.addTextField{(textField: UITextField) in textField.placeholder = "Nombre del grupo"}
            alert.addAction(modiAlumno)
            let cancelarAction = UIAlertAction(title: "Cancelar", style: .destructive, handler: {(action)-> Void in })
            alert.addAction(cancelarAction)
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            let mainTabController = storyboard?.instantiateViewController(withIdentifier: "DetallesVC") as! DetallesVC
            mainTabController.publicidad_catch = (self.my_Grupos[indexPath.row].imageGrupo)
            mainTabController.nombre_catch = (self.my_Grupos[indexPath.row].nombreGrupo)
            self.navigationController?.pushViewController(mainTabController, animated: true)
        }
    }
    
    @IBAction func contactoFunc(_ sender: UILongPressGestureRecognizer)
    {
        let acctionSheet = UIAlertController(title: "Selecciona una opción", message: " ", preferredStyle: .actionSheet)
        acctionSheet.addAction(UIAlertAction(title: "Enviar ubicación", style: .default, handler : {(action: UIAlertAction) in
            
        }))
        acctionSheet.addAction(UIAlertAction(title: "Solicitar ubicación", style: .default, handler : {(action: UIAlertAction) in

        }))
        acctionSheet.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler : nil))
        self.present(acctionSheet, animated: true, completion: nil)
    }
    
    
    func AgregarInstacias()
    {
        self.my_Grupos.append(Grupos(imageGrupo: UIImage.init(named: "grupo1")!,
                                     nombreGrupo: "Família"))
        self.my_Grupos.append(Grupos(imageGrupo: UIImage.init(named: "grupo2")!,
                                     nombreGrupo: "Amigos"))
        self.my_Grupos.append(Grupos(imageGrupo: UIImage.init(named: "grupo3")!,
                                     nombreGrupo: "Vecinos"))
        self.my_Grupos.append(Grupos(imageGrupo: UIImage.init(named: "grupo4")!,
                                     nombreGrupo: "Trabajo"))
        self.my_Grupos.append(Grupos(imageGrupo: UIImage.init(named: "grupo5")!,
                                     nombreGrupo: "Secundaria"))
        
        self.my_Contactos.append(Contactos(imagen: UIImage.init(named: "rostro1")!,
                                           nomUser: "Delta"))
        self.my_Contactos.append(Contactos(imagen: UIImage.init(named: "rostro2")!,
                                           nomUser: "Hilter"))
        self.my_Contactos.append(Contactos(imagen: UIImage.init(named: "rostro3")!,
                                           nomUser: "Kronos"))
        self.my_Contactos.append(Contactos(imagen: UIImage.init(named: "rostro4")!,
                                           nomUser: "Paulina"))
    }

    func setupLongPressGesture()
    {
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPressTable))
        longPressGesture.minimumPressDuration = 0.5 // 1 second press
        longPressGesture.delaysTouchesBegan = true
        self.tableView.addGestureRecognizer(longPressGesture)
    }
    
    @objc func handleLongPressTable(_ gestureRecognizer: UILongPressGestureRecognizer)
    {
        let point = gestureRecognizer.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)
        
        if let indexPath = indexPath
        {
            let acctionSheet = UIAlertController(title: "Selecciona una opción", message: " ", preferredStyle: .actionSheet)
            
            acctionSheet.addAction(UIAlertAction(title: "Enviar alerta preventiva", style: .default, handler : {(action: UIAlertAction) in
                self.amigosDetele.append(self.my_Contactos[indexPath.row].nomUser)
                print("********************")
                self.printArray()
                print("********************")
                self.PeticionAlertPrev()
            }))
            
            acctionSheet.addAction(UIAlertAction(title: "Solicitar ubicación", style: .default, handler : {(action: UIAlertAction) in
                self.amigosDetele.append(self.my_Contactos[indexPath.row].nomUser)
                print("********************")
                self.printArray()
                print("********************")
                self.PeticionSolicidLocation()
            }))
            
            acctionSheet.addAction(UIAlertAction(title: "Vigilar usuario", style: .default, handler : {(action: UIAlertAction) in
                self.PeticionVigilarUser(usuario: self.my_Contactos[indexPath.row].nomUser)
            }))
            
            acctionSheet.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler : {(action: UIAlertAction) in
                self.amigosDetele.removeAll()
            }))
            self.present(acctionSheet, animated: true, completion: nil)
        }
    }
    
    func printArray()
    {
        for e in amigosDetele{
            print(e)
        }
    }
    
    func createAlert(tittle:String, message:String)
    {
        let alert = UIAlertController(title: tittle, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func getFriendsYTeams()
    {
        let friends = self.realm.objects(Respuesta.self)
        
        if friends.count != 0
        {
            for contactos in (friends.first?.amigos)!
            {
                self.my_Contactos.append(Contactos(imagen: UIImage.init(named: "rostro1")!, nomUser: contactos))
                print(contactos)
                self.tableView.reloadData()
            }
            
            for grupos in (friends.first?.grupos)!
            {
                self.my_Grupos.append(Grupos(imageGrupo: UIImage.init(named: "grupo5")!, nombreGrupo: grupos.nombreGrupo))
                print(grupos)
                self.collectionView.reloadData()
            }
        }
        else
        {
            self.PeticionFriendsYTeams()
        }
    }
    
    func EliminarContactosyGrupos()
    {
        let result = realm.objects(Respuesta.self)
        try! realm.write
        {
            realm.delete(result)
            print("Se borraron todos los Contactos y Grupos con éxito")
        }
    }
    
    func getFriends(nombre_catch:String)
    {
        let friends = self.realm.objects(Respuesta.self)
        
        for grupos in (friends.first?.grupos)!
        {
            if grupos.nombreGrupo == nombre_catch
            {
                print(grupos.nombreGrupo)
                for miembros in grupos.miembros
                {
                    self.amigosDetele.append( miembros)
                    print(miembros)
                }
            }
        }
    }
    
    func PeticionBuscar(usuario: String)
    {
        DispatchQueue.main.async
        {
            let parameters      = ["nombreUsuario": usuario]  // variable para el cuerpo de la petición
            guard let url       = URL(string: URLPeticion + ":3030/Modular/API/contactos/BuscarUsuario") else { return }       // URL a quien se hace la petición
            var request         = URLRequest(url: url)                                                                      // No supe bien xD
            request.httpMethod  = "POST"                                                                                    // Selección del tipo de método
            request.addValue(   "application/json", forHTTPHeaderField: "Content-Type")                                     // aplica un formato especial para el cuerpo
            guard let httpBody  = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }      // conversión de parámetros a JSON
            request.httpBody    = httpBody                                                                                  // envío de parámetros
            self.JSONReportesUser(request: request)                                                                             // Respuesta de cliente HTTP
        }
    }
    
    func JSONReportesUser(request:URLRequest)
    {
        let seccion = URLSession.shared
        seccion.dataTask(with: request)
        {   (data, response, error) in
            guard let data  = data else { return }
            do
            {
                guard let json  = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else { return }
                let reportes     = Busqueda(value: json)
                DispatchQueue.main.async                                                                // Hilo para comprobar que se realizó bien la petición
                {
                    if reportes.codigoRespuesta == 200                                                // Para el caso correcto
                    {
                        self.userFound.removeAll()
                        for repo  in reportes.usuarios                                                  // recorrido de arreglo en los reportes
                        {
                            print(repo)
                            self.userFound.append(Contactos(imagen: UIImage.init(named: "icono-mi-cuenta")!, nomUser: repo))
                        }
                    }
                    else { }
                }
            }
            catch let jsonErr
            {
                print("Error de serialización json:", jsonErr)
            }
        }.resume()
    }
    
    func PeticionFriendsYTeams()
    {
        DispatchQueue.main.async
        {
            let parameters      = ["nombreUsuario": nomUser, "tokenSiliconBear": tokenSB, "ubicacionUsuario": userLocation]  // variable para el cuerpo de la petición
                guard let url       = URL(string: URLPeticion + ":3030/Modular/API/contactos/ActualizarAmigosYGrupos") else { return }       // URL a quien se hace la petición
                var request         = URLRequest(url: url)                                                                      // No supe bien xD
                request.httpMethod  = "POST"                                                                                    // Selección del tipo de método
                request.addValue(   "application/json", forHTTPHeaderField: "Content-Type")                                     // aplica un formato especial para el cuerpo
                guard let httpBody  = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }      // conversión de parámetros a JSON
                request.httpBody    = httpBody                                                                                  // envío de parámetros
                self.JSONFriendsYTeams(request: request)                                                                             // Respuesta de cliente HTTP
        }
    }
    
    func JSONFriendsYTeams(request:URLRequest)
    {
        let seccion = URLSession.shared
        seccion.dataTask(with: request)
        {   (data, response, error) in
            guard let data  = data else { return }
            do
            {
                guard let json  = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else { return }
                let amigos     = Respuesta(value: json)
                DispatchQueue.main.async                                                                // Hilo para comprobar que se realizó bien la petición
                {
                    if amigos.codigoRespuesta == 200                                                // Para el caso correcto
                    {
                        for amigos  in amigos.amigos                                                 // recorrido de arreglo en los reportes
                        {
                            self.my_Contactos.append(Contactos(imagen: UIImage.init(named: "rostro1")!, nomUser: amigos))
                            print(amigos)
                            self.tableView.reloadData()
                        }
                        for grupos  in amigos.grupos                                                // recorrido de arreglo en los reportes
                        {
                            self.my_Grupos.append(Grupos(imageGrupo: UIImage.init(named: "grupo5")!, nombreGrupo: grupos.nombreGrupo))
                            print(grupos)
                            self.collectionView.reloadData()
                        }
                        DispatchQueue.main.async                                                                // Hilo para comprobar que se realizó bien la petición
                        {
                            try! self.realm.write
                            {
                                self.realm.add(amigos)
                                self.createAlert(tittle: "¡Correcto!", message: "Se han actualizado los contactos y grupos")
                            }
                        }
                        
                    }
                    else { }
                }
            }
            catch let jsonErr
            {
                print("Error de serialización json:", jsonErr)
            }
        }.resume()
    }
    
    func PeticionDeleteFriend(amigo: String)
    {
        DispatchQueue.main.async
        {
            let parameters      = ["nombreUsuario": nomUser, "nombreUsuarioAmigo": amigo, "tokenSiliconBear": tokenSB, "ubicacionUsuario": userLocation]  // variable para el cuerpo de la petición
            guard let url       = URL(string: URLPeticion + ":3030/Modular/API/contactos/EliminarAmigo") else { return }       // URL a quien se hace la petición
            var request         = URLRequest(url: url)                                                                      // No supe bien xD
            request.httpMethod  = "POST"                                                                                    // Selección del tipo de método
            request.addValue(   "application/json", forHTTPHeaderField: "Content-Type")                                     // aplica un formato especial para el cuerpo
            guard let httpBody  = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }      // conversión de parámetros a JSON
            request.httpBody    = httpBody                                                                                  // envío de parámetros
            self.JSONDeleteFriend(request: request)                                                                             // Respuesta de cliente HTTP
        }
    }
    
    func JSONDeleteFriend(request:URLRequest)
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
    
    func PeticionCreateTeam(nombre: String)
    {
        DispatchQueue.main.async
            {
                let parameters      = ["nombreUsuario": nomUser, "nombreGrupo": nombre, "tokenSiliconBear": tokenSB, "ubicacionUsuario": userLocation]  // variable para el cuerpo de la petición
                guard let url       = URL(string: URLPeticion + ":3030/Modular/API/contactos/CrearGrupo") else { return }       // URL a quien se hace la petición
                var request         = URLRequest(url: url)                                                                      // No supe bien xD
                request.httpMethod  = "POST"                                                                                    // Selección del tipo de método
                request.addValue(   "application/json", forHTTPHeaderField: "Content-Type")                                     // aplica un formato especial para el cuerpo
                guard let httpBody  = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }      // conversión de parámetros a JSON
                request.httpBody    = httpBody                                                                                  // envío de parámetros
                self.JSONCreateTeam(request: request)                                                                             // Respuesta de cliente HTTP
        }
    }
    
    func JSONCreateTeam(request:URLRequest)
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
    
    func PeticionEnviarSolicitud(nombreNewAmigo: String)
    {
        DispatchQueue.main.async
            {
                let parameters      = ["nombreUsuario": nomUser, "usuarioAgregado": nombreNewAmigo, "tokenSiliconBear": tokenSB, "ubicacionUsuario": userLocation]  // variable para el cuerpo de la petición
                guard let url       = URL(string: URLPeticion + ":3030/Modular/API/contactos/EnviarSolicitudAmistad") else { return }       // URL a quien se hace la petición
                var request         = URLRequest(url: url)                                                                      // No supe bien xD
                request.httpMethod  = "POST"                                                                                    // Selección del tipo de método
                request.addValue(   "application/json", forHTTPHeaderField: "Content-Type")                                     // aplica un formato especial para el cuerpo
                guard let httpBody  = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }      // conversión de parámetros a JSON
                request.httpBody    = httpBody                                                                                  // envío de parámetros
                self.JSONEnviarSolicitud(request: request)                                                                             // Respuesta de cliente HTTP
        }
    }
    
    func JSONEnviarSolicitud(request:URLRequest)
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
    
    func PeticionEditarGrupo(nombreGrupo: String, nuevoNombre: String)
    {
        DispatchQueue.main.async
        {
            let parameters      = ["nombreUsuario": nomUser, "nombreGrupo": nombreGrupo, "nuevoNombreGrupo": nuevoNombre, "tokenSiliconBear": tokenSB, "ubicacionUsuario": userLocation]  // variable para el cuerpo de la petición
            guard let url       = URL(string: URLPeticion + ":3030/Modular/API/contactos/EditarGrupo") else { return }       // URL a quien se hace la petición
            var request         = URLRequest(url: url)                                                                      // No supe bien xD
            request.httpMethod  = "POST"                                                                                    // Selección del tipo de método
            request.addValue(   "application/json", forHTTPHeaderField: "Content-Type")                                     // aplica un formato especial para el cuerpo
            guard let httpBody  = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }      // conversión de parámetros a JSON
            request.httpBody    = httpBody                                                                                  // envío de parámetros
            self.JSONEditarGrupo(request: request)                                                                             // Respuesta de cliente HTTP
        }
    }
    
    func JSONEditarGrupo(request:URLRequest)
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
    
    func PeticionDeleteGrupo(nombreGrupo: String)
    {
        DispatchQueue.main.async
        {
            let parameters      = ["nombreUsuario": nomUser, "nombreGrupo": nombreGrupo, "tokenSiliconBear": tokenSB, "ubicacionUsuario": userLocation]  // variable para el cuerpo de la petición
            guard let url       = URL(string: URLPeticion + ":3030/Modular/API/contactos/EliminarGrupo") else { return }       // URL a quien se hace la petición
            var request         = URLRequest(url: url)                                                                      // No supe bien xD
            request.httpMethod  = "POST"                                                                                    // Selección del tipo de método
            request.addValue(   "application/json", forHTTPHeaderField: "Content-Type")                                     // aplica un formato especial para el cuerpo
            guard let httpBody  = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }      // conversión de parámetros a JSON
            request.httpBody    = httpBody                                                                                  // envío de parámetros
            self.JSONDeleteGrupo(request: request)                                                                             // Respuesta de cliente HTTP
        }
    }
    
    func JSONDeleteGrupo(request:URLRequest)
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
    
    func PeticionAlertPrev()
    {
        DispatchQueue.main.async
        {
            let parameters      = ["nombreUsuario": nomUser, "usuariosNotificados": self.amigosDetele, "tokenSiliconBear": tokenSB, "ubicacionUsuario": userLocation] as [String : Any]  // variable para el cuerpo de la petición
            guard let url       = URL(string: URLPeticion + ":3030/Modular/API/contactos/EnviarAlertaPreventiva") else { return }       // URL a quien se hace la petición
            var request         = URLRequest(url: url)                                                                      // No supe bien xD
            request.httpMethod  = "POST"                                                                                    // Selección del tipo de método
            request.addValue(   "application/json", forHTTPHeaderField: "Content-Type")                                     // aplica un formato especial para el cuerpo
            guard let httpBody  = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }      // conversión de parámetros a JSON
            request.httpBody    = httpBody                                                                                  // envío de parámetros
            self.JSONAlertPrev(request: request)                                                                             // Respuesta de cliente HTTP
        }
    }
    
    func JSONAlertPrev(request:URLRequest)
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
                    self.amigosDetele.removeAll()
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
    
    func PeticionSolicidLocation()
    {
        DispatchQueue.main.async
            {
                let parameters      = ["nombreUsuario": nomUser, "usuariosSolicitados": self.amigosDetele, "tokenSiliconBear": tokenSB, "ubicacionUsuario": userLocation] as [String : Any]  // variable para el cuerpo de la petición
                guard let url       = URL(string: URLPeticion + ":3030/Modular/API/contactos/SolicitarUbicacion") else { return }       // URL a quien se hace la petición
                var request         = URLRequest(url: url)                                                                      // No supe bien xD
                request.httpMethod  = "POST"                                                                                    // Selección del tipo de método
                request.addValue(   "application/json", forHTTPHeaderField: "Content-Type")                                     // aplica un formato especial para el cuerpo
                guard let httpBody  = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }      // conversión de parámetros a JSON
                request.httpBody    = httpBody                                                                                  // envío de parámetros
                self.JSONSolicidLocation(request: request)                                                                             // Respuesta de cliente HTTP
        }
    }
    
    func JSONSolicidLocation(request:URLRequest)
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
                    self.amigosDetele.removeAll()
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
    
    func PeticionVigilarUser(usuario: String)
    {
        DispatchQueue.main.async
            {
                let parameters      = ["nombreUsuario": nomUser, "usuarioVigilado": usuario, "tokenSiliconBear": tokenSB, "ubicacionUsuario": userLocation]  // variable para el cuerpo de la petición
                guard let url       = URL(string: URLPeticion + ":3030/Modular/API/contactos/VigilarUsuario") else { return }       // URL a quien se hace la petición
                var request         = URLRequest(url: url)                                                                      // No supe bien xD
                request.httpMethod  = "POST"                                                                                    // Selección del tipo de método
                request.addValue(   "application/json", forHTTPHeaderField: "Content-Type")                                     // aplica un formato especial para el cuerpo
                guard let httpBody  = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }      // conversión de parámetros a JSON
                request.httpBody    = httpBody                                                                                  // envío de parámetros
                self.JSONVigilarUser(request: request)                                                                             // Respuesta de cliente HTTP
        }
    }
    
    func JSONVigilarUser(request:URLRequest)
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
                    self.amigosDetele.removeAll()
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
    
}
