//
//  ContactosYGrupos.swift
//  OjoMetropolitano
//
//  Created by Jesus Reynaga Rodriguez on 15/06/18.
//  Copyright © 2018 Silicon Bear. All rights reserved.
//

import Foundation
import RealmSwift

class Respuesta: Object
{
    @objc dynamic var codigoRespuesta:  Int = 0
    @objc dynamic var mensajeRespuesta: String = ""
    let amigos =                        List<String>()
    let grupos =                        List<Grupos>()
    
    
    override static func primaryKey() -> String?
    {
        return "codigoRespuesta"
    }
}

class Grupos: Object
{
    @objc dynamic var nombreGrupo: String = ""
    let miembros =                 List<String>()
    override static func primaryKey() -> String?
    {
        return "nombreGrupo"
    }
}

class RespuestaDeleteFriend: Object
{
    @objc dynamic var codigoRespuesta:  Int = 0
    @objc dynamic var mensaje:          String = ""
    
    override static func primaryKey() -> String?
    {
        return "codigoRespuesta"
    }
}
