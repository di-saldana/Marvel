//
//  DetalleViewController.swift
//  Marvel
//
//  Created by Máster Móviles on 3/11/23.
//

import UIKit
import Marvelous

class DetalleViewController: UIViewController {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    
    var character: RCCharacterObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = character?.name
        bioLabel.text = character?.bio
        
        let colaBackground = OperationQueue()
        colaBackground.addOperation {
            //SUPONIENDO que la variable con el personaje se llama "personaje"
            if let thumb = self.character?.thumbnail {
              //portrait_uncanny es 300x450px. Puedes cambiarlo por otro tamaño si prefieres
              let url = "\(thumb.basePath!)/portrait_uncanny.\(thumb.extension!)"
              //cambiamos la URL por https://. Necesario en iOS
              let urlHttps = url.replacingOccurrences(of: "http", with: "https")
                if let urlFinal = URL(string:urlHttps) {
                    do {
                       let datos = try Data(contentsOf:urlFinal)
                        if let img = UIImage(data: datos) {
                            OperationQueue.main.addOperation {
                                //suponiendo que el outlet de la imagen se llama "miImagen"
                                self.image.image = img
                            }
                        }
                    }
                    catch {
                    }
                }
            }
        }
        
    }
    
    override func viewWillLayoutSubviews() {
       bioLabel.sizeToFit()
   }
}
