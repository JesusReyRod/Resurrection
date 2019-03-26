//
//  InicioViewController.swift
//  Ojo Metropolitano Beta
//
//  Created by Jesus Reynaga Rodriguez on 28/01/18.
//  Copyright © 2018 Silicon Bear. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation
import RealmSwift

class InicioViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate
{
    
    @IBOutlet weak var userReporte:    UIButton!
    @IBOutlet weak var mapView:        MKMapView!                     // variable de MapKit para poder visualizar el mapa y trabajar con sus herramientas
    @IBOutlet weak var mapViewReporte: MKMapView!
    @IBOutlet weak var floatyButton:   UIButton!
    @IBOutlet weak var viewConstraint: NSLayoutConstraint!            // variable de tipo contraint para interactuar con el menú tareal
    @IBOutlet weak var blurView:       UIVisualEffectView!            // variable de efecto borroso para el menú lateral
    @IBOutlet weak var sideView:       UIView!                        // variable de la herrameinta VIew para crear el menú lateral
    @IBOutlet weak var perfilMenu:     UIImageView!                   // variable de la herramienta Imagen par ael menú lateral y efectos visuales
    @IBOutlet weak var userName:       UILabel!                       // variable para mostrar el nombre del usuario en el menú lateral
    @IBOutlet weak var popupReporte:   RoundBTN!
    let span:MKCoordinateSpan        = MKCoordinateSpanMake(0.2, 0.2) // variable para enfocar la cámara del mapa a una cierta distancia
    
    var isSlideMenuHidden            = true
    let realm = try! Realm()
    var isTap = 0
    
    //******************** Main de la sección Inicio o Home ********************//
    override func viewDidLoad()
    {
        
        DispatchQueue.main.async                // Hilo para la consulta de los Reportes globales
        {
            self.consulta()
            self.Peticio()                      // Función para realizar la petición
            self.MarcadorUbicacion()            // Función mostrar la ubicación del usuario
            self.mapView.delegate = self        // Función propia de la herramienta MapKit para visualizar el mapa
        }
        DispatchQueue.main.async                                                                // Hilo para comprobar que se realizó bien la petición
        {
            self.deleteReportes()
        }
        super.viewDidLoad()                     // Función propia de ViewController para visualizar el contenido de la ventana o Activity
        
        
        /*DispatchQueue.main.async                // Hilo para los efectos visuales del menú lateral
        {
            self.blurView.layer.cornerRadius   = 15                                     // Efecto para los bordes redondeados del menú lateral
            self.sideView.layer.shadowColor    = UIColor.black.cgColor                  // Efecto de sombra al View del menú
            self.sideView.layer.shadowOpacity  = 1                                      // Opacidad de la sombra del menú
            self.sideView.layer.shadowOffset   = CGSize(width: 0, height: 10)           // Lados donde se refleja la sombra creo
            self.sideView.layer.shadowRadius   = 3.5                                    // Grado de la sombra
            self.viewConstraint.constant       = -175                                   // Esconde el menú de la vista del usuario
            self.perfilMenu.layer.cornerRadius = self.perfilMenu.frame.size.width/2     // Imagen redonda del usuario dentro del menú
            self.perfilMenu.clipsToBounds      = true                                   // Es para que se apliquen los bordes redondos a la imagen.
            self.userName.text!                = nomUser                                // Asigno de la consulta el nombre del usuario en el menú lateral
        }*/
        
    }
    
    //******************** Función para mostrar el menú ********************//
    @IBAction func SideMenu(_ sender: UIBarButtonItem)
    {
        if isSlideMenuHidden
        {
            viewConstraint.constant = 0
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
        }
        else
        {
            viewConstraint.constant = -175
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
        }
        isSlideMenuHidden = !isSlideMenuHidden
    }
    
