//
//  SearchResultCell.swift
//  StoreSearch
//
//  Created by Benjamin Jaramillo on 23/02/24.
//

import UIKit

// Definición de la clase SearchResultCell, una subclase de UITableViewCell
class SearchResultCell: UITableViewCell {
    // Outlets para las etiquetas de nombre y nombre del artista, y la imagen de la obra de arte
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var artworkImageView: UIImageView!
    
    var downloadTask: URLSessionDownloadTask?

    
    // Función llamada cuando la celda se carga desde el archivo de interfaz
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Crea una vista personalizada para el fondo seleccionado de la celda
        let selectedView = UIView(frame: CGRect.zero)
        // Configura el color de fondo seleccionado con un tono semitransparente del color "SearchBar"
        selectedView.backgroundColor = UIColor(named: "SearchBar")?.withAlphaComponent(0.5)
        // Asigna la vista personalizada como fondo seleccionado de la celda
        selectedBackgroundView = selectedView
    }

    // Función llamada cuando se selecciona la celda
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Aquí puedes realizar cualquier configuración adicional de la celda para el estado seleccionado
    }
    
    override func prepareForReuse() {
      // Llama al método de la superclase para asegurarse de que cualquier preparación adicional se realice
      super.prepareForReuse()
      
      // Cancela la tarea de descarga en curso, si existe
      downloadTask?.cancel()
      
      // Establece la tarea de descarga en nil para indicar que no hay ninguna descarga en curso
      downloadTask = nil
    }

    
    // MARK: - Helper Methods
    func configure(for result: SearchResult) {
      // Asigna el nombre del resultado al texto del `nameLabel`
      nameLabel.text = result.name

      // Verifica si el nombre del artista está vacío
      if result.artist.isEmpty {
        // Si está vacío, asigna "Unknown" al `artistNameLabel`
        artistNameLabel.text = "Unknown"
      } else {
        // Si no está vacío, asigna el nombre del artista y el tipo al `artistNameLabel`
        artistNameLabel.text = String(format: "%@ (%@)", result.artist, result.type)
      }

      // Asigna una imagen por defecto al `artworkImageView`
      artworkImageView.image = UIImage(systemName: "square")
      
      // Verifica si la URL de la imagen pequeña es válida
      if let smallURL = URL(string: result.imageSmall) {
        // Si es válida, inicia la descarga de la imagen
        downloadTask = artworkImageView.loadImage(url: smallURL)
      }
    }

}

