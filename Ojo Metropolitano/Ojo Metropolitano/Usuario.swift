//
//  Usuario.swift
//  Ojo Metropolitano
//
//  Created by Jesus Reynaga Rodriguez on 28/03/18.
//  Copyright © 2018 Silicon Bear. All rights reserved.
//

import Foundation
import RealmSwift

class ValidarSesion: Object
{
    @objc dynamic var tokenSiliconBear: String = ""
    @objc dynamic var codigoRespuesta:  String = ""
    @objc dynamic var mensajeRespuesta: String = ""
    
    override static func primaryKey() -> String?
    {
        return "codigoRespuesta"
    }
}

class Usuario: Object
{
    @objc dynamic var nombreUsuario:    String = ""
    @objc dynamic var celular:          String = ""
    @objc dynamic var correo:           String = ""
    @objc dynamic var nombres:          String = ""
    @objc dynamic var apellidoPaterno:  String = ""
    @objc dynamic var apellidoMaterno:  String = ""
    @objc dynamic var imagenPerfil:     String = ""
    @objc dynamic var tokenSiliconBear: String = ""
    @objc dynamic var codigoRespuesta:  String = ""
    @objc dynamic var mensajeRespuesta: String = ""
    
    override static func primaryKey() -> String?
    {
        return "nombreUsuario"
    }
}
