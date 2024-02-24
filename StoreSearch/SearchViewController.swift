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
    
    struct TableView {
      struct CellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
      }
    }
    
    override func viewDidLoad() {
      super.viewDidLoad()
      tableView.contentInset = UIEdgeInsets(top: 47, left: 0, bottom: 0, right: 0)
      var cellNib = UINib(nibName: TableView.CellIdentifiers.searchResultCell, bundle: nil)
      tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.searchResultCell)
      cellNib = UINib(nibName: TableView.CellIdentifiers.nothingFoundCell, bundle: nil)
      tableView.register(
        cellNib,
        forCellReuseIdentifier: TableView.CellIdentifiers.nothingFoundCell)
      searchBar.becomeFirstResponder()
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
        // Verifica si no hay resultados de búsqueda
        if searchResults.count == 0 {
            // Si no hay resultados, devuelve una celda de "Nothing Found" reutilizable
            return tableView.dequeueReusableCell(
                withIdentifier: TableView.CellIdentifiers.nothingFoundCell,
                for: indexPath)
        } else {
            // Si hay resultados de búsqueda
            // Obtiene una celda reutilizable de tipo SearchResultCell
            let cell = tableView.dequeueReusableCell(
                withIdentifier: TableView.CellIdentifiers.searchResultCell,
                for: indexPath) as! SearchResultCell
            // Obtiene el objeto SearchResult correspondiente a la fila actual
            let searchResult = searchResults[indexPath.row]
            // Configura las etiquetas de la celda con los datos del SearchResult
            cell.nameLabel.text = searchResult.name
            cell.artistNameLabel.text = searchResult.artistName
            // Devuelve la celda configurada
            return cell
        }
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
