//
//  PopUpDetallesVC.swift
//  Ojo Metropolitano
//
//  Created by Jesus Reynaga Rodriguez on 20/04/18.
//  Copyright © 2018 Silicon Bear. All rights reserved.
//

import UIKit

class PopUpDetallesVC: UIViewController {

    @IBOutlet weak var fechaReporte:   UILabel!
    @IBOutlet weak var autor:          UILabel!
    @IBOutlet weak var tipoReporte:    UILabel!
    @IBOutlet weak var fechaIncidente: UILabel!
    @IBOutlet weak var descripcion:    UITextView!
    @IBOutlet weak var scroll:         UIScrollView!
    @IBOutlet weak var evidencia:      UIImageView!
    
    override func viewDidLoad()
    {
        DispatchQueue.main.async
        {
            self.Peticion()
            self.scroll.layer.cornerRadius = 10
        }
        super.viewDidLoad()
        
    }

    func Peticion()
    {
        let parameters      = ["idReporte": idReporte, "nombreUsuario": nomUser, "tokenSiliconBear": tokenSB, "ubicacionUsuario": "\(userLocation)"]
        guard let url       = URL(string: URLPeticion + "/Modular/API/MostrarDetallesReporte.php") else { return }
        var request         = URLRequest(url: url)
        request.httpMethod  = "POST"
        request.addValue    ( "application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody  = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
        request.httpBody    = httpBody
        self.JSON(request: request)
    }
    
    func JSON(request:URLRequest)
    {
        let seccion = URLSession.shared
        seccion.dataTask(with: request)
        {   (data, response, error) in
            guard let data  = data else { return }
            do
            {
                let reportes = try JSONDecoder().decode(detalleRepo.self, from: data)
                DispatchQueue.main.async
                {
                    if reportes.codigoRespuesta == "200"
                    {
                        self.fechaReporte.text   = reportes.reporte.fechaReporte
                        self.autor.text          = reportes.reporte.autorReporte
                        self.tipoReporte.text    = typeRepo
                        self.fechaIncidente.text = reportes.reporte.fechaIncidente
                        self.descripcion.text    = reportes.reporte.descripcion
                        self.descripcion.font    = UIFont(name: "Helvetica Neue", size: 15)
                        self.descripcion.font    = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.light)
                    }
                    else
                    {
                        self.createAlertTipoError(tittle: "¡Upps!", message: reportes.mensajeRespuesta)
                    }
                }
            }
            catch let jsonErr
            {
                print("Error de serialización json:", jsonErr)
            }
        }.resume()
    }
    
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
    @IBAction func showEvidence(_ sender: UITapGestureRecognizer)
    {
        let mainTabController = self.storyboard?.instantiateViewController(withIdentifier: "WatchImageVC") as! WatchImageVC
        mainTabController.ads_catch = (self.evidencia.image)!
        self.present(mainTabController, animated: true, completion: nil)
    }
    
}