    //******************** Función propia del MapKit para visualizar los diferentes colores de los Pinnes ********************//
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        let identifier = "PinAnnotation"
        if annotation is PinAnnotation
        {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
            if annotationView == nil
            {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView!.canShowCallout = true
                let btn = UIButton(type: .detailDisclosure)
                annotationView!.rightCalloutAccessoryView = btn
            }
            else
            {
                annotationView!.annotation = annotation
            }
            if let annotation = annotation as? PinAnnotation
            {
                annotationView?.pinTintColor = annotation.pinTinColor
            }
            return annotationView
        }
        return nil
    }
    
    @IBAction func consultaReportes(_ sender: UIButton)
    {
        self.PeticionUserReportes()
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)
    {
        let capital = view.annotation as! PinAnnotation
        typeRepo = capital.title!
        let placeInfo = capital.coordinate.latitude
        let placeInfi = capital.coordinate.longitude
        DispatchQueue.main.async
        {
            let reportes = self.realm.objects(Reportes.self)
            for reportes in reportes
            {
                if reportes.latitud == String(placeInfo) && reportes.longitud == String(placeInfi)
                {
                    idReporte = reportes.idReporte
                }
            }
        }
        let mainTabController = self.storyboard?.instantiateViewController(withIdentifier: "PopUpDetallesVC") as! PopUpDetallesVC
        self.present(mainTabController, animated: true, completion: nil)
    }
    
    //******************** Función para obtener la ubicación del usuario y agregarla al mapa ********************//
    func MarcadorUbicacion()
    {
        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(Double(Latitude)!, Double(Longitude)!)
        let pin = PinAnnotation(id: "Ubicación", title: "Usted está aquí", subtitle: "Verifique la Zona !", coordinate: myLocation, pinTinColor: .black)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        mapView.setRegion(region, animated: true)
        self.mapView.addAnnotation(pin)
    }
    
    //******************** Consulta de los datos del usuario en la base de datos ********************//
    func consulta()
    {
        let usuario = self.realm.objects(Usuario.self)
        for user in usuario
        {
            nomUser = user.nombreUsuario
            tokenSB = user.tokenSiliconBear
            print("*******************************************")
            print(user.tokenSiliconBear)
        }
    }
    
    func CosultaReportes()
    {
        let reportes = self.realm.objects(Reportes.self)
        for reportes in reportes
        {
            self.addMarkers(lat: reportes.latitud, log: reportes.longitud, type: reportes.tipoReporte, id: reportes.idReporte)
        }
    }
    
    //******************** Función para agregar los reportes globales al mapa ********************//
    func addMarkers(lat:String, log:String, type:String, id:String)
    {
        let marcadores:CLLocationCoordinate2D = CLLocationCoordinate2DMake(Double(lat)!, Double(log)!)
        switch type
        {
            case "1":
                let pin = PinAnnotation(id: id, title: "Robo", subtitle: "", coordinate: marcadores, pinTinColor: .brown)
                self.mapView.addAnnotation(pin)
            case "2":
                let pin = PinAnnotation(id: id, title: "Asalto", subtitle: "", coordinate: marcadores, pinTinColor: .blue)
                self.mapView.addAnnotation(pin)
            case "3":
                let pin = PinAnnotation(id: id, title: "Acoso", subtitle: "", coordinate: marcadores, pinTinColor: .cyan)
                self.mapView.addAnnotation(pin)
            case "4":
                let pin = PinAnnotation(id: id, title: "Vandalismo", subtitle: "", coordinate: marcadores, pinTinColor: .yellow)
                self.mapView.addAnnotation(pin)
            case "5":
                let pin = PinAnnotation(id: id, title: "Pandillerismo", subtitle: "", coordinate: marcadores, pinTinColor: .orange)
                self.mapView.addAnnotation(pin)
            case "6":
                let pin = PinAnnotation(id: id, title: "Violación", subtitle: "", coordinate: marcadores, pinTinColor: .green)
                self.mapView.addAnnotation(pin)
            case "7":
                let pin = PinAnnotation(id: id, title: "Secuentro o Tentativa", subtitle: "", coordinate: marcadores, pinTinColor: .gray)
                self.mapView.addAnnotation(pin)
            case "8":
                let pin = PinAnnotation(id: id, title: "Asesinato", subtitle: "", coordinate: marcadores, pinTinColor: .red)
                self.mapView.addAnnotation(pin)
        default:
            print("no se la neta alv")
        }
    }
    
    func addMarkersUser(lat:String, log:String, type:String, id:String)
    {
        DispatchQueue.main.async
        {
            let marcadores:CLLocationCoordinate2D = CLLocationCoordinate2DMake(Double(lat)!, Double(log)!)
            switch type
            {
            case "1":
                let pin = PinAnnotation(id: id, title: "Robo", subtitle: "", coordinate: marcadores, pinTinColor: .brown)
                self.mapViewReporte.addAnnotation(pin)
            case "2":
                let pin = PinAnnotation(id: id, title: "Asalto", subtitle: "", coordinate: marcadores, pinTinColor: .blue)
                self.mapViewReporte.addAnnotation(pin)
            case "3":
                let pin = PinAnnotation(id: id, title: "Acoso", subtitle: "", coordinate: marcadores, pinTinColor: .cyan)
                self.mapViewReporte.addAnnotation(pin)
            case "4":
                let pin = PinAnnotation(id: id, title: "Vandalismo", subtitle: "", coordinate: marcadores, pinTinColor: .yellow)
                self.mapViewReporte.addAnnotation(pin)
            case "5":
                let pin = PinAnnotation(id: id, title: "Pandillerismo", subtitle: "", coordinate: marcadores, pinTinColor: .orange)
                self.mapViewReporte.addAnnotation(pin)
            case "6":
                let pin = PinAnnotation(id: id, title: "Violación", subtitle: "", coordinate: marcadores, pinTinColor: .green)
                self.mapViewReporte.addAnnotation(pin)
            case "7":
                let pin = PinAnnotation(id: id, title: "Secuentro o Tentativa", subtitle: "", coordinate: marcadores, pinTinColor: .gray)
                self.mapViewReporte.addAnnotation(pin)
            case "8":
                let pin = PinAnnotation(id: id, title: "Asesinato", subtitle: "", coordinate: marcadores, pinTinColor: .red)
                self.mapViewReporte.addAnnotation(pin)
            default:
                print("no se la neta alv")
            }
        }
    }
    
    //******************** Función para realizar la petición ********************//
    func PeticionUserReportes()
    {
        DispatchQueue.main.async
        {
                let parameters      = ["nombreUsuario": nomUser, "tokenSiliconBear":tokenSB, "ubicacionUsuario": userLocation]  // variable para el cuerpo de la petición
                guard let url       = URL(string: URLPeticion + "/Modular/API/ActualizarMisReportes.php") else { return }       // URL a quien se hace la petición
                var request         = URLRequest(url: url)                                                                      // No supe bien xD
                request.httpMethod  = "POST"                                                                                    // Selección del tipo de método
                request.addValue(   "application/json", forHTTPHeaderField: "Content-Type")                                     // aplica un formato especial para el cuerpo
                guard let httpBody  = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }      // conversión de parámetros a JSON
                request.httpBody    = httpBody                                                                                  // envío de parámetros
                self.JSONReportesUser(request: request)                                                                             // Respuesta de cliente HTTP
        }
    }
    
    //******************** Función para interpretar la respuesta ********************//
    func JSONReportesUser(request:URLRequest)
    {
        let seccion = URLSession.shared
        seccion.dataTask(with: request)
        {   (data, response, error) in
            guard let data  = data else { return }
            do
            {
                guard let json  = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else { return }
                let reportes     = ReportesUsuario(value: json)
                DispatchQueue.main.async                                                                // Hilo para comprobar que se realizó bien la petición
                {
                    if reportes.codigoRespuesta == "200"                                                // Para el caso correcto
                    {
                        for repo  in reportes.reportes                                                  // recorrido de arreglo en los reportes
                        {
                            self.addMarkersUser(lat:  repo.latitud,
                                            log:  repo.longitud,
                                            type: repo.tipoReporte,
                                            id:   repo.idReporte);                                      // LLama la función para agregar los marcadores.
                        }
                        
                    }
                    else                                                                                // Para el caso erroneo
                    {
                        self.createAlertTipoError(tittle: "¡Upps!", message: reportes.mensajeRespuesta) // Mostramos alerta de error en la petición.
                    }
                }
            }
            catch let jsonErr
            {
                print("Error de serialización json:", jsonErr)
            }
        }.resume()
    }
    
    //******************** Función para realizar la petición ********************//
    func Peticio()
    {
        DispatchQueue.main.async
        {
            let parameters      = ["nombreUsuario": nomUser, "tokenSiliconBear":tokenSB, "ubicacionUsuario": userLocation]  // variable para el cuerpo de la petición
            guard let url       = URL(string: URLPeticion + "/Modular/API/MostrarReportesGlobales.php") else { return }      // URL a quien se hace la petición
            var request         = URLRequest(url: url)                                                                      // No supe bien xD
            request.httpMethod  = "POST"                                                                                    // Selección del tipo de método
            request.addValue(   "application/json", forHTTPHeaderField: "Content-Type")                                     // aplica un formato especial para el cuerpo
            guard let httpBody  = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }      // conversión de parámetros a JSON
            request.httpBody    = httpBody                                                                                  // envío de parámetros
            self.JSONReportes(request: request)                                                                             // Respuesta de cliente HTTP
        }
    }
    
    //******************** Función para interpretar la respuesta ********************//
    func JSONReportes(request:URLRequest)
    {
        let seccion = URLSession.shared
        seccion.dataTask(with: request)
        {   (data, response, error) in
            guard let data  = data else { return }
            do
            {
                guard let json  = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else { return }
                let reportes     = ReportesGlobales(value: json)
                DispatchQueue.main.async                                                                // Hilo para comprobar que se realizó bien la petición
                {
                    if reportes.codigoRespuesta == "200"                                                // Para el caso correcto
                    {
                        for repo  in reportes.reportes                                                  // recorrido de arreglo en los reportes
                        {
                            
                            self.addMarkers(lat:  repo.latitud,
                                            log:  repo.longitud,
                                            type: repo.tipoReporte,
                                            id:   repo.idReporte);                                      // LLama la función para agregar los marcadores.
                        }
                        DispatchQueue.main.async                                                       // Hilo para guardar los reportes en la Base Local
                        {
                            try! self.realm.write
                            {
                                self.realm.add(reportes.reportes)
                                print("Se guardó como esperabamos")
                            }
                        }
                        
                    }
                    else                                                                                // Para el caso erroneo
                    {
                        self.createAlertTipoError(tittle: "¡Upps!", message: reportes.mensajeRespuesta) // Mostramos alerta de error en la petición.
                    }
                }
            }
            catch let jsonErr
            {
                print("Error de serialización json:", jsonErr)
            }
            }.resume()
    }
    
    func deleteReportes()
    {
        let result = realm.objects(Reportes.self)
        try! realm.write
        {
            realm.delete(result)
        }
    }
    
    //******************** Solo una plantilla de una Alerta ********************//
    func createAlertTipoError(tittle:String, message:String)
    {
        let alert = UIAlertController(title: tittle, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //******************** Función para mostrar el color de los iconos del TabBar rojo ********************//
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.tintColor = UIColor.red
    }
    
    @IBAction func prueba(_ sender: UIButton)
    {
        let mainTabController = storyboard?.instantiateViewController(withIdentifier: "PopUpDetallesReportesVC") as! PopUpDetallesReportesVC
        present(mainTabController, animated: true, completion: nil)
    }
    
    func changeImage(button: UIButton, onImage: UIImage, offImage:UIImage)
    {
        if button.currentImage == offImage{
            button.setImage(onImage, for: .normal)
        } else {
            button.setImage(offImage, for: .normal)
        }
    }
    
    @IBAction func Reportar(_ sender: UIButton)
    {
        if floatyButton.currentImage == #imageLiteral(resourceName: "plus-2")
        {
            self.MarcadorUbicacionReportes()
            self.mapView.isHidden        = true
            self.mapViewReporte.isHidden = false
            self.popupReporte.isHidden   = false
            self.userReporte.isHidden    = false
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(LevantarReporte(sender:)))
            longPressGesture.minimumPressDuration = 0.5
            self.mapViewReporte.addGestureRecognizer(longPressGesture)
        }
    else
        {
            self.mapView.isHidden = false
            self.mapViewReporte.isHidden = true
            self.popupReporte.isHidden = true
            self.userReporte.isHidden = true
        }
        changeImage(button: sender, onImage: #imageLiteral(resourceName: "plus-2"), offImage: #imageLiteral(resourceName: "plus-3"))
    }
    
    func MarcadorUbicacionReportes()
    {
        let allAnnotations    = self.mapViewReporte.annotations
        self.mapViewReporte.removeAnnotations(allAnnotations)
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(Double(Latitude)!, Double(Longitude)!)
        let pin = PinAnnotation(id: "Ubicación", title: "Usted está aquí", subtitle: "Verifique la Zona !", coordinate: myLocation, pinTinColor: .black)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        mapViewReporte.setRegion(region, animated: true)
        self.mapViewReporte.addAnnotation(pin)
    }
    
    @objc func LevantarReporte(sender: UILongPressGestureRecognizer)
    {
        let location          = sender.location(in: mapViewReporte)
        let locCoor           = self.mapViewReporte.convert(location, toCoordinateFrom: self.mapViewReporte)
        let annotation        = MKPointAnnotation()
        annotation.coordinate = locCoor
        LatitudeReporte       = String(locCoor.latitude)
        LongitudeReporte      = String(locCoor.longitude)
        let allAnnotations    = self.mapViewReporte.annotations
        self.mapViewReporte.removeAnnotations(allAnnotations)
        self.mapViewReporte.addAnnotation(annotation)
    }

}
