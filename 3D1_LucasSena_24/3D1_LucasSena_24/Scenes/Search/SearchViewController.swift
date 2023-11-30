import UIKit /* toda a biblioteca UIKit foi feita em Objective-C então é necessário que eu deixe explicito
que o método herda desta biblioteca*/

class SearchViewController: UIViewController {

    @IBOutlet weak var btnSalavar: UIButton!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var lblDetalhes: UILabel!
    
    private var savePokemon : Pokemon? = nil
    var delegate : PokemonProtocol? = nil
    private var service: PokemonService? = nil
     
    override func viewDidLoad() {
        super.viewDidLoad()
        self.service = PokemonService()
        self.createButton()
    }
    
    private func createButton() {
        let item = UIBarButtonItem(barButtonSystemItem: .search,
                                   target: self,
                                   action: #selector(searchPokemon))
        self.navigationItem.rightBarButtonItem = item
    }
    
    @objc private func searchPokemon(_ sender: UIBarButtonItem) {
        savePokemon = nil
        sender.isEnabled = false
        self.btnSalavar.isEnabled = false
        self.image.image = UIImage(systemName: "questionmark")
        self.lblDetalhes.text = "Loading..."
        
        self.service?.load { [weak self] response in
            guard let self = self else {return}
            
            switch response {
            case .success(let pokemon):
                if let imageUrl = pokemon.sprites?.front_default {
                    self.image.loadFromUrl(imageUrl)
                }
                self.lblDetalhes.text = pokemon.toString()
                self.savePokemon = pokemon
                self.btnSalavar.isEnabled = true
            case .failure(let error):
                self.image.image = UIImage(systemName: "exclamationmark.icloud")
                self.lblDetalhes.text = error.localizedDescription
            }
            
            sender.isEnabled = true
        }
    }
    
    
    @IBAction func btnSalvar(_ sender: Any) {
        if let pokemon = savePokemon,
           let locaDelegate = delegate {
            locaDelegate.save(pokemon: pokemon)
            self.navigationController?.popViewController(animated: true)
        }
    }
}
