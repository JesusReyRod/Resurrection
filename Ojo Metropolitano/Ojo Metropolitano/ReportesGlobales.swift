//
//  ReportesGlobales.swift
//  Prueba 4
//
//  Created by Jesus Reynaga Rodriguez on 18/02/18.
//  Copyright © 2018 Silicon Bear. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class ReportesGlobales: Object
{
    @objc dynamic var codigoRespuesta:  String = ""
    @objc dynamic var mensajeRespuesta: String = ""
    let reportes =                      List<Reportes>()
    
    override static func primaryKey() -> String?
    {
        return "codigoRespuesta"
    }
}

class Reportes: Object
{
    @objc dynamic var idReporte:      String = ""
    @objc dynamic var tipoReporte:    String = ""
    @objc dynamic var latitud:        String = ""
    @objc dynamic var longitud:       String = ""
    @objc dynamic var fechaIncidente: String = ""
    
    override static func primaryKey() -> String?
    {
        return "idReporte"
    }
}

class ReportesUsuario: Object
{
    @objc dynamic var codigoRespuesta:  String = ""
    @objc dynamic var mensajeRespuesta: String = ""
    let reportes =                      List<UsuarioReportes>()
    
    override static func primaryKey() -> String?
    {
        return "codigoRespuesta"
    }
}

class UsuarioReportes: Object
{
    @objc dynamic var idReporte:      String = ""
    @objc dynamic var tipoReporte:    String = ""
    @objc dynamic var latitud:        String = ""
    @objc dynamic var longitud:       String = ""
    @objc dynamic var fechaIncidente: String = ""
    @objc dynamic var descripcion:    String = ""
    @objc dynamic var evidencia:      String = ""
    @objc dynamic var fechaReporte:   String = ""
    
    override static func primaryKey() -> String?
    {
        return "idReporte"
    }
}

class LevantarReporte: Object
{
    @objc dynamic var codigoRespuesta:      String = ""
    @objc dynamic var mensajeRespuesta:     String = ""
    
    override static func primaryKey() -> String?
    {
        return "codigoRespuesta"
    }
}

class AgregarLugares: Object
{
    @objc dynamic var codigoRespuesta:      String = ""
    @objc dynamic var mensajeRespuesta:     String = ""

    override static func primaryKey() -> String?
    {
        return "codigoRespuesta"
    }
}

class Detalles: Object
{
    @objc dynamic var codigoRespuesta:      String = ""
    @objc dynamic var mensajeRespuesta:     String = ""
    let reporte =             ReporteInfo()
    
    override static func primaryKey() -> String?
    {
        return "codigoRespuesta"
    }

}

class ReporteInfo: Object
{
    @objc dynamic var idReporte:      String = ""
    @objc dynamic var tipoReporte:    String = ""
    @objc dynamic var autorReporte:   String = ""
    @objc dynamic var latitud:        String = ""
    @objc dynamic var longitud:       String = ""
    @objc dynamic var fechaIncidente: String = ""
    @objc dynamic var descripcion:    String = ""
    @objc dynamic var evidencia:      String = ""
    @objc dynamic var fechaReporte:   String = ""
    
    override static func primaryKey() -> String?
    {
        return "autorReporte"
    }
    
}

struct detalleRepo: Decodable
{
    let codigoRespuesta:      String
    let mensajeRespuesta:     String
    let reporte:  Repoinfo
}

struct Repoinfo: Decodable
{
    let idReporte:      String
    let tipoReporte:    String
    let autorReporte:   String
    let latitud:        String
    let longitud:       String
    let fechaIncidente: String
    let descripcion:    String
    let evidencia:      String
    let fechaReporte:   String
}

/*class DetallesReportes: Object
{
    @objc dynamic var codigoRespuesta:      String = ""
    @objc dynamic var mensajeRespuesta:     String = ""
    let reporte =                          List<DetailReporte>()
    
    override static func primaryKey() -> String?
    {
        return "codigoRespuesta"
    }
 
}
 
class DetailReporte: Object
{
    @objc dynamic var idReporte:      String = ""
    @objc dynamic var tipoReporte:    String = ""
    @objc dynamic var autorReporte:   String = ""
    @objc dynamic var latitud:        String = ""
    @objc dynamic var longitud:       String = ""
    @objc dynamic var fechaIncidente: String = ""
    @objc dynamic var descripcion:    String = ""
    @objc dynamic var evidencia:      String = ""
    @objc dynamic var fechaReporte:   String = ""

    override static func primaryKey() -> String?
    {
        return "idReporte"
    }
}*/

 
 
/*class DetalleReporte: Object
{
    @objc dynamic var idReporte:      String = ""
    @objc dynamic var tipoReporte:    String = ""
    @objc dynamic var autorReporte:   String = ""
    @objc dynamic var latitud:        String = ""
    @objc dynamic var longitud:       String = ""
    @objc dynamic var fechaIncidente: String = ""
    @objc dynamic var descripcion:    String = ""
    @objc dynamic var evidencia:      String = ""
    @objc dynamic var fechaReporte:   String = ""
    
    override static func primaryKey() -> String?
    {
        return "idReporte"
    }
}*/
