//
//  ValidarSesionVC.swift
//  Ojo Metropolitano
//
//  Created by Jesus Reynaga Rodriguez on 06/05/18.
//  Copyright © 2018 Silicon Bear. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import RealmSwift

//******************** Variables globales temporables ********************//
var Latitude:     String = ""
var Longitude:    String = ""
var nomUser:      String = ""
var tokenSB:      String = ""
var userLocation: String = ""
var typeRepo:     String = ""
var idReporte:    String = ""

@available(iOS 10.0, *)
class ValidarSesionVC: UIViewController, CLLocationManagerDelegate
{
    let locationManager               = CLLocationManager()     // variable para obtener permisos de localización
    let realm = try! Realm()
    var exito = false
    
    override func viewDidLoad()
    {
        DispatchQueue.main.async
        {
            self.locationManager.delegate = self                     // Variable para el delegado de los permisos
            self.locationManager.requestWhenInUseAuthorization()     // permisos del localización por parte del ususario
            self.locationManager.startUpdatingLocation()             // una vez asignados los permisos comenzar a localizar
            self.PeticionValidarSesion()
        }
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 4)
        {
            if self.exito == false
            {
                self.AccessLogin()
            }
            else
            {
                self.AccessToBar()
            }
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        DispatchQueue.main.async
        {
            let location = locations[0]                                     // no entendí bien esto jaja
            Latitude     = String(location.coordinate.latitude)             // asignación de la latitud a una variable
            Longitude    = String(location.coordinate.longitude)            // asignación de la longitud a una variable
            userLocation = String(location.coordinate.latitude) + "," +
                String(location.coordinate.longitude);
        }
    }
    
    //******************** Función para la petición de la valicación de sesión ********************//
    func PeticionValidarSesion()
    {
        DispatchQueue.main.async
        {
            let usuario = self.realm.objects(Usuario.self)
            for user in usuario
            {
                nomUser = user.nombreUsuario
                tokenSB = user.tokenSiliconBear
            }
            let parameters      = ["nombreUsuario": nomUser, "tokenSiliconBear": tokenSB, "ubicacionUsuario": "\(userLocation)"]
            guard let url       = URL(string: URLPeticion + "/API/ValidarSesion.php") else { return }
            var request         = URLRequest(url: url)
            request.httpMethod  = "POST"
            request.addValue    ( "application/json", forHTTPHeaderField: "Content-Type")
            guard let httpBody  = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
            request.httpBody    = httpBody
            self.JSONValidarSesion(request: request)
        }
    }
    
    //******************** Función para interpretar el respueta de la petición ********************//
    func JSONValidarSesion(request:URLRequest)
    {
        let seccion = URLSession.shared
        seccion.dataTask(with: request)
        {   (data, response, error) in
            guard let data  = data else { return }
            do
            {
                guard let json  = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else { return }
                let validar     = ValidarSesion(value: json)
                tokenSB         = validar.tokenSiliconBear
                DispatchQueue.main.async
                {
                    if validar.codigoRespuesta == "200"
                    {
                        self.exito = true
                        DispatchQueue.main.async
                        {
                                let usuario = self.realm.objects(Usuario.self).filter("nombreUsuario == %@", nomUser).first
                                print(usuario as Any)
                                try! self.realm.write {
                                    usuario!.tokenSiliconBear = tokenSB
                                }
                                print(usuario as Any)
                        }
                    }
                    else
                    {
                        self.createAlertTipoError(tittle: "¡Upps!", message: validar.mensajeRespuesta)
                        
                    }
                }
                
            }
            catch let jsonErr
            {
                print("Error de serialización json:", jsonErr)
            }
            }.resume()
    }
    
    //******************** Solo una plantilla de una alerta ********************//
    func createAlertTipoError(tittle:String, message:String)
    {
        let alert = UIAlertController(title: tittle, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            self.AccessLogin()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //******************** Función para llamar al TabBar ********************//
    func AccessToBar()
    {
        let mainTabController = storyboard?.instantiateViewController(withIdentifier: "MainTabController") as! MainTabController
        mainTabController.selectedViewController = mainTabController.viewControllers?[2]
        present(mainTabController, animated: true, completion: nil)
    }
    
    //******************** Función para llamar al TabBar ********************//
    func AccessLogin()
    {
        let mainTabController = storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        present(mainTabController, animated: true, completion: nil)
    }
}
