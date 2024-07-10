//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by Benjamin Jaramillo on 30/06/24.
//

import UIKit

class DetailViewController: UIViewController {
  var searchResult: SearchResult!

  @IBOutlet weak var popupView: UIView!
  @IBOutlet weak var artworkImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var artistNameLabel: UILabel!
  @IBOutlet weak var kindLabel: UILabel!
  @IBOutlet weak var genreLabel: UILabel!
  @IBOutlet weak var priceButton: UIButton!

  var downloadTask: URLSessionDownloadTask?
    
  enum AnimationStyle {
      case slide
      case fade
  }

  var dismissStyle = AnimationStyle.fade

  override func viewDidLoad() {
    super.viewDidLoad()
    // Redondea las esquinas de la vista emergente.
    popupView.layer.cornerRadius = 10
    
    // Crea un reconocedor de gestos para cerrar la vista.
    let gestureRecognizer = UITapGestureRecognizer(
      target: self,
      action: #selector(close))
    
    // Permite que las toques en otras vistas pasen a través del reconocedor de gestos.
    gestureRecognizer.cancelsTouchesInView = false
    
    // Establece el delegado del reconocedor de gestos.
    gestureRecognizer.delegate = self
    
    // Agrega el reconocedor de gestos a la vista.
    view.addGestureRecognizer(gestureRecognizer)
    
    // Si hay un resultado de búsqueda, actualiza la interfaz de usuario.
    if searchResult != nil {
      updateUI()
    }
      // Gradient view
      view.backgroundColor = UIColor.clear
      let dimmingView = GradientView(frame: CGRect.zero)
      dimmingView.frame = view.bounds
      view.insertSubview(dimmingView, at: 0)
      
  }

  deinit {
    print("deinit \(self)")
    // Cancela cualquier tarea de descarga pendiente.
    downloadTask?.cancel()
  }
    
    // Inicializador requerido con un decodificador (aDecoder)
    required init?(coder aDecoder: NSCoder) {
        // Llama al inicializador de la clase base (UIViewController)
        super.init(coder: aDecoder)
        // Establece el delegado de transición a la propia instancia
        transitioningDelegate = self
    }

  
  // MARK: - Actions
  
  @IBAction func close() {
    dismissStyle = .slide
    // Cierra la vista emergente.
    dismiss(animated: true, completion: nil)
  }

  @IBAction func openInStore() {
    // Abre el enlace del resultado en el navegador.
    if let url = URL(string: searchResult.storeURL) {
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
  }
  
  // MARK: - Helper Methods
  
  func updateUI() {
    // Actualiza el nombre del resultado.
    nameLabel.text = searchResult.name

    // Actualiza el nombre del artista.
    if searchResult.artist.isEmpty {
      artistNameLabel.text = "Unknown"
    } else {
      artistNameLabel.text = searchResult.artist
    }

    // Actualiza el tipo y género del resultado.
    kindLabel.text = searchResult.type
    genreLabel.text = searchResult.genre

    // Formateador para mostrar el precio en formato de moneda.
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = searchResult.currency

    // Muestra el precio del resultado.
    let priceText: String
    if searchResult.price == 0 {
      priceText = "Free"
    } else if let text = formatter.string(
      from: searchResult.price as NSNumber) {
      priceText = text
    } else {
      priceText = ""
    }

    priceButton.setTitle(priceText, for: .normal)

    // Obtiene y muestra la imagen grande del resultado.
    if let largeURL = URL(string: searchResult.imageLarge) {
      downloadTask = artworkImageView.loadImage(url: largeURL)
    }
  }
}

// Extensión de DetailViewController que adopta el protocolo UIGestureRecognizerDelegate
extension DetailViewController: UIGestureRecognizerDelegate {
  
  // Método que determina si un gesto debe recibir un toque específico
  func gestureRecognizer(
    _ gestureRecognizer: UIGestureRecognizer,
    shouldReceive touch: UITouch
  ) -> Bool {
    // Retorna true si la vista tocada es igual a la vista del controlador
    return (touch.view === self.view)
  }
}

// Extensión de DetailViewController que adopta el protocolo UIViewControllerTransitioningDelegate
extension DetailViewController: UIViewControllerTransitioningDelegate {
  
  // Método para obtener el controlador de animación al presentar un view controller
  func animationController(
    forPresented presented: UIViewController,
    presenting: UIViewController,
    source: UIViewController
  ) -> UIViewControllerAnimatedTransitioning? {
    // Retorna una instancia de BounceAnimationController para la animación de presentación
    return BounceAnimationController()
  }

  // Método para obtener el controlador de animación al descartar un view controller
  func animationController(
    forDismissed dismissed: UIViewController
  ) -> UIViewControllerAnimatedTransitioning? {
    // Switch basado en el estilo de descarte configurado en dismissStyle
    switch dismissStyle {
      // Caso para estilo de descarte slide
      case .slide:
        // Retorna una instancia de SlideOutAnimationController
        return SlideOutAnimationController()
      // Caso para estilo de descarte fade
      case .fade:
        // Retorna una instancia de FadeOutAnimationController
        return FadeOutAnimationController()
    }
  }
}
