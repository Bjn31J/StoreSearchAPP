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
    var isLoading = false
    
    // Definición de la estructura TableView
    struct TableView {
        // Anidamiento de la estructura CellIdentifiers
        struct CellIdentifiers {
            // Definición de identificadores de celda estáticos para SearchResultCell y NothingFoundCell
            static let searchResultCell = "SearchResultCell"  // Identificador de celda para los resultados de búsqueda
            static let nothingFoundCell = "NothingFoundCell"  // Identificador de celda para mostrar cuando no se encuentran resultados
            static let loadingCell = "LoadingCell"
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
        
        cellNib = UINib(nibName: TableView.CellIdentifiers.loadingCell,bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.loadingCell)
         
        // Hace que el searchBar tenga el foco para que el teclado se muestre automáticamente
        searchBar.becomeFirstResponder()
    }

}

// MARK: - Search Bar Delegate

// MARK: - Search Bar Delegate
// Extensión para SearchViewController que implementa el delegado de UISearchBar.
extension SearchViewController: UISearchBarDelegate {
  // Método que se llama cuando se hace clic en el botón de búsqueda del UISearchBar.
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    // Verifica si el texto del searchBar no está vacío.
    if !searchBar.text!.isEmpty {
      // Desactiva el teclado.
      searchBar.resignFirstResponder()

      // Indica que la aplicación está cargando.
      isLoading = true
      // Recarga la tabla para mostrar la celda de carga.
      tableView.reloadData()

      // Marca que se ha realizado una búsqueda.
      hasSearched = true
      // Limpia los resultados de búsqueda anteriores.
      searchResults = []

      // Crea una cola global para realizar la solicitud de red.
      let queue = DispatchQueue.global()
      // Genera la URL para la búsqueda en iTunes.
      let url = self.iTunesURL(searchText: searchBar.text!)
      // Ejecuta la solicitud de red en segundo plano.
      queue.async {
        // Si se obtienen datos válidos de la solicitud, los procesa.
        if let data = self.performStoreRequest(with: url) {
          // Parsea los datos recibidos y actualiza los resultados de búsqueda.
          self.searchResults = self.parse(data: data)
          // Ordena los resultados de búsqueda.
          self.searchResults.sort(by: <)

          // Vuelve al hilo principal para actualizar la interfaz de usuario.
          DispatchQueue.main.async {
            // Indica que la carga ha terminado.
            self.isLoading = false
            // Recarga la tabla para mostrar los resultados de búsqueda.
            self.tableView.reloadData()
          }

          return
        }
      }
    }
  }



    
    
    // Devuelve la posición de la barra en la interfaz de usuario
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        // Devuelve la posición de la barra como "topAttached" para adjuntarla en la parte superior
        return .topAttached
    }

}



// MARK: - Table View Delegate
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(
    _ tableView: UITableView,
    numberOfRowsInSection section: Int
  ) -> Int {
    // Si está cargando, devuelve 1 para mostrar la celda de carga.
    if isLoading {
      return 1
    // Si no se ha realizado una búsqueda, devuelve 0 para no mostrar filas.
    } else if !hasSearched {
      return 0
    // Si se ha buscado pero no hay resultados, devuelve 1 para mostrar la celda de "Nada encontrado".
    } else if searchResults.count == 0 {
      return 1
    // Si hay resultados de búsqueda, devuelve el número de resultados.
    } else {
      return searchResults.count
    }
  }
    

    // Método del delegado de UITableView para proporcionar una celda para una fila dada.
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        // Verifica si está cargando.
        if isLoading {
            // Obtiene una celda reutilizable con el identificador "loadingCell".
            let cell = tableView.dequeueReusableCell(
                withIdentifier: TableView.CellIdentifiers.loadingCell,
                for: indexPath)
            
            // Encuentra el spinner (UIActivityIndicatorView) en la celda utilizando su etiqueta.
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            // Inicia la animación del spinner.
            spinner.startAnimating()
            // Devuelve la celda de carga.
            return cell
        // Verifica si no hay resultados de búsqueda.
        } else if searchResults.count == 0 {
            // Obtiene una celda reutilizable con el identificador "nothingFoundCell".
            return tableView.dequeueReusableCell(
                withIdentifier: TableView.CellIdentifiers.nothingFoundCell,
                for: indexPath)
        // Si hay resultados de búsqueda.
        } else {
            // Obtiene una celda reutilizable con el identificador "searchResultCell".
            let cell = tableView.dequeueReusableCell(
                withIdentifier: TableView.CellIdentifiers.searchResultCell,
                for: indexPath) as! SearchResultCell
            // Obtiene el resultado de búsqueda correspondiente a la fila actual.
            let searchResult = searchResults[indexPath.row]
            // Establece el nombre del resultado en la etiqueta de nombre de la celda.
            cell.nameLabel.text = searchResult.name
            // Si el nombre del artista está vacío, muestra "Unknown".
            if searchResult.artist.isEmpty {
                cell.artistNameLabel.text = "Unknown"
            // Si no, muestra el nombre del artista y el tipo del resultado.
            } else {
                cell.artistNameLabel.text = String(
                    format: "%@ (%@)",
                    searchResult.artist,
                    searchResult.type)
            }
            // Devuelve la celda del resultado de búsqueda.
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
        if searchResults.count == 0 || isLoading{
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
        let urlString = String(format: "https://itunes.apple.com/search?term=%@&limit=200", encodedText)
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
