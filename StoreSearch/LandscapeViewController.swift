//
//  LandscapeViewController.swift
//  StoreSearch
//
//  Created by Benjamin Jaramillo on 10/07/24.
//

import UIKit

class LandscapeViewController: UIViewController {
  var searchResults = [SearchResult]()

  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var pageControl: UIPageControl!

  private var firstTime = true
  private var downloads = [URLSessionDownloadTask]()

    // Método llamado después de cargar la vista en memoria
    override func viewDidLoad() {
      // Llama al método viewDidLoad de la clase base
      super.viewDidLoad()
      
      // Elimina todas las restricciones del view principal
      view.removeConstraints(view.constraints)
      // Permite que el view use máscaras de autoresizable
      view.translatesAutoresizingMaskIntoConstraints = true
      
      // Elimina todas las restricciones del page control
      pageControl.removeConstraints(pageControl.constraints)
      // Permite que el page control use máscaras de autoresizable
      pageControl.translatesAutoresizingMaskIntoConstraints = true
      
      // Elimina todas las restricciones del scroll view
      scrollView.removeConstraints(scrollView.constraints)
      // Permite que el scroll view use máscaras de autoresizable
      scrollView.translatesAutoresizingMaskIntoConstraints = true
      
      // Establece el fondo del view con un patrón de imagen de fondo
      view.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
      
      // Configura el número inicial de páginas del page control como cero
      pageControl.numberOfPages = 0
    }

    // Método llamado justo antes de que el sistema realice el diseño de las subvistas
    override func viewWillLayoutSubviews() {
      // Llama al método viewWillLayoutSubviews de la clase base
      super.viewWillLayoutSubviews()
      
      // Obtiene el marco seguro (safe area) del view
      let safeFrame = view.safeAreaLayoutGuide.layoutFrame
      
      // Establece el marco del scroll view para que coincida con el marco seguro
      scrollView.frame = safeFrame
      
      // Calcula y establece el marco del page control
      pageControl.frame = CGRect(
        x: safeFrame.origin.x,
        y: safeFrame.size.height - pageControl.frame.size.height,
        width: safeFrame.size.width,
        height: pageControl.frame.size.height)
      
      // Verifica si es la primera vez que se realiza el diseño
      if firstTime {
        // Marca que ya no es la primera vez
        firstTime = false
        // Llama a la función para colocar los botones de mosaico con los resultados de búsqueda
        tileButtons(searchResults)
      }
    }


    // Método de inicialización para liberar recursos
    deinit {
      // Imprime un mensaje indicando que se está liberando la instancia de la clase
      print("deinit \(self)")
      
      // Itera sobre todas las tareas de descarga almacenadas en la propiedad 'downloads'
      for task in downloads {
        // Cancela cada tarea de descarga
        task.cancel()
      }
    }

  
  // MARK: - Actions
    // Método de acción para responder al cambio de página en el UIPageControl
    @IBAction func pageChanged(_ sender: UIPageControl) {
      // Realiza una animación suave del cambio de página
      UIView.animate(
        // Duración de la animación
        withDuration: 0.3,
        // Retraso antes de comenzar la animación (en este caso, no hay retraso)
        delay: 0,
        // Opciones de animación (curva de aceleración y desaceleración)
        options: [.curveEaseInOut],
        // Bloque de animaciones
        animations: {
          // Cambia el desplazamiento del scrollView para mostrar la página actual seleccionada
          self.scrollView.contentOffset = CGPoint(
            // Calcula el nuevo desplazamiento en función de la página actual seleccionada
            x: self.scrollView.bounds.size.width * CGFloat(sender.currentPage),
            y: 0)
        },
        // Bloque de finalización de la animación (en este caso, no se realiza ninguna acción al completar la animación)
        completion: nil)
    }

