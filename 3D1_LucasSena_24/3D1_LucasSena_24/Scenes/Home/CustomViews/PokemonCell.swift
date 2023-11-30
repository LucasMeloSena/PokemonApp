import UIKit
import Kingfisher

class PokemonCell: UITableViewCell {
    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak var descriptionLabel : UILabel!
    @IBOutlet weak var pokemonView : UIImageView!
    
    func populate(title: String, description: String, url: String) {
        self.titleLabel.text = title
        self.descriptionLabel.text = description
        self.pokemonView.loadFromUrl(url)
    }
}
