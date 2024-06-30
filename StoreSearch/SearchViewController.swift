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
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    
    var searchResults = [SearchResult]()
    var hasSearched = false
    var isLoading = false
    var dataTask: URLSessionDataTask?
    
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

    override func viewDidLoad() {
      super.viewDidLoad()
      // Llama al método de la superclase para realizar cualquier configuración adicional.
      super.viewDidLoad()

      // Ajusta el contenido del tableView para que tenga un margen superior de 91 puntos.
      tableView.contentInset = UIEdgeInsets(top: 91, left: 0, bottom: 0, right: 0)

      // Crea un UINib para la celda de resultados de búsqueda usando el identificador especificado.
      var cellNib = UINib(nibName: TableView.CellIdentifiers.searchResultCell, bundle: nil)
      // Registra el UINib en el tableView para que pueda usarlo al crear celdas con ese identificador.
      tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.searchResultCell)

      // Crea un UINib para la celda que se muestra cuando no se encuentran resultados.
      cellNib = UINib(nibName: TableView.CellIdentifiers.nothingFoundCell, bundle: nil)
      // Registra el UINib en el tableView para que pueda usarlo al crear celdas con ese identificador.
      tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.nothingFoundCell)

      // Hace que la barra de búsqueda se convierta en el primer respondedor, mostrando el teclado al cargar la vista.
      searchBar.becomeFirstResponder()

      // Crea un UINib para la celda de carga usando el identificador especificado.
      cellNib = UINib(nibName: TableView.CellIdentifiers.loadingCell, bundle: nil)
      // Registra el UINib en el tableView para que pueda usarlo al crear celdas con ese identificador.
      tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.loadingCell)
    }

    
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        print("Segment changed: \(sender.selectedSegmentIndex)")
    }

}


extension SearchViewController: UISearchBarDelegate {
  
  // Método delegado llamado cuando se presiona el botón de búsqueda en la barra de búsqueda.
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    performSearch()
  }
  
  // Método que realiza la búsqueda.
  func performSearch() {
    // Verifica si el texto del searchBar no está vacío.
    if !searchBar.text!.isEmpty {
      // Desactiva el teclado.
      searchBar.resignFirstResponder()

      // Cancela cualquier tarea de datos en curso.
      dataTask?.cancel()

      // Indica que la aplicación está cargando.
      isLoading = true
      // Recarga la tabla para mostrar la celda de carga.
      tableView.reloadData()

      // Marca que se ha realizado una búsqueda.
      hasSearched = true
      // Limpia los resultados de búsqueda anteriores.
      searchResults = []

      // Crea la URL para la búsqueda en iTunes con el texto de búsqueda y la categoría seleccionada.
      let url = iTunesURL(searchText: searchBar.text!, category: segmentedControl.selectedSegmentIndex)
      // Crea una sesión compartida de URL.
      let session = URLSession.shared
      // Crea una tarea de datos para la URL.
      dataTask = session.dataTask(with: url) { data, response, error in
        // Verifica si hubo un error y si el error es de cancelación (-999).
        if let error = error as NSError?, error.code == -999 {
          return // La búsqueda fue cancelada.
        } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
          // Verifica si la respuesta HTTP es válida (código 200).
          if let data = data {
            // Parsea los datos recibidos.
            self.searchResults = self.parse(data: data)
            // Ordena los resultados de búsqueda.
            self.searchResults.sort(by: <)
            // Actualiza la interfaz en el hilo principal.
            DispatchQueue.main.async {
              self.isLoading = false
              self.tableView.reloadData()
            }
            return
          }
        } else {
          print("Failure! \(response!)")
        }
        // En caso de error, actualiza la interfaz en el hilo principal.
        DispatchQueue.main.async {
          self.hasSearched = false
          self.isLoading = false
          self.tableView.reloadData()
          self.showNetworkError()
        }
      }
      // Inicia la tarea de datos.
      dataTask?.resume()
    }
  }
}

    // Devuelve la posición de la barra en la interfaz de usuario
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        // Devuelve la posición de la barra como "topAttached" para adjuntarla en la parte superior
        return .topAttached
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
            cell.configure(for: searchResult)
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
    
    func iTunesURL(searchText: String, category: Int) -> URL {
      let kind: String
      switch category {
      case 1: kind = "musicTrack"
      case 2: kind = "software"
      case 3: kind = "ebook"
      default: kind = ""
      }
      let encodedText = searchText.addingPercentEncoding(
        withAllowedCharacters: CharacterSet.urlQueryAllowed)!
      let urlString = "https://itunes.apple.com/search?" +
        "term=\(encodedText)&limit=200&entity=\(kind)"

      let url = URL(string: urlString)
      return url!
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
