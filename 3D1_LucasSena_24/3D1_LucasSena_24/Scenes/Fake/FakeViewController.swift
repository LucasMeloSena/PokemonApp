import UIKit

class FakeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: { [weak self] in
            guard let self = self else {return}
            /* guard let é o try catch para variaveis que podem ser nulaveis
                usado para utilizar a variavel no proximo bloco de codigo
             */
            self.navigationController?.popViewController(animated: false)
        })
    }
}
