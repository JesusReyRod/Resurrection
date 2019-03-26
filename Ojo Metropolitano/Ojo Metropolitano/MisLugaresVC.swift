//
//  MisLugaresVC.swift
//  Ojo Metropolitano
//
//  Created by Jesus Reynaga Rodriguez on 12/03/18.
//  Copyright © 2018 Silicon Bear. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import RealmSwift

class MisLugaresVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, MKMapViewDelegate, UIGestureRecognizerDelegate
{
    
    @IBOutlet weak var myCollectionGrupos: UICollectionView!                    // variable de la barra horizontal de los grupos
    @IBOutlet weak var mapView:            MKMapView!                           // variable para visualizar el mapa en el view controller
    let span:MKCoordinateSpan            = MKCoordinateSpanMake(0.01, 0.01)     // variable para el enfoque de la cámara del mapa
    let realm = try! Realm()
    var id_lugar = ""
    var posicion_lugar = Int()
    
    //******************** Estructura de los lugares ********************//
    struct LugarMarcado
    {
        var id_lugar:     String
        var tipo_lugar:   String
        var nombre_lugar: String
        var coordx_lugar: String
        var coordy_lugar: String
    }
    var MisLugaresMarcados: [LugarMarcado] = []                                 // creación de un arreglo vacio de la estructura
    
