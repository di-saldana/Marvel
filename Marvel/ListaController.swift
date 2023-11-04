//
//  ListaController.swift
//  Marvel
//
//  Created by Máster Móviles on 3/11/23.
//

import UIKit
import Marvelous

class ListaController: UIViewController, UISearchResultsUpdating, UITableViewDataSource {
   
    @IBOutlet weak var tabla: UITableView!
    @IBOutlet var searchController: UISearchController!
    
    let throttler = Throttler(minimumDelay: 0.1)  //el delay está en segundos
    
    var datos: [RCCharacterObject] = []
    
    var miSpinner = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.searchController = UISearchController(searchResultsController: nil)
        //el delegate somos nosotros (ListaController)
        self.searchController.searchResultsUpdater = self
        //Configuramos el search controller
        //esto sería true si quisiéramos mostrar los resultados de búsqueda en un sitio distinto a la tabla
        self.searchController.obscuresBackgroundDuringPresentation = false
        //lo que aparece en la barra de búsqueda antes de teclear nada
        self.searchController.searchBar.placeholder = "Buscar texto"
        //Añadimos la barra de búsqueda a la tabla
        self.navigationItem.searchController = searchController
        
        self.tabla.dataSource = self
        
        //que se oculte automáticamente al pararse
        miSpinner.hidesWhenStopped = true
        //lo añadimos a la vista principal del controller actual
        self.view.addSubview(miSpinner)
        //lo centramos en la pantalla
        miSpinner.center.x = self.view.center.x
        miSpinner.center.y = self.view.center.y
        //nos aseguramos que está al frente y no tapado por la tabla
        self.view.bringSubviewToFront(self.miSpinner)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func updateSearchResults(for searchController: UISearchController) {
        throttler.throttle {
            let textoBuscado = searchController.searchBar.text!
            let textoBuscadoTrim = textoBuscado.trimmingCharacters(in: .whitespacesAndNewlines)
            print(textoBuscadoTrim)
            
            if textoBuscado.count > 2 {
                self.mostrarPersonajes(comienzanPor: textoBuscado)
            }
        
        }
    }
    
    func mostrarPersonajes(comienzanPor cadena : String) {
        self.datos = []
        
        OperationQueue.main.addOperation() {
            self.miSpinner.startAnimating()
        }
        
        let marvelAPI = RCMarvelAPI()
        //PUEDES CAMBIAR ESTO PARA PONER TUS CLAVES
        marvelAPI.publicKey = "a6927e7e15930110aade56ef90244f6d"
        marvelAPI.privateKey = "487b621fc3c0d6f128b468ba86c99c508f24d357"
        let filtro = RCCharacterFilter()
        filtro.nameStartsWith = cadena
        filtro.limit = 50
        marvelAPI.characters(by: filtro) {
            resultados, info, error in
            if let personajes = resultados as? [RCCharacterObject] {
                for personaje in personajes {
                    print(personaje.name ?? "")
                    self.datos.append(personaje)
                    
                    OperationQueue.main.addOperation() {
                        self.tabla.reloadData();
                        self.miSpinner.stopAnimating()
                    }
                }
                print("Hay \(personajes.count) personajes")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datos.count
    }
    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let nuevaCelda = tableView.dequeueReusableCell(withIdentifier: "celda",
//                                                       for: indexPath)
//        nuevaCelda.textLabel?.text = datos[indexPath.row].name
//        return nuevaCelda
//     }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let nuevaCelda = tableView.dequeueReusableCell(withIdentifier: "celda", for: indexPath)

        // Check if the indexPath.row is within the valid range of datos
        if indexPath.row < datos.count {
            nuevaCelda.textLabel?.text = datos[indexPath.row].name
        } else {
            // Handle the case where indexPath.row is out of bounds
            nuevaCelda.textLabel?.text = "No data available"
        }

        return nuevaCelda
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "miSegue" {
            if let destinationVC = segue.destination as? DetalleViewController,
               let selectedIndexPath = tabla.indexPathForSelectedRow {
                
                // Check if the selected index is within the bounds of the datos array
                if selectedIndexPath.row < datos.count {
                    let selectedCharacter = datos[selectedIndexPath.row]
                    destinationVC.character = selectedCharacter
                } else {
                    // Handle the case where the index is out of bounds (e.g., show an error message)
                    print("Selected index is out of bounds")
                }
            }
        }
    }



}