  // MARK: - Private Methods
    // Método privado para colocar botones en el scrollView basado en los resultados de búsqueda
    private func tileButtons(_ searchResults: [SearchResult]) {
      // Dimensiones de cada elemento del mosaico
      let itemWidth: CGFloat = 94
      let itemHeight: CGFloat = 88
      
      // Variables para el cálculo de columnas y filas por página
      var columnsPerPage = 0
      var rowsPerPage = 0
      var marginX: CGFloat = 0
      var marginY: CGFloat = 0
      
      // Dimensiones del scrollView
      let viewWidth = scrollView.bounds.size.width
      let viewHeight = scrollView.bounds.size.height
      
      // Calcular el número de columnas y filas por página
      columnsPerPage = Int(viewWidth / itemWidth)
      rowsPerPage = Int(viewHeight / itemHeight)
      
      // Márgenes horizontal y vertical para centrar los botones en el scrollView
      marginX = (viewWidth - (CGFloat(columnsPerPage) * itemWidth)) * 0.5
      marginY = (viewHeight - (CGFloat(rowsPerPage) * itemHeight)) * 0.5
      
      // Dimensiones de cada botón dentro del elemento del mosaico
      let buttonWidth: CGFloat = 82
      let buttonHeight: CGFloat = 82
      let paddingHorz = (itemWidth - buttonWidth) / 2
      let paddingVert = (itemHeight - buttonHeight) / 2
      
      // Agregar los botones al scrollView
      var row = 0
      var column = 0
      var x = marginX
      
      for (index, result) in searchResults.enumerated() {
        // Crear un botón personalizado
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(named: "LandscapeButton"), for: .normal)
        
        // Descargar la imagen asociada al resultado y colocarla en el botón
        downloadImage(for: result, andPlaceOn: button)
        
        // Establecer el marco (frame) del botón dentro del scrollView
        button.frame = CGRect(
          x: x + paddingHorz,
          y: marginY + CGFloat(row) * itemHeight + paddingVert,
          width: buttonWidth,
          height: buttonHeight)
        
        // Agregar el botón al scrollView
        scrollView.addSubview(button)
        
        // Actualizar las posiciones de fila y columna
        row += 1
        if row == rowsPerPage {
          row = 0
          x += itemWidth
          column += 1
          if column == columnsPerPage {
            column = 0
            x += marginX * 2
          }
        }
      }
      
      // Establecer el tamaño de contenido del scrollView
      let buttonsPerPage = columnsPerPage * rowsPerPage
      let numPages = 1 + (searchResults.count - 1) / buttonsPerPage
      scrollView.contentSize = CGSize(
        width: CGFloat(numPages) * viewWidth,
        height: scrollView.bounds.size.height)
      
      // Configurar el número de páginas en el page control
      print("Number of pages: \(numPages)")
      pageControl.numberOfPages = numPages
      pageControl.currentPage = 0
    }

    // Método privado para descargar una imagen desde una URL y colocarla en un botón
    private func downloadImage(
      for searchResult: SearchResult,
      andPlaceOn button: UIButton
    ) {
      // Verifica si la URL de la imagen es válida
      if let url = URL(string: searchResult.imageSmall) {
        // Crea una tarea de descarga con URLSession compartida
        let task = URLSession.shared.downloadTask(with: url) {
          [weak button] url, _, error in
          // Verifica si no hubo errores y se pudo obtener la URL y los datos de la imagen
          if error == nil, let url = url,
             let data = try? Data(contentsOf: url),
             let image = UIImage(data: data) {
            // Actualiza la interfaz de usuario en el hilo principal
            DispatchQueue.main.async {
              // Verifica si el botón aún es válido y establece la imagen descargada como imagen normal del botón
              if let button = button {
                button.setImage(image, for: .normal)
              }
            }
          }
        }
        // Inicia la tarea de descarga
        task.resume()
        // Agrega la tarea a la lista de descargas para gestionar su ciclo de vida
        downloads.append(task)
      }
    }

}

// Extensión que implementa el protocolo UIScrollViewDelegate para el LandscapeViewController
extension LandscapeViewController: UIScrollViewDelegate {
  
  // Método llamado cuando se realiza el desplazamiento del scrollView
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    // Obtiene el ancho visible del scrollView
    let width = scrollView.bounds.size.width
    
    // Calcula la página actual basada en el desplazamiento horizontal del scrollView
    let page = Int((scrollView.contentOffset.x + width / 2) / width)
    
    // Actualiza la página actual en el page control
    pageControl.currentPage = page
  }
}

