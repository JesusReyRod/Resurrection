//
//  AgregarLugarVC.swift
//  Ojo Metropolitano
//
//  Created by Jesus Reynaga Rodriguez on 31/03/18.
//  Copyright © 2018 Silicon Bear. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift

class AgregarLugarVC: UIViewController, MKMapViewDelegate
{

    @IBOutlet      var tiposLugares:  [UIButton]!                           // arreglo de botones para el DropDown menu
    @IBOutlet weak var popupAddPlace: UIView!                               // variable para efectos visuales
    @IBOutlet weak var mapView:       MKMapView!                            // variable para visulizar el mapa dentro del popup
    @IBOutlet weak var plantilla:     UIButton!
    @IBOutlet weak var nameLugar:     UITextField!                          // variable para obtener el nombre del lugar
    let span:MKCoordinateSpan       = MKCoordinateSpanMake(0.01, 0.01)      // variable global para el enfoque de cámara del mapa
    var typeLugar                   = "0"                                   // viable para determinar el tipo de lugar
    let realm = try! Realm()
    
    //******************** Main del popup ********************//
    override func viewDidLoad()
    {
        DispatchQueue.main.async
        {
            self.popupAddPlace.layer.cornerRadius   = 10                // aplica bordes curvos
            self.mapView.delegate                   = self              // muestra el mapa en el popup
        }
        super.viewDidLoad()
        MarcadorUbicacion()                                             // muestra la ubicación del usuario con un marcador
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)        
    }
    
    //******************** Función propia del popup para mostrar el marcador ********************//
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "myAnnotation") as? MKPinAnnotationView
        
        if annotationView == nil
        {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myAnnotation")
        } else {
            annotationView?.annotation = annotation
        }
        
        if let annotation = annotation as? PinAnnotation {
            annotationView?.pinTintColor = annotation.pinTinColor
        }
        return annotationView
    }
    
    //******************** Crea un marcador con la ubicación del usuario ********************//
    func MarcadorUbicacion()
    {
        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(Double(Latitude)!, Double(Longitude)!)
        let pin = PinAnnotation(id: "Mi Ubicacion", title: "Usted está aquí", subtitle: "Verifique la Zona !", coordinate: myLocation, pinTinColor: .black)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        mapView.setRegion(region, animated: true)
        self.mapView.addAnnotation(pin)
    }
    
    //******************** Función para desplegar el DropDown menu ********************//
    @IBAction func seleccion(_ sender: UIButton)
    {
        tiposLugares.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations:
            {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    
    //******************** Función para mostrar loss posibles valores del dropDown menu ********************//
    enum Lugares: String
    {
        case casa    = "Casa"
        case escuela = "Escuela"
        case trabajo = "Trabajo"
        case gym     = "GYM"
        case otro    = "Otro"
    }
    
    //******************** Asignación de la variable tipo lugar según seleccione el usuario ********************//
    @IBAction func tiposTap(_ sender: UIButton)
    {
        guard let titulo = sender.currentTitle, let lugar = Lugares (rawValue: titulo) else {
            return
        }
        
        switch lugar {
        case .casa:
            typeLugar = "1"
            print(typeLugar)
            plantilla.setTitle("Casa", for: .normal)
        case .escuela:
            typeLugar = "2"
            print(typeLugar)
            plantilla.setTitle("Escuela", for: .normal)
        case .trabajo:
            typeLugar = "3"
            print(typeLugar)
            plantilla.setTitle("Trabajo", for: .normal)
        case .gym:
            typeLugar = "4"
            print(typeLugar)
            plantilla.setTitle("GYM", for: .normal)
        case .otro:
            typeLugar = "5"
            print(typeLugar)
            plantilla.setTitle("Otro", for: .normal)
        }
        
        tiposLugares.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations:
                {
                    button.isHidden = !button.isHidden
                    self.view.layoutIfNeeded()
            })
        }
    }
    
    //******************** Función para realizar la petición ********************//
    func Peticion()
    {
        let parameters      = ["nombreUsuario": nomUser,
                              "tipoLugar": typeLugar,
                              "nombreLugar": nameLugar.text!,
                              "latitudLugar": LatitudeReporte,
                              "longitudLugar": LongitudeReporte,
                              "tokenSiliconBear": tokenSB,
                              "ubicacionUsuario": "\(userLocation)"];
        guard let url       = URL(string: URLPeticion + "/Modular/API/Lugares/AgregarLugar.php") else { return }
        var request         = URLRequest(url: url)
        request.httpMethod  = "POST"
        request.addValue(   "application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody  = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
        request.httpBody    = httpBody
        self.JSONReportes(request: request)
    }
    
    //******************** Función para interpretar la respuesta de la petición ********************//
    func JSONReportes(request:URLRequest)
    {
        let seccion = URLSession.shared
        seccion.dataTask(with: request)
        {   (data, response, error) in
            guard let data  = data else { return }
            do
            {
                guard let json  = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else { return }
                let addLugar    = AgregarLugares(value: json)
                print(addLugar.codigoRespuesta)
                print(addLugar.mensajeRespuesta)
                DispatchQueue.main.async
                {
                    if addLugar.codigoRespuesta == "200"
                    {
                        self.Update_lugares()
                        self.createAlertOK(tittle: "¡Correcto!", message: addLugar.mensajeRespuesta)
                        
                    }
                    else
                    {
                        self.createAlert(tittle: "¡Upps!", message: addLugar.mensajeRespuesta)
                    }
                }
            }
            catch let jsonErr
            {
                print("Error de serialización json:", jsonErr)
            }
        }.resume()
    }
    
    func Update_lugares()
    {
        DispatchQueue.main.async
        {
            let mis_lugares = MisLugaresVC()
            mis_lugares.Peticion()
        }
    }
    
    //******************** Función para crear una plantilla de alerta ********************//
    func createAlert(tittle:String, message:String)
    {
        let alert = UIAlertController(title: tittle, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func createAlertOK(tittle:String, message:String)
    {
        let alert = UIAlertController(title: tittle, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //******************** Función para poder arrastrar el pin o marcador a un punto en específico ********************//
    @IBAction func moveMarker(_ sender: UILongPressGestureRecognizer)
    {
        let location          = sender.location(in: mapView)
        let locCoor           = self.mapView.convert(location, toCoordinateFrom: self.mapView)
        let annotation        = MKPointAnnotation()
        annotation.coordinate = locCoor
        LatitudeReporte       = String(locCoor.latitude)
        LongitudeReporte      = String(locCoor.longitude)
        let allAnnotations    = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        self.mapView.addAnnotation(annotation)
    }
    
    //******************** Evento para crear retirar el teclado del View Controller ********************//
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
    }
    
    //******************** Función para cancelar la operación ********************//
    @IBAction func cancelar(_ sender: UIButton)
    {
        dismiss(animated: true, completion: nil)
    }
    
    //******************** Función para realizar agregar un lugar ********************//
    @IBAction func AgregarLugar(_ sender: UIButton)
    {
        if nameLugar.text != "" && typeLugar != "0"
        {
            self.Peticion()
        }
        else
        {
            self.createAlert(tittle: "Error", message: "Faltan datos para completar la operación.")
        }
    }
    
}
