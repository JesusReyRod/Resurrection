//
//  LeventarReporteVC.swift
//  Ojo Metropolitano
//
//  Created by Jesus Reynaga Rodriguez on 23/02/18.
//  Copyright © 2018 Silicon Bear. All rights reserved.
//


import UIKit
import MapKit
import CoreLocation

var LatitudeReporte:     String = ""
var LongitudeReporte:    String = ""

class LeventarReporteVC: UIViewController, MKMapViewDelegate
{

    @IBOutlet weak var mapViewReporte:   MKMapView!                         // variable para poder mostrar el mapa dentro del ViewController
    let span:MKCoordinateSpan          = MKCoordinateSpanMake(0.01, 0.01)   // variable para enfocar la cámara del mapa
    
    //******************** Main del view controller ********************//
    override func viewDidLoad()
    {
        super.viewDidLoad()
        mapViewReporte.delegate = self
        MarcadorUbicacion()
    }
    
    //******************** Función propia del mapview para visualizar el marcador de un color ********************//
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        var annotationView = mapViewReporte.dequeueReusableAnnotationView(withIdentifier: "myAnnotation") as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myAnnotation")
        } else {
            annotationView?.annotation = annotation
        }
        
        if let annotation = annotation as? PinAnnotation {
            annotationView?.pinTintColor = annotation.pinTinColor
        }
        return annotationView
    }
    
    //******************** Funación para crear un marcador con la ubicación del usuario ********************//
    func MarcadorUbicacion()
    {
        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(Double(Latitude)!, Double(Longitude)!)
        let pin = PinAnnotation(id: "Mi Ubicacion", title: "Usted está aquí", subtitle: "Verifique la Zona !", coordinate: myLocation, pinTinColor: .purple)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        mapViewReporte.setRegion(region, animated: true)
        self.mapViewReporte.addAnnotation(pin)
    }
    
    //******************** Funación para arrastrar el pin o marcador ********************//
    @IBAction func LevantarReporte(_ sender: UILongPressGestureRecognizer)
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
    
    //******************** Funación para desabilitar el tabBar ********************//
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.tintColor = UIColor.black
    }
}
