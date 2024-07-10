//
//  BounceAnimationController.swift
//  StoreSearch
//
//  Created by Benjamin Jaramillo on 10/07/24.
//

import UIKit

// Clase BounceAnimationController que hereda de NSObject y adopta el protocolo UIViewControllerAnimatedTransitioning
class BounceAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

  // Método para especificar la duración de la transición
  func transitionDuration(
    // Parámetro 'transitionContext' proporciona contexto para la transición
    using transitionContext: UIViewControllerContextTransitioning?
  ) -> TimeInterval {
    // Retorna la duración de la animación, en este caso 0.4 segundos
    return 0.4
  }

  // Método para realizar la animación de la transición
  func animateTransition(
    // Parámetro 'transitionContext' proporciona contexto para la transición
    using transitionContext: UIViewControllerContextTransitioning
  ) {
    // Obtiene el view controller de destino que se va a presentar
    if let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
       // Obtiene la vista del view controller de destino
       let toView = transitionContext.view(forKey: UITransitionContextViewKey.to) {
      // Obtiene el contenedor de la transición
      let containerView = transitionContext.containerView
      // Establece el marco final de la vista de destino
      toView.frame = transitionContext.finalFrame(for: toViewController)
      // Añade la vista de destino al contenedor
      containerView.addSubview(toView)
      // Establece una transformación inicial para la vista (escalado al 70%)
      toView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)

      // Realiza la animación usando UIView.animateKeyframes
      UIView.animateKeyframes(
        // Especifica la duración total de la animación
        withDuration: transitionDuration(using: transitionContext),
        delay: 0,
        options: .calculationModeCubic,
        animations: {
          // Primera parte de la animación: escala al 120% de su tamaño original
          UIView.addKeyframe(
            withRelativeStartTime: 0.0,
            relativeDuration: 0.334) {
              toView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }
          // Segunda parte de la animación: escala al 90% de su tamaño original
          UIView.addKeyframe(
            withRelativeStartTime: 0.334,
            relativeDuration: 0.333) {
              toView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }
          // Tercera parte de la animación: vuelve al tamaño original
          UIView.addKeyframe(
            withRelativeStartTime: 0.666,
            relativeDuration: 0.333) {
              toView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
        }, completion: { finished in
          // Completa la transición
          transitionContext.completeTransition(finished)
        })
    }
  }
}
