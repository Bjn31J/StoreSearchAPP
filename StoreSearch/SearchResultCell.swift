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
}

