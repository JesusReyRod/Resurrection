//
//  UserLugares.swift
//  Ojo Metropolitano
//
//  Created by Jesus Reynaga Rodriguez on 29/04/18.
//  Copyright © 2018 Silicon Bear. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class ConsultaLugares: Object
{
    @objc dynamic var codigoRespuesta:  String = ""
    @objc dynamic var mensajeRespuesta: String = ""
    let lugares =                       List<LugaresUsuario>()
    
    override static func primaryKey() -> String?
    {
        return "codigoRespuesta"
    }
}

class LugaresUsuario: Object
{
    @objc dynamic var idLugar:       String = ""
    @objc dynamic var tipoLugar:     String = ""
    @objc dynamic var nombreLugar:   String = ""
    @objc dynamic var latitudLugar:  String = ""
    @objc dynamic var longitudLugar: String = ""
    
    override static func primaryKey() -> String?
    {
        return "idLugar"
    }
}

class Busqueda: Object {
    @objc dynamic var codigoRespuesta:  Int = 0
    @objc dynamic var mensajeRespuesta: String = ""
    let usuarios =                      List<String>()
    
    override static func primaryKey() -> String?
    {
        return "codigoRespuesta"
    }
}

struct Busque: Decodable
{
    let codigoRespuesta:      String
    let mensajeRespuesta:     String
    let usuarios: [String] = []
}
