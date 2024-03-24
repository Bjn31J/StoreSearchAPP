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
    
    // Definición de la estructura TableView
    struct TableView {
        // Anidamiento de la estructura CellIdentifiers
        struct CellIdentifiers {
            // Definición de identificadores de celda estáticos para SearchResultCell y NothingFoundCell
            static let searchResultCell = "SearchResultCell"  // Identificador de celda para los resultados de búsqueda
            static let nothingFoundCell = "NothingFoundCell"  // Identificador de celda para mostrar cuando no se encuentran resultados
        }
    }

    // Configuración inicial cuando la vista carga
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ajusta la inserción de contenido de la tabla para dejar espacio para la barra de búsqueda
        tableView.contentInset = UIEdgeInsets(top: 47, left: 0, bottom: 0, right: 0)
        
        // Registra el archivo de Nib (Interface Builder) para la celda SearchResultCell
        var cellNib = UINib(nibName: TableView.CellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.searchResultCell)
        
        // Registra el archivo de Nib para la celda NothingFoundCell
        cellNib = UINib(nibName: TableView.CellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.nothingFoundCell)
        
        // Hace que el searchBar tenga el foco para que el teclado se muestre automáticamente
        searchBar.becomeFirstResponder()
    }

}

// MARK: - Search Bar Delegate
extension SearchViewController: UISearchBarDelegate {
    
    // Método llamado cuando se hace clic en el botón de búsqueda en la barra de búsqueda
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Verifica si el texto de búsqueda no está vacío
        if !searchBar.text!.isEmpty {
            // Si hay texto de búsqueda, se resigna el primer respondedor (se oculta el teclado)
            searchBar.resignFirstResponder()

            // Se establece la bandera hasSearched en true para indicar que se ha realizado una búsqueda
            hasSearched = true
            
            // Se limpia el array de resultados de búsqueda para realizar una nueva búsqueda
            searchResults = []

            // Se construye la URL para la búsqueda utilizando el texto de búsqueda ingresado en la barra de búsqueda
            let url = iTunesURL(searchText: searchBar.text!)
            // Se imprime la URL construida para depuración
            print("URL: '\(url)'")

            // Se realiza la solicitud al servidor de iTunes con la URL construida y se obtiene la respuesta de datos
            if let data = performStoreRequest(with: url) {
                // Si se obtienen datos de la solicitud, se parsean para obtener los resultados de búsqueda
                searchResults = parse(data: data)
                // Se ordenan los resultados de búsqueda en orden alfabético
                searchResults.sort(by: <)
            }
            
            // Se recarga la tabla para mostrar los nuevos resultados de búsqueda
            tableView.reloadData()
        }
    }

    
    
    // Devuelve la posición de la barra en la interfaz de usuario
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        // Devuelve la posición de la barra como "topAttached" para adjuntarla en la parte superior
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
    // Método que configura y devuelve una celda para una fila específica de la tabla
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        // Verifica si no hay resultados de búsqueda
        if searchResults.count == 0 {
            // Si no hay resultados, devuelve una celda de "Nada encontrado"
            return tableView.dequeueReusableCell(
                withIdentifier: TableView.CellIdentifiers.nothingFoundCell,
                for: indexPath)
        } else {
            // Si hay resultados de búsqueda
            // Obtiene una celda reutilizable para SearchResultCell y la configura
            let cell = tableView.dequeueReusableCell(
                withIdentifier: TableView.CellIdentifiers.searchResultCell,
                for: indexPath) as! SearchResultCell
            // Obtiene el resultado de búsqueda correspondiente a la fila actual
            let searchResult = searchResults[indexPath.row]
            // Configura el nombre del resultado de búsqueda en la etiqueta nameLabel de la celda
            cell.nameLabel.text = searchResult.name
            // Verifica si el artista está vacío
            if searchResult.artist.isEmpty {
                // Si el artista está vacío, muestra "Desconocido" en la etiqueta artistNameLabel
                cell.artistNameLabel.text = "Unknown"
            } else {
                // Si el artista no está vacío, muestra el nombre del artista y el tipo de resultado en artistNameLabel
                cell.artistNameLabel.text = String(
                    format: "%@ (%@)",
                    searchResult.artist,
                    searchResult.type)
            }
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
    
    
    
    
    // MARK: - Helper Methods
    // Método para construir y devolver la URL de búsqueda en iTunes
    func iTunesURL(searchText: String) -> URL {
        // Codifica el texto de búsqueda para asegurarse de que sea compatible con una URL
        let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        // Construye la URL de búsqueda en iTunes utilizando el texto de búsqueda codificado
        let urlString = String(format: "https://itunes.apple.com/search?term=%@", encodedText)
        // Crea una instancia de URL a partir de la cadena de URL construida
        let url = URL(string: urlString)
        // Devuelve la URL creada
        return url!
    }

    
    // Método para realizar una solicitud al servidor de iTunes y devolver los datos obtenidos
    func performStoreRequest(with url: URL) -> Data? {
        do {
            // Intenta obtener los datos de la URL proporcionada
            return try Data(contentsOf: url)
        } catch {
            // Si se produce un error al obtener los datos, imprime el error y muestra un mensaje de error en la red
            print("Download Error: \(error.localizedDescription)")
            showNetworkError()
            // Devuelve nil indicando que no se pudieron obtener los datos
            return nil
        }
    }

    
    // Método para analizar los datos JSON obtenidos de la solicitud y devolver un array de SearchResult
    func parse(data: Data) -> [SearchResult] {
        do {
            // Crea una instancia de JSONDecoder para decodificar los datos JSON
            let decoder = JSONDecoder()
            // Decodifica los datos JSON en un objeto de tipo ResultArray utilizando el JSONDecoder
            let result = try decoder.decode(ResultArray.self, from: data)
            // Devuelve la matriz de resultados obtenidos del objeto ResultArray
            return result.results
        } catch {
            // Si se produce un error al decodificar los datos JSON, imprime el error y devuelve un array vacío
            print("JSON Error: \(error)")
            return []
        }
    }

    // Método para mostrar un mensaje de error de red al usuario
    func showNetworkError() {
        // Crea una instancia de UIAlertController para mostrar el mensaje de error
        let alert = UIAlertController(
            title: "Whoops...",
            message: "There was an error accessing the iTunes Store." +
            " Please try again.",
            preferredStyle: .alert)

        // Agrega un botón de acción "OK" al UIAlertController
        let action = UIAlertAction(
            title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        // Presenta el UIAlertController para mostrar el mensaje de error al usuario
        present(alert, animated: true, completion: nil)
    }

    
}
