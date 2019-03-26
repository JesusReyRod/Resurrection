//
//  PopUpReportesViewController.swift
//  Ojo Metropolitano
//
//  Created by Jesus Reynaga Rodriguez on 08/05/18.
//  Copyright © 2018 Silicon Bear. All rights reserved.
//

import UIKit

class PopUpReportesVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var descripcion: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var viewTAP: UIView!
    @IBOutlet var tipoReportes:     [UIButton]!             // arreglo de botones para el dropDown menu
    @IBOutlet weak var plantilla: UIButton!
    @IBOutlet weak var imagenEvidencia: UIImageView!
    var typeReportes                = "0"                   // variable para almacenar el tipo de reporte
    var fecha                       = ""                    // variable para obtener la fecha del sistema
    
    
    
    
    override func viewDidLoad()
    {
        
        super.viewDidLoad()
        scrollView.layer.cornerRadius = 10
    }
    
    enum Delitos: String
    {
        case robo                = "Robo"
        case asalto              = "Asalto"
        case acoso               = "Acoso"
        case vandalismo          = "Vandalismo"
        case pandillerismo       = "Pandillerismo"
        case violación           = "Violación"
        case secuestro_tentativa = "Secuestro o tentativa"
        case asesinato           = "Asesinato"
    }
    
    @IBAction func handleSelection(_ sender: UIButton)
    {
        tipoReportes.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    
    //******************** Asignación de la variable tipo reporte según seleccione el usuario ********************//
    @IBAction func reportesTap(_ sender: UIButton)
    {
        
        guard let titulo = sender.currentTitle, let delitos = Delitos (rawValue: titulo) else {
            return
        }
        
        switch delitos {
        case .robo:
            typeReportes = "1"
            plantilla.setTitle("Robo", for: .normal)
        case .asalto:
            typeReportes = "2"
            plantilla.setTitle("Asalto", for: .normal)
        case .acoso:
            typeReportes = "3"
            plantilla.setTitle("Acoso", for: .normal)
        case .vandalismo:
            typeReportes = "4"
            plantilla.setTitle("Vandalismo", for: .normal)
        case .pandillerismo:
            typeReportes = "5"
            plantilla.setTitle("Pandillerismo", for: .normal)
        case .violación:
            typeReportes = "6"
            plantilla.setTitle("Violación", for: .normal)
        case .secuestro_tentativa:
            typeReportes = "7"
            plantilla.setTitle("Secuestro o tentativa", for: .normal)
        case .asesinato:
            typeReportes = "8"
            plantilla.setTitle("Asesinado", for: .normal)
        }
        
        tipoReportes.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func datePickerValueChanged(_ sender: UIDatePicker){
        
        // Create date formatter
        let dateFormatter: DateFormatter = DateFormatter()
        
        // Set date format
        dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a"
        
        // Apply date format
        let selectedDate: String = dateFormatter.string(from: sender.date)
        
        print("Selected value \(selectedDate)")
    }
    
    @IBAction func cancelar(_ sender: UIButton)
    {
        dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
        self.scrollView.endEditing(true)
    }
    
    @IBAction func showPicture(_ sender: UITapGestureRecognizer)
    {
        if imagenEvidencia.image != nil
        {
            DispatchQueue.main.async
            {
                let mainTabController = self.storyboard?.instantiateViewController(withIdentifier: "WatchImageVC") as! WatchImageVC
                mainTabController.ads_catch = (self.imagenEvidencia.image)!
                self.present(mainTabController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func selectPhoto(_ sender: UIButton)
    {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let acctionSheet = UIAlertController(title: "Selecciona una opción", message: " ", preferredStyle: .actionSheet)
        
        acctionSheet.addAction(UIAlertAction(title: "Cámara", style: .default, handler : {(action: UIAlertAction) in
            DispatchQueue.main.async
            {
                if UIImagePickerController.isSourceTypeAvailable(.camera)
                {
                    imagePickerController.sourceType = .camera
                    self.present(imagePickerController, animated: true, completion: nil)
                }
                else
                {
                    self.createAlert(tittle: "¡Error!", message: "No se puede acceder a la cámara")
                }
            }
            
        }))
        
        acctionSheet.addAction(UIAlertAction(title: "Galería", style: .default, handler : {(action: UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        
        acctionSheet.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler : nil))
        self.present(acctionSheet, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        imagenEvidencia.image = image
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func createAlert(tittle:String, message:String)
    {
        let alert = UIAlertController(title: tittle, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func changeDate(_ sender: Any)
    {
        self.datePicker.maximumDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        let strDate = dateFormatter.string(from: datePicker.date)
        fecha = strDate
        print(strDate)
    }
    
    @IBAction func levantarReporte(_ sender: UIButton)
    {
        if typeReportes != "0"  && descripcion.text != ""
        {
            self.Peticion()
        }
        else
        {
            self.createAlert(tittle: "Error", message: "No se ha seleccionado un tipo de reporte.")
        }
    }
    
    func Peticion()
    {
        DispatchQueue.main.async
        {
            let parameters      = ["tipoReporte": self.typeReportes,
                                   "nombreUsuario": nomUser,
                                   "latitud": LatitudeReporte,
                                   "longitud": LongitudeReporte,
                                   "fechaIncidente": self.fecha,
                                   "descripcion": self.self.descripcion.text,
                                   "evidencia": nil,
                                   "tokenSiliconBear": tokenSB,
                                   "ubicacionUsuario": userLocation]
            guard let url       = URL(string: URLPeticion + "/Modular/API/LevantarReporte.php") else { return }
            var request         = URLRequest(url: url)
            request.httpMethod  = "POST"
            request.addValue(   "application/json", forHTTPHeaderField: "Content-Type")
            guard let httpBody  = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
            request.httpBody    = httpBody
            self.JSONReportes(request: request)
        }
    }
    
    func JSONReportes(request:URLRequest)
    {
        let seccion = URLSession.shared
        seccion.dataTask(with: request)
        {   (data, response, error) in
            guard let data  = data else { return }
            do
            {
                //let reportes = try JSONDecoder().decode(LeventarReporte.self, from: data)
                guard let json  = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else { return }
                let reportes     = LevantarReporte(value: json)
                print(reportes.codigoRespuesta)
                print(reportes.mensajeRespuesta)
                DispatchQueue.main.async
                {
                    if reportes.codigoRespuesta == "200"
                    {
                        self.createAlertOK(tittle: "Correcto!", message: reportes.mensajeRespuesta)
                    }
                    else
                    {
                        self.createAlert(tittle: "¡Upps!", message: reportes.mensajeRespuesta)
                    }
                }
            }
            catch let jsonErr
            {
                print("Error de serialización json:", jsonErr)
            }
        }.resume()
    }
    
    //******************** Plantill de una alterta ********************//
    func createAlertOK(tittle:String, message:String)
    {
        let alert = UIAlertController(title: tittle, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
