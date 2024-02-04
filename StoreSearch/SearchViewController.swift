//
//  ViewController.swift
//  StoreSearch
//
//  Created by Benjamin Jaramillo on 03/02/24.
//

import UIKit

class SearchViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var searchResults = [SearchResult]()
    var hasSearched = false
    
    // Sobrescribe la función viewDidLoad del ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ajusta el desplazamiento del contenido de la tabla
        // La propiedad contentInset agrega espacio adicional alrededor del contenido de la tabla
        tableView.contentInset = UIEdgeInsets(top: 47, left: 0, bottom: 0, right: 0)
        // El desplazamiento hacia abajo (top) se establece en 47 puntos para dejar espacio para otros elementos
        // Los otros valores de desplazamiento (left, bottom y right) se mantienen en cero
        // Esto significa que no hay desplazamiento adicional en esos lados
    }
}

// MARK: - Search Bar Delegate
// Extensión del SearchViewController que adopta el protocolo UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    
    // Función llamada cuando se presiona el botón de búsqueda en el teclado
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Renuncia al primer respondedor, es decir, oculta el teclado
        searchBar.resignFirstResponder()
        
        // Limpia los resultados de búsqueda anteriores
        searchResults = []
        
        // Verifica si el texto de búsqueda no es "justin bieber"
        if searchBar.text! != "justin bieber" {
            // Genera resultados de búsqueda falsos
            for i in 0...2 {
                let searchResult = SearchResult()
                searchResult.name = String(format: "Fake Result %d for", i)
                searchResult.artistName = searchBar.text!
                searchResults.append(searchResult)
            }
        }
        
        // Indica que se ha realizado una búsqueda
        hasSearched = true
        
        // Recarga los datos de la tabla para mostrar los nuevos resultados de búsqueda
        tableView.reloadData()
    }
    
    // Función que especifica la posición de la barra de búsqueda
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        // Devuelve la posición de la barra de búsqueda como 'topAttached'
        return .topAttached
    }
}


// MARK: - Table View Delegate
// Extensión del SearchViewController que adopta los protocolos UITableViewDelegate y UITableViewDataSource
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    // Función que devuelve el número de filas en la sección de la tabla
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        // Verifica si aún no se ha realizado ninguna búsqueda
        if !hasSearched {
            return 0
        } else if searchResults.count == 0 {
            // Si no se encontraron resultados de búsqueda, devuelve 1 para mostrar un mensaje indicando que no se encontró nada
            return 1
        } else {
            // Devuelve el número de resultados de búsqueda
            return searchResults.count
        }
    }

    // Función que configura y devuelve una celda para una fila específica de la tabla
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        // Identificador de la celda
        let cellIdentifier = "SearchResultCell"

        // Obtiene una celda reutilizable o crea una nueva si no hay ninguna disponible
        var cell: UITableViewCell! = tableView.dequeueReusableCell(
            withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(
                style: .subtitle, reuseIdentifier: cellIdentifier)
        }
        
        // Configura el contenido de la celda dependiendo de si se encontraron resultados de búsqueda o no
        if searchResults.count == 0 {
            cell.textLabel!.text = "(Nothing found)"
            cell.detailTextLabel!.text = ""
        } else {
            let searchResult = searchResults[indexPath.row]
            cell.textLabel!.text = searchResult.name
            cell.detailTextLabel!.text = searchResult.artistName
        }
        
        // Devuelve la celda configurada
        return cell
    }

    // Función que se ejecuta cuando se selecciona una fila de la tabla
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        // Deselecciona la fila para eliminar el resaltado
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // Función que determina si una fila específica de la tabla puede ser seleccionada
    func tableView(
        _ tableView: UITableView,
        willSelectRowAt indexPath: IndexPath
    ) -> IndexPath? {
        // Si no hay resultados de búsqueda, no se permite la selección
        if searchResults.count == 0 {
            return nil
        } else {
            // Si hay resultados de búsqueda, permite la selección de la fila
            return indexPath
        }
    }
}
