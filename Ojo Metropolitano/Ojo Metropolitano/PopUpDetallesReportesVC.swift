//
//  PopUpDetallesReportesVC.swift
//  Ojo Metropolitano
//
//  Created by Jesus Reynaga Rodriguez on 06/04/18.
//  Copyright © 2018 Silicon Bear. All rights reserved.
//

import UIKit

class PopUpDetallesReportesVC: UIViewController {

    @IBOutlet weak var fechaReporte:   UILabel!
    @IBOutlet weak var autor:          UILabel!
    @IBOutlet weak var tipoReporte:    UILabel!
    @IBOutlet weak var fechaIncidente: UILabel!
    @IBOutlet weak var descripcion:    UITextView!
    @IBOutlet weak var popUp: UIView!
    
    override func viewDidLoad()
    {
        DispatchQueue.main.async
        {
            
        }
        super.viewDidLoad()
        self.popUp.layer.cornerRadius = 10
        //self.Peticion()
    }

    /*func Peticion()
    {
        DispatchQueue.main.async
            {
                let parameters      = ["idReporte": idReporte, "nombreUsuario": nomUser, "tokenSiliconBear": tokenSB, "ubicacionUsuario": "\(userLocation)"]
                guard let url       = URL(string: URLPeticion + "Modular/API/MostrarDetallesReporte.php") else { return }
                var request         = URLRequest(url: url)
                request.httpMethod  = "POST"
                request.addValue    ( "application/json", forHTTPHeaderField: "Content-Type")
                guard let httpBody  = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
                request.httpBody    = httpBody
                self.JSON(request: request)
        }
    }
    
    func JSON(request:URLRequest)
    {
        let seccion = URLSession.shared
        seccion.dataTask(with: request)
        {   (data, response, error) in
            guard let data  = data else { return }
            do
            {
                guard let json  = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else { return }
                let reporte     = DetallesReporte(value: json)
                DispatchQueue.main.async
                    {
                        if reporte.codigoRespuesta == "200"
                        {
                            for repo  in reporte.reportes
                            {
                                self.fechaReporte.text   = repo.fechaReporte
                                self.autor.text          = repo.autorReporte
                                self.tipoReporte.text    = typeRepo
                                self.fechaIncidente.text = repo.fechaIncidente
                                self.descripcion.text    = repo.descripcion
                            }
                        }
                        else
                        {
                            self.createAlertTipoError(tittle: "¡Upps!", message: reporte.mensajeRespuesta)
                        }
                }
                
            }
            catch let jsonErr
            {
                print("Error de serialización json:", jsonErr)
            }
            }.resume()
    }*/
    
    func createAlertTipoError(tittle:String, message:String)
    {
        let alert = UIAlertController(title: tittle, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func cerrar(_ sender: UIButton)
    {
        dismiss(animated: true, completion: nil)
    }
}
