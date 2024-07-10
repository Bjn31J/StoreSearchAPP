//
//  SlideOutAnimationController.swift
//  StoreSearch
//
//  Created by Benjamin Jaramillo on 10/07/24.
//

import UIKit

// Clase SlideOutAnimationController que hereda de NSObject y adopta el protocolo UIViewControllerAnimatedTransitioning
class SlideOutAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

  // Método para especificar la duración de la transición
  func transitionDuration(
    // Parámetro 'transitionContext' proporciona contexto para la transición
    using transitionContext: UIViewControllerContextTransitioning?
  ) -> TimeInterval {
    // Retorna la duración de la animación, en este caso 0.3 segundos
    return 0.3
  }

  // Método para realizar la animación de la transición
  func animateTransition(
    // Parámetro 'transitionContext' proporciona contexto para la transición
    using transitionContext: UIViewControllerContextTransitioning
  ) {
    // Obtiene la vista del view controller que está siendo descartado
    if let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from) {
      // Obtiene el contenedor de la transición
      let containerView = transitionContext.containerView
      // Obtiene la duración de la animación
      let time = transitionDuration(using: transitionContext)
      // Realiza la animación usando UIView.animate
      UIView.animate(
        withDuration: time,
        animations: {
          // Desplaza la vista hacia arriba fuera de la pantalla
          fromView.center.y -= containerView.bounds.size.height
          // Reduce la escala de la vista a la mitad
          fromView.transform = CGAffineTransform(
            scaleX: 0.5, y: 0.5)
        }, completion: { finished in
          // Completa la transición
          transitionContext.completeTransition(finished)
        }
      )
    }
  }
}
