//
//  ViewController.swift
//  Prueba 4
//
//  Created by Jesus Reynaga Rodriguez on 04/02/18.
//  Copyright © 2018 Silicon Bear. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import RealmSwift

@available(iOS 10.0, *)
class LoginVC:  UIViewController, CLLocationManagerDelegate
{

    let locationManager               = CLLocationManager()     // variable para obtener permisos de localización
    @IBOutlet weak var scrollView:      UIScrollView!           // variable para mostrarel mapa en el Activity
    @IBOutlet weak var nombreUsuario:   UITextField!            // variable para obtener el nombre del usuario
    @IBOutlet weak var contraseña:      UITextField!            // variable para obtener la contraseña
    var timer = Timer()                                         // variable para contrar el tiempo de espera
    let realm = try! Realm()
    
    //******************** Funación para actualizar la ubicación del usuario ********************//
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        DispatchQueue.main.async
        {
                let location = locations[0]                                     // no entendí bien esto jaja
                Latitude     = String(location.coordinate.latitude)             // asignación de la latitud a una variable
                Longitude    = String(location.coordinate.longitude)            // asignación de la longitud a una variable
                userLocation = String(location.coordinate.latitude) + "," +
                               String(location.coordinate.longitude);           // latitud y longitd juntas
        }
    }
    
    //******************** Main del Login ********************//
    override func viewDidLoad()
    {
        super.viewDidLoad()                                 // Main del Viewcontroller de la vista login
        locationManager.delegate = self                     // Variable para el delegado de los permisos
        locationManager.requestWhenInUseAuthorization()     // permisos del localización por parte del ususario
        locationManager.startUpdatingLocation()             // una vez asignados los permisos comenzar a localizar
    }
    
    //******************** Botón Login ********************//
    @IBAction func Login(_ sender: Any)
    {
        Peticion()
        //self.AccessToBar()
    }
    @IBAction func aux(_ sender: UIButton)
    {
        self.AccessToBar()
    }
    
    //******************** Función para llamar al TabBar ********************//
    func AccessToBar()
    {
        let mainTabController = storyboard?.instantiateViewController(withIdentifier: "MainTabController") as! MainTabController
        mainTabController.selectedViewController = mainTabController.viewControllers?[2]
        present(mainTabController, animated: true, completion: nil)
    }
    
    //******************** Función de la petición ********************//
    func Peticion()
    {
        DispatchQueue.main.async
        {
            self.TimerProgramado()
            let parameters      = ["nombreUsuario":self.nombreUsuario.text!, "contrasena":self.contraseña.text!, "ubicacionUsuario": "\(userLocation)"]
            guard let url       = URL(string: URLPeticion + "/API/IniciarSesion.php") else { return }
            var request         = URLRequest(url: url)
            request.httpMethod  = "POST"
            request.addValue(   "application/json", forHTTPHeaderField: "Content-Type")
            guard let httpBody  = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
            request.httpBody    = httpBody
            self.JSON(request: request)
        }
    }
    
    //******************** Función para obtener los datos del usuario ********************//
    func JSON(request:URLRequest)
    {
        let seccion = URLSession.shared
        seccion.dataTask(with: request)
        {   (data, response, error) in
            guard let data  = data else { return }
            do
            {
                guard let json  = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else { return }
                let usuario     = Usuario(value: json)
                nomUser         = usuario.nombreUsuario
                tokenSB         = usuario.tokenSiliconBear
                self.timer.invalidate()
                DispatchQueue.main.async
                {
                    if usuario.codigoRespuesta == "200"
                    {
                        self.deleteUsuario()
                        DispatchQueue.main.async
                        {
                            try! self.realm.write
                            {
                                self.realm.add(usuario)
                                print("Se guardó como esperabamos")
                            }
                        }
                        self.AccessToBar()
                    }
                    else
                    {
                        self.createAlertTipoError(tittle: "¡Upps!", message: usuario.mensajeRespuesta)
                    }
                }
                
            }
            catch let jsonErr
            {
                print("Error de serialización json:", jsonErr)
            }
        }.resume()
    }
    
    func deleteUsuario()
    {
        let result = realm.objects(Usuario.self)
        print(result)
        try! realm.write
        {
            realm.delete(result)
        }
    }
    
    //******************** Función de tiempo para determinar si ha respondido el servidor ********************//
    func TimerProgramado()
    {
        timer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(self.RecargarTableView), userInfo: nil, repeats: true)
    }
    
    //******************** Complemento del timer ********************//
    @objc func RecargarTableView()
    {
        createAlertTipoError(tittle: "¡Upps!", message: "Parece que no se pudo establecer una conexión.")
    }
    
    //******************** Solo una plantilla de una alerta ********************//
    func createAlertTipoError(tittle:String, message:String)
    {
        let alert = UIAlertController(title: tittle, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

