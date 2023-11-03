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
        self.searchController.searchBar.sizeToFit()
        self.tabla.tableHeaderView = searchController.searchBar
        
        self.tabla.dataSource = self
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
            self.datos = [] // Reinicializacion de datos por cada nueva busqueda
            
            let textoBuscado = searchController.searchBar.text!
            let textoBuscadoTrim = textoBuscado.trimmingCharacters(in: .whitespacesAndNewlines)
            print(textoBuscadoTrim)
            
            if textoBuscado.count > 2 {
                self.mostrarPersonajes(comienzanPor: textoBuscado)
            }
        }
    }
    
    func mostrarPersonajes(comienzanPor cadena : String) {
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
                    }
                }
                print("Hay \(personajes.count) personajes")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datos.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let nuevaCelda = tableView.dequeueReusableCell(withIdentifier: "celda",
                              for: indexPath)
        nuevaCelda.textLabel?.text = datos[indexPath.row].name
        return nuevaCelda
     }
    
}
