//
//  SearchResult.swift
//  StoreSearch
//
//  Created by Benjamin Jaramillo on 03/02/24.
//


import Foundation

// Clase que representa un objeto que contiene un array de SearchResult
class ResultArray: Codable {
    // Propiedad que indica el número de resultados en el array
    var resultCount = 0
    // Propiedad que almacena los resultados de la búsqueda
    var results = [SearchResult]()
}


// Sobrecarga del operador "<" para comparar dos objetos SearchResult
func < (lhs: SearchResult, rhs: SearchResult) -> Bool {
    // Compara los nombres de los dos objetos SearchResult utilizando el método localizedStandardCompare
    return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
}


class SearchResult: Codable, CustomStringConvertible {
  var artistName: String? = ""
  var trackName: String? = ""
  var kind: String? = ""
  var trackPrice: Double? = 0.0
  var currency = ""
  var imageSmall = ""
  var imageLarge = ""
  var trackViewUrl: String?
  var collectionName: String?
  var collectionViewUrl: String?
  var collectionPrice: Double?
  var itemPrice: Double?
  var itemGenre: String?
  var bookGenre: [String]?

    // Enumeración que define las claves de codificación para decodificar los datos JSON
    enum CodingKeys: String, CodingKey {
        // Clave para el enlace de la imagen pequeña
        case imageSmall = "artworkUrl60"
        // Clave para el enlace de la imagen grande
        case imageLarge = "artworkUrl100"
        // Clave para el género del artículo
        case itemGenre = "primaryGenreName"
        // Clave para el género del libro
        case bookGenre = "genres"
        // Clave para el precio del artículo
        case itemPrice = "price"
        // Claves comunes para todos los tipos de elementos
        case kind, artistName, currency
        // Claves específicas para diferentes tipos de elementos
        case trackName, trackPrice, trackViewUrl // Para canciones
        case collectionName, collectionViewUrl, collectionPrice // Para álbumes o libros
    }


    // Propiedad computada que devuelve el nombre del elemento
    var name: String {
        // Utiliza el operador de fusión nula para devolver el primer valor no nulo entre trackName y collectionName
        // Si ambos son nulos, devuelve una cadena vacía
        return trackName ?? collectionName ?? ""
    }

    // Propiedad computada que devuelve la URL de la tienda del elemento
    var storeURL: String {
        // Utiliza el operador de fusión nula para devolver el primer valor no nulo entre trackViewUrl y collectionViewUrl
        // Si ambos son nulos, devuelve una cadena vacía
        return trackViewUrl ?? collectionViewUrl ?? ""
    }

    // Propiedad computada que devuelve el precio del elemento
    var price: Double {
        // Utiliza el operador de fusión nula para devolver el primer valor no nulo entre trackPrice, collectionPrice y itemPrice
        // Si todos son nulos, devuelve 0.0 como precio predeterminado
        return trackPrice ?? collectionPrice ?? itemPrice ?? 0.0
    }

    // Propiedad computada que devuelve el género del elemento
    var genre: String {
        // Comprueba si itemGenre tiene un valor
        if let genre = itemGenre {
            // Si itemGenre tiene un valor, lo devuelve
            return genre
        } else if let genres = bookGenre {
            // Si itemGenre es nulo pero bookGenre tiene un valor, une todos los géneros con una coma y espacio y lo devuelve
            return genres.joined(separator: ", ")
        }
        // Si tanto itemGenre como bookGenre son nulos, devuelve una cadena vacía
        return ""
    }


    // Propiedad computada que devuelve el tipo de elemento
    var type: String {
        // Obtiene el valor de kind o utiliza "audiobook" como valor predeterminado si kind es nulo
        let kind = self.kind ?? "audiobook"
        
        // Utiliza un switch para asignar un tipo basado en el valor de kind
        switch kind {
        case "album": return "Album"
        case "audiobook": return "Audio Book"
        case "book": return "Book"
        case "ebook": return "E-Book"
        case "feature-movie": return "Movie"
        case "music-video": return "Music Video"
        case "podcast": return "Podcast"
        case "software": return "App"
        case "song": return "Song"
        case "tv-episode": return "TV Episode"
        default: break
        }
        
        // Si el valor de kind no coincide con ninguno de los casos anteriores, devuelve "Unknown"
        return "Unknown"
    }

    // Propiedad computada que devuelve el nombre del artista
    var artist: String {
        // Utiliza el operador de fusión nula para obtener el valor de artistName o una cadena vacía si artistName es nulo
        return artistName ?? ""
    }

  
    // Propiedad computada que devuelve una descripción del resultado
    var description: String {
        // Utiliza interpolación de cadenas para construir la descripción con los valores de kind, name y artistName
        return "\nResult - Kind: \(kind ?? "None"), Name: \(name), Artist Name: \(artistName ?? "None")"
    }

}
