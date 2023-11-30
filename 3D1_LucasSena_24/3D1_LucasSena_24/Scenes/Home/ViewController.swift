import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var tabela: UITableView!
    
    private var listaPokemon : [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabela.dataSource = self
        self.tabela.delegate = self
        
        let fakeView = FakeViewController()
        self.navigationController?.pushViewController(fakeView, animated: false)
        
        self.loadList()
        self.tabela.reloadData()
    }
    
    private func loadList() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "PokemonEntity")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "weight", ascending: false)]
        do {
            self.listaPokemon = try context.fetch(fetchRequest)
        }
        catch {
            debugPrint("==> Erro ao recuperar dados da base CoreData")
        }
    }
    
    @IBAction func btnSearch(_ sender: Any) {
        let viewSearch = SearchViewController()
        viewSearch.delegate = self
        self.navigationController?.pushViewController(viewSearch, animated: true)
    }
}

extension ViewController : PokemonProtocol {
    func delete(pokemon: NSManagedObject) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let context = appDelegate.persistentContainer.viewContext
        do {
            context.delete(pokemon)
            try context.save()
        }
        catch {
            debugPrint("==> Erro ao tentar excluir pokemon")
        }
        self.reloadAll()
    }
    
    private func reloadAll() {
        self.loadList()
        self.tabela.reloadData()
    }
    
    func save(pokemon: Pokemon) {
        if self.listaPokemon.first(where: { $0.value(forKey: "id") as? Int == pokemon.id }) != nil {
            return // faz sair da função inteira
        }
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let context = appDelegate.persistentContainer.viewContext
        if let entity = NSEntityDescription.entity(forEntityName: "PokemonEntity", in: context) {
            let pk = NSManagedObject(entity: entity, insertInto: context)
            pk.setValue(pokemon.id ?? 0, forKey: "id")
            pk.setValue(pokemon.sprites?.front_default ?? "", forKey: "frontImage")
            pk.setValue(pokemon.name ?? "", forKey: "name")
            pk.setValue(pokemon.abilities?[0].ability?.name ?? "", forKey: "abilities")
            pk.setValue(pokemon.forms?.count, forKey: "forms")
            pk.setValue(pokemon.height ?? 1, forKey: "height")
            pk.setValue(pokemon.weight ?? 1, forKey: "weight")
            pk.setValue(UUID().uuidString, forKey: "hashId")
        }
        do {
            try context.save()
        }
        catch {
             debugPrint("==> Erro ao salvar pokemon na base de dados CoreData")
        }
        self.reloadAll()
    }
}

extension ViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listaPokemon.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell1") as? PokemonCell
        else {
            return UITableViewCell()
        }
        let item = self.listaPokemon[indexPath.row]
        
        let url = item.value(forKey: "frontImage") as? String ?? ""
        let name = item.value(forKey: "name") as? String ?? ""
        let height = item.value(forKey: "height") as? Int ?? 0
        let weight = item.value(forKey: "weight") as? Int ?? 0
        let forms = item.value(forKey: "forms") as? Int ?? 0
        let id = item.value(forKey: "id") as? Int ?? 0
        
        let details = "Id: \(id) - Forms: \(forms)\nPeso: \(weight) - Altura: \(height)"
        cell.populate(title: name, description: details, url: url)
        cell.layer.borderWidth = 15
        cell.layer.cornerRadius = 15
        let hexColor = 0x2c3340
        let red = CGFloat((hexColor & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hexColor & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(hexColor & 0x0000FF) / 255.0

        cell.layer.borderColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0).cgColor
        return cell
    }
}

extension ViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150.0
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: "Delete", handler: { [weak self] _,_,_ in
            guard let validSelf = self else {return}
            let item = validSelf.listaPokemon[indexPath.row]
            validSelf.delete(pokemon: item)
        })
        deleteAction.backgroundColor = .red
        deleteAction.image = .init(systemName: "trash", withConfiguration: nil)
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
