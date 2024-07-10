//
//  GradientView.swift
//  StoreSearch
//
//  Created by Benjamin Jaramillo on 10/07/24.
//

import UIKit

// Clase GradientView que hereda de UIView
class GradientView: UIView {

  // Inicializador que acepta un marco (frame)
  override init(frame: CGRect) {
    // Llama al inicializador de la clase base (UIView)
    super.init(frame: frame)
    // Establece el color de fondo a transparente
    backgroundColor = UIColor.clear
  }

  // Inicializador requerido con un decodificador (aDecoder)
  required init?(coder aDecoder: NSCoder) {
    // Llama al inicializador de la clase base (UIView)
    super.init(coder: aDecoder)
    // Establece el color de fondo a transparente
    backgroundColor = UIColor.clear
  }

  // Método para dibujar el contenido de la vista
  override func draw(_ rect: CGRect) {
    // 1. Obtiene los traits actuales y establece el color dependiendo del estilo de interfaz de usuario
    let traits = UITraitCollection.current
    let color: CGFloat = traits.userInterfaceStyle == .light ? 0.314 : 1

    // 2. Define los componentes del color y las ubicaciones para el gradiente
    let components: [CGFloat] = [
      color, color, color, 0.2,
      color, color, color, 0.4,
      color, color, color, 0.6,
      color, color, color, 1
    ]
    let locations: [CGFloat] = [0, 0.5, 0.75, 1]

    // 3. Crea el espacio de color y el gradiente
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let gradient = CGGradient(
      colorSpace: colorSpace,
      colorComponents: components,
      locations: locations,
      count: 4
    )

    // 4. Define el centro y el radio para el gradiente radial
    let x = bounds.midX
    let y = bounds.midY
    let centerPoint = CGPoint(x: x, y: y)
    let radius = max(x, y)

    // 5. Obtiene el contexto de dibujo actual y dibuja el gradiente radial
    let context = UIGraphicsGetCurrentContext()
    context?.drawRadialGradient(
      gradient!,
      startCenter: centerPoint,
      startRadius: 0,
      endCenter: centerPoint,
      endRadius: radius,
      options: .drawsAfterEndLocation
    )
  }
}
//Gradiente Radial: El color cambia en círculos 
//concéntricos desde un punto central hacia el exterior.
//Este es el tipo de gradiente que se utiliza en el código de GradientView.