    //******************** Main del View Controller ********************//
    override func viewDidLoad()
    {
        DispatchQueue.main.async
        {
            
            self.mapView.delegate = self                                        // variable para visualizar el mapa en el view controller
            self.MarcadorUbicacion()                                            // Función para visualizar la ubicación del usuario en el mapa del view controller
        }
        super.viewDidLoad()                                                 // función propia para cargar el View Controller y sus elementos
        //self.Peticion2()
        //self.CosultaLugares()
        //self.CosultaReportes()
        //self.Peticion()
        self.getLugares()
        self.MisLugaresMarcados.append(LugarMarcado(id_lugar: " ",          // creación de un elemento en blanco para poder ver el botón de "Agregar"
                                                    tipo_lugar: " ",
                                                    nombre_lugar: " ",
                                                    coordx_lugar: " ",
                                                    coordy_lugar: " "));
        self.myCollectionGrupos.reloadData()
        
        let longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(longPressGR:)))
        longPressGR.minimumPressDuration = 0.5
        longPressGR.delaysTouchesBegan = true
        self.myCollectionGrupos.addGestureRecognizer(longPressGR)
    }
    
    @objc func handleLongPress(longPressGR: UILongPressGestureRecognizer)
    {
        let point = longPressGR.location(in: self.myCollectionGrupos)
        let indexPath = self.myCollectionGrupos.indexPathForItem(at: point)
        
        if let indexPath = indexPath {
            if(indexPath.row != MisLugaresMarcados.count - 1)
            {
                
                let acctionSheet = UIAlertController(title: "Selecciona una opción", message: " ", preferredStyle: .actionSheet)
                
                acctionSheet.addAction(UIAlertAction(title: "Editar", style: .default, handler : {(action: UIAlertAction) in
                    print(self.MisLugaresMarcados[indexPath.row].id_lugar)
                    print(self.MisLugaresMarcados[indexPath.row].nombre_lugar)
                }))
                
                acctionSheet.addAction(UIAlertAction(title: "Eliminar", style: .default, handler : {(action: UIAlertAction) in
                    
                    let alert = UIAlertController(title: "Confirmación", message: "¿Estás seguro de eliminar?", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.default, handler: { (action) in
                        alert.dismiss(animated: true, completion: nil)
                    }))
                    
                    alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default, handler: { (action) in
                        self.id_lugar = self.MisLugaresMarcados[indexPath.row].id_lugar
                        self.posicion_lugar = indexPath.row
                        self.PeticionEliminar(id: self.id_lugar)
                        print("_______________________________________________")
                        print(self.id_lugar)
                        print(self.posicion_lugar)
                        print("_______________________________________________")
                    }))
                    self.present(alert, animated: true, completion: nil)
                }))
                
                acctionSheet.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler : nil))
                self.present(acctionSheet, animated: true, completion: nil)
            }
        } else {
            print("Could not find index path")
        }
    }
    
    //******************** Función propia del mapKit para cambiar color y ver las etiquetas ********************//
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "myAnnotation") as? MKPinAnnotationView
        
        if annotationView == nil
        {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myAnnotation")
        }
        else
        {
            annotationView?.annotation = annotation
        }
        
        if let annotation = annotation as? PinAnnotation
        {
            annotationView?.pinTintColor = annotation.pinTinColor
        }
        annotationView?.canShowCallout            = true
        annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        return annotationView
    }
    
    //******************** Función para crear un marcador según la ubicación del usuario ********************//
    func MarcadorUbicacion()
    {
        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(Double(Latitude)!, Double(Longitude)!)
        let pin = PinAnnotation(id: "Mi ubicacion", title: "Usted está aquí", subtitle: "Verifique la Zona !", coordinate: myLocation, pinTinColor: .black)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        mapView.setRegion(region, animated: true)
        self.mapView.addAnnotation(pin)
    }
    
    //******************** Función propia de la Collection (barra horizontal) ********************//
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return MisLugaresMarcados.count                     // especifica el numero de elementos a mostrar en la collection
    }
    
    //******************** Función propia de la collection para mostrar los elementos ********************//
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GruposCollectionViewCell", for: indexPath) as! GruposCollectionViewCell
        cell.imageGrupo.image = UIImage.init(named: "MisLugares_iconoLugarCasa")
        cell.etiqueta.text    = MisLugaresMarcados[indexPath.row].nombre_lugar
        if(indexPath.row == MisLugaresMarcados.count - 1)
        {
            cell.imageGrupo.image = UIImage.init(named: "plus-2")
            cell.etiqueta.text = "Agregar lugar"
        }
        return cell
    }
    
    //******************** Función propia para crear un evento al ser seleccionado un elemento ********************//
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if(indexPath.row == MisLugaresMarcados.count - 1)
        {
            let mainTabController = storyboard?.instantiateViewController(withIdentifier: "AgregarLugarVC") as! AgregarLugarVC
            present(mainTabController, animated: true, completion: nil)
        }
        else
        {
            self.MoverMapa(longitud: Double(MisLugaresMarcados[indexPath.row].coordx_lugar)!, latitud: Double(MisLugaresMarcados[indexPath.row].coordy_lugar)!)
        }
    }
    
    //******************** Solo cambia el mapa cuando se tenga ya resitrados los lugares ********************//
    func MoverMapa(longitud:Double, latitud:Double)
    {
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01) 
        let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(longitud, latitud)    // Localizacion
        let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        mapView.setRegion(region, animated: true)
    }
    
    func Peticion()
    {
        DispatchQueue.main.async
        {
            let parameters      = ["nombreUsuario": nomUser, "tokenSiliconBear":tokenSB, "ubicacionUsuario": userLocation]  // variable para el cuerpo de la petición
            guard let url       = URL(string: URLPeticion + "/Modular/API/Lugares/ActualizarLugares.php") else { return }    // URL a quien se hace la petición
            var request         = URLRequest(url: url)                                                                      // No supe bien xD
            request.httpMethod  = "POST"                                                                                    // Selección del tipo de método
            request.addValue(   "application/json", forHTTPHeaderField: "Content-Type")                                     // aplica un formato especial para el cuerpo
            guard let httpBody  = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }      // conversión de parámetros a JSON
            request.httpBody    = httpBody                                                                                  // envío de parámetros
            self.JSONLugares(   request: request)                                                                           // Respuesta de cliente HTTP
        }
    }
    
    func JSONLugares(request:URLRequest)
    {
        let seccion = URLSession.shared
        seccion.dataTask(with: request)
        {   (data, response, error) in
            guard let data  = data else { return }
            do
            {
                guard let json  = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else { return }
                let places     = ConsultaLugares(value: json)
                print(places.lugares)
                DispatchQueue.main.async
                {
                    if places.codigoRespuesta == "200"
                    {
                        self.EliminarLugares()
                        for userPlace in places.lugares
                        {
                            self.MisLugaresMarcados.append(LugarMarcado(id_lugar: userPlace.idLugar,
                                                                        tipo_lugar: userPlace.tipoLugar,
                                                                        nombre_lugar: userPlace.nombreLugar,
                                                                        coordx_lugar: userPlace.latitudLugar,
                                                                        coordy_lugar: userPlace.longitudLugar));
                        }
                        DispatchQueue.main.async
                        {
                            try! self.realm.write
                            {
                                self.realm.add(places.lugares)
                                print("Se guardó como esperabamos")
                            }
                        }
                    }
                    else
                    {
                        
                    }
                }
            }
            catch let jsonErr
            {
                print("Error de serialización json:", jsonErr)
            }
            }.resume()
    }
    
    func CosultaLugares()
    {
        let lugares = self.realm.objects(LugaresUsuario.self)
        print("________________________________________________________")
        print(lugares.count)
        for places in lugares
        {
            self.MisLugaresMarcados.append(LugarMarcado(id_lugar: places.idLugar,
                                                        tipo_lugar: places.tipoLugar,
                                                        nombre_lugar: places.nombreLugar,
                                                        coordx_lugar: places.latitudLugar,
                                                        coordy_lugar: places.longitudLugar));
            self.addMarkers(lat: places.latitudLugar, log: places.longitudLugar, type: places.tipoLugar, id: places.nombreLugar)
            print(places)
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
    
    func AlertDetele(tittle:String, message:String, id_lugar:String)
    {
        let alert = UIAlertController(title: tittle, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default, handler: { (action) in
            self.PeticionEliminar(id: id_lugar)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func PeticionEliminar(id:String)
    {
        DispatchQueue.main.async
        {
            let parameters      = ["nombreUsuario": nomUser,
                                   "idLugar": id,
                                   "tokenSiliconBear": tokenSB,
                                   "ubicacionUsuario": userLocation];                                                           // variable para el cuerpo de la petición
                guard let url       = URL(string: URLPeticion + "/Modular/API/Lugares/EliminarLugar.php") else { return }        // URL a quien se hace la petición
                var request         = URLRequest(url: url)                                                                      // No supe bien xD
                request.httpMethod  = "POST"                                                                                    // Selección del tipo de método
                request.addValue(   "application/json", forHTTPHeaderField: "Content-Type")                                     // aplica un formato especial para el cuerpo
                guard let httpBody  = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }      // conversión de parámetros a JSON
                request.httpBody    = httpBody                                                                                  // envío de parámetros
                self.JSONLugareDetele(request: request)                                                                           // Respuesta de cliente HTTP
        }
    }
    
    func JSONLugareDetele(request:URLRequest)
    {
        let seccion = URLSession.shared
        seccion.dataTask(with: request)
        {   (data, response, error) in
            guard let data  = data else { return }
            do
            {
                guard let json  = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else { return }
                let places     = ConsultaLugares(value: json)
                print(places.lugares)
                DispatchQueue.main.async
                {
                    if places.codigoRespuesta == "200"
                    {
                        self.MisLugaresMarcados.remove(at: self.posicion_lugar)
                        self.myCollectionGrupos.reloadData()
                        self.EliminarLugar(id_lugar: self.id_lugar)
                    }
                    else
                    {
                        self.createAlert(tittle: "¡Upps!", message: places.mensajeRespuesta)
                    }
                }
            }
            catch let jsonErr
            {
                print("Error de serialización json:", jsonErr)
            }
        }.resume()
    }
    
    func EliminarLugares()
    {
        let result = realm.objects(LugaresUsuario.self)
        try! realm.write
        {
            realm.delete(result)
            print("Se borraron todos los lugares con éxito")
        }
    }
        
    func EliminarLugar(id_lugar:String)
    {
        let result = realm.objects(LugaresUsuario.self).filter("idLugar == %@", id_lugar)
        print(result)
        try! realm.write
        {
            realm.delete(result)
        }
    }
    
    func addMarkers(lat:String, log:String, type:String, id:String)
    {
        let marcadores:CLLocationCoordinate2D = CLLocationCoordinate2DMake(Double(lat)!, Double(log)!)
        switch type
        {
        case "1":
            let pin = PinAnnotation(id: id, title: id, subtitle: "Casa", coordinate: marcadores, pinTinColor: .brown)
            self.mapView.addAnnotation(pin)
        case "2":
            let pin = PinAnnotation(id: id, title: id, subtitle: "Escuela", coordinate: marcadores, pinTinColor: .blue)
            self.mapView.addAnnotation(pin)
        case "3":
            let pin = PinAnnotation(id: id, title: id, subtitle: "Trabajo", coordinate: marcadores, pinTinColor: .cyan)
            self.mapView.addAnnotation(pin)
        case "4":
            let pin = PinAnnotation(id: id, title: id, subtitle: "GYM", coordinate: marcadores, pinTinColor: .yellow)
            self.mapView.addAnnotation(pin)
        case "5":
            let pin = PinAnnotation(id: id, title: id, subtitle: "Otro", coordinate: marcadores, pinTinColor: .orange)
            self.mapView.addAnnotation(pin)
        /*case "6":
            let pin = PinAnnotation(id: id, title: "Violación", subtitle: "", coordinate: marcadores, pinTinColor: .green)
            self.mapView.addAnnotation(pin)
        case "7":
            let pin = PinAnnotation(id: id, title: "Secuentro o Tentativa", subtitle: "", coordinate: marcadores, pinTinColor: .gray)
            self.mapView.addAnnotation(pin)
        case "8":
            let pin = PinAnnotation(id: id, title: "Asesinato", subtitle: "", coordinate: marcadores, pinTinColor: .red)
            self.mapView.addAnnotation(pin)*/
        default:
            print("no se la neta alv")
        }
    }
    
    
    //************************************************************************************************************************************************************//
    
    
    /*
    
     func JSONLugareDetele(request:URLRequest)
     {
     let seccion = URLSession.shared
     seccion.dataTask(with: request)
     {   (data, response, error) in
     guard let data  = data else { return }
     do
     {
     guard let json  = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else { return }
     let places     = ConsultaLugares(value: json)
     print(places.lugares)
     DispatchQueue.main.async
     {
     if places.codigoRespuesta == "200"
     {
     self.MisLugaresMarcados.remove(at: self.posicion_lugar)
     self.myCollectionGrupos.reloadData()
     self.EliminarLugar(id_lugar: self.id_lugar)
     }
     else
     {
     self.createAlert(tittle: "¡Upps!", message: places.mensajeRespuesta)
     }
     }
     }
     catch let jsonErr
     {
     print("Error de serialización json:", jsonErr)
     }
     }.resume()
     }
     
     */
    
    func getLugares()
    {
        let lugares = self.realm.objects(LugaresUsuario.self)
        print(lugares.count)
        if lugares.count != 0
        {
            for places in lugares
            {
                self.MisLugaresMarcados.append(LugarMarcado(id_lugar: places.idLugar,
                                                            tipo_lugar: places.tipoLugar,
                                                            nombre_lugar: places.nombreLugar,
                                                            coordx_lugar: places.latitudLugar,
                                                            coordy_lugar: places.longitudLugar));
                self.addMarkers(lat: places.latitudLugar, log: places.longitudLugar, type: places.tipoLugar, id: places.nombreLugar)
                self.myCollectionGrupos.reloadData()
            }
        }
        else
        {
            self.Peticion2()
        }
    }
    
    func Peticion2()
    {
        DispatchQueue.main.async
        {
            let parameters      = ["nombreUsuario": nomUser, "tokenSiliconBear":tokenSB, "ubicacionUsuario": userLocation]  // variable para el cuerpo de la petición
            guard let url       = URL(string: URLPeticion + "/Modular/API/Lugares/ActualizarLugares.php") else { return }    // URL a quien se hace la petición
            var request         = URLRequest(url: url)                                                                      // No supe bien xD
            request.httpMethod  = "POST"                                                                                    // Selección del tipo de método
            request.addValue(   "application/json", forHTTPHeaderField: "Content-Type")                                     // aplica un formato especial para el cuerpo
            guard let httpBody  = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }      // conversión de parámetros a JSON
            request.httpBody    = httpBody                                                                                  // envío de parámetros
            self.JSONLugares2(   request: request)                                                                           // Respuesta de cliente HTTP
        }
    }
    
    func JSONLugares2(request:URLRequest)
    {
        let seccion = URLSession.shared
        seccion.dataTask(with: request)
        {   (data, response, error) in
            guard let data  = data else { return }
            do
            {
                guard let json  = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else { return }
                let places      = ConsultaLugares(value: json)
                print(places.lugares)
                DispatchQueue.main.async
                {
                    if places.codigoRespuesta == "200"
                    {
                        for userPlace in places.lugares
                        {
                            self.MisLugaresMarcados.append(LugarMarcado(id_lugar: userPlace.idLugar,
                                                                        tipo_lugar: userPlace.tipoLugar,
                                                                        nombre_lugar: userPlace.nombreLugar,
                                                                        coordx_lugar: userPlace.latitudLugar,
                                                                        coordy_lugar: userPlace.longitudLugar));
                            self.addMarkers(lat: userPlace.latitudLugar,
                                            log: userPlace.longitudLugar,
                                            type: userPlace.tipoLugar,
                                            id: userPlace.nombreLugar)
                            self.myCollectionGrupos.reloadData()
                        }
                        DispatchQueue.main.async
                        {
                            try! self.realm.write
                            {
                                self.realm.add(places.lugares)
                                self.createAlert(tittle: "¡Correcto!", message: "Se han actualizado los lugares")
                            }
                        }
                    }
                    else
                    {
                        self.createAlert(tittle: "¡Error!", message: places.mensajeRespuesta)
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
