//
//  UIImageView+DownloadImage.swift
//  StoreSearch
//
//  Created by Benjamin Jaramillo on 30/06/24.
//

import UIKit

extension UIImageView {
  // Método para cargar una imagen desde una URL
  func loadImage(url: URL) -> URLSessionDownloadTask {
    // Crea una sesión compartida de URL
    let session = URLSession.shared
    
    // Crea una tarea de descarga para la URL
    let downloadTask = session.downloadTask(with: url) { [weak self] url, _, error in
      // Verifica si no hubo errores y si se recibió una URL válida
      if error == nil, let url = url,
         // Intenta obtener los datos desde la URL
         let data = try? Data(contentsOf: url),
         // Crea una imagen con los datos obtenidos
         let image = UIImage(data: data) {
        // Actualiza la interfaz en el hilo principal
        DispatchQueue.main.async {
          // Asigna la imagen descargada al UIImageView
          if let weakSelf = self {
            weakSelf.image = image
          }
        }
      }
    }
    
    // Inicia la tarea de descarga
    downloadTask.resume()
    
    // Retorna la tarea de descarga
    return downloadTask
  }
}

