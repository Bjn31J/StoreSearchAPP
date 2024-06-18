//
//  SearchResult.swift
//  StoreSearch
//
//  Created by Benjamin Jaramillo on 03/02/24.
//


import Foundation

// Clase que representa un array de resultados de búsqueda.
class ResultArray: Codable {
  // Número de resultados.
  var resultCount = 0
  // Array de objetos SearchResult.
  var results = [SearchResult]()
}

// Operador de comparación para ordenar SearchResult por nombre.
func < (lhs: SearchResult, rhs: SearchResult) -> Bool {
  return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
}

// Clase que representa un resultado de búsqueda.
class SearchResult: Codable, CustomStringConvertible {
  // Nombre del artista.
  var artistName: String? = ""
  // Nombre de la pista o colección.
  var trackName: String? = ""
  // Tipo de media (album, song, etc.).
  var kind: String? = ""
  // Precio de la pista.
  var trackPrice: Double? = 0.0
  // Moneda del precio.
  var currency = ""
  // URL de la imagen pequeña.
  var imageSmall = ""
  // URL de la imagen grande.
  var imageLarge = ""
  // URL de la vista de la pista.
  var trackViewUrl: String?
  // Nombre de la colección.
  var collectionName: String?
  // URL de la vista de la colección.
  var collectionViewUrl: String?
  // Precio de la colección.
  var collectionPrice: Double?
  // Precio del ítem.
  var itemPrice: Double?
  // Género del ítem.
  var itemGenre: String?
  // Géneros del libro.
  var bookGenre: [String]?

  // Enum para mapear los nombres de las claves del JSON.
  enum CodingKeys: String, CodingKey {
    case imageSmall = "artworkUrl60"
    case imageLarge = "artworkUrl100"
    case itemGenre = "primaryGenreName"
    case bookGenre = "genres"
    case itemPrice = "price"
    case kind, artistName, currency
    case trackName, trackPrice, trackViewUrl
    case collectionName, collectionViewUrl, collectionPrice
  }

  // Propiedad calculada para obtener el nombre del ítem.
  var name: String {
    return trackName ?? collectionName ?? ""
  }

  // Propiedad calculada para obtener la URL de la tienda.
  var storeURL: String {
    return trackViewUrl ?? collectionViewUrl ?? ""
  }

  // Propiedad calculada para obtener el precio del ítem.
  var price: Double {
    return trackPrice ?? collectionPrice ?? itemPrice ?? 0.0
  }

  // Propiedad calculada para obtener el género del ítem.
  var genre: String {
    if let genre = itemGenre {
      return genre
    } else if let genres = bookGenre {
      return genres.joined(separator: ", ")
    }
    return ""
  }

  // Propiedad calculada para obtener el tipo de ítem.
  var type: String {
    let kind = self.kind ?? "audiobook"
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
    return "Unknown"
  }
  
  // Propiedad calculada para obtener el nombre del artista.
  var artist: String {
    return artistName ?? ""
  }
  
  // Propiedad calculada para obtener la descripción del ítem.
  var description: String {
    return "\nResult - Kind: \(kind ?? "None"), Name: \(name), Artist Name: \(artistName ?? "None")"
  }
}
