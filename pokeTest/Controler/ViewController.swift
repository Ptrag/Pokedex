import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionViewOutlet: UICollectionView!
    var searchBar: UISearchBar!
    var pokemonApi = PokemonApi()
    var pokemonData = [PokemonData]()
    var afterSearchPokemonResults = [PokemonData]()
    var searchUsed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        fetchPokemon()
        collectionViewOutlet.dataSource = self
        
    }
    @objc func handleClick() {
        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.showsCancelButton = true
        searchBar.becomeFirstResponder()
        searchBar.tintColor = .white
        navigationItem.titleView = searchBar
    }
    
    func setupView() {
        navigationItem.title = "Pokedex"
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.barTintColor = .orange
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(handleClick))
        collectionViewOutlet.backgroundColor = .white
        
    }
    func fetchPokemon() {
        pokemonApi.fetchPokemon { (pokemonData) in
            self.pokemonData = pokemonData
            self.collectionViewOutlet.reloadData()
        }
    }
    

}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchUsed ? afterSearchPokemonResults.count : pokemonData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PokeCell
        cell.lblText.text = searchUsed ? afterSearchPokemonResults[indexPath.row].name.localizedUppercase : pokemonData[indexPath.row].name.localizedUppercase
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        cell.imageView.image = searchUsed ? afterSearchPokemonResults[indexPath.row].image : pokemonData[indexPath.row].image
        return cell
    }
    
    
    
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let noOfCellsInRow = 5

        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout

        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))

        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))

        return CGSize(width: size, height: size)
    }
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        navigationItem.titleView = nil
        searchUsed = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchText = searchText.lowercased()
        
        if searchText == "" || searchBar.text == nil {
            searchUsed = false
            collectionViewOutlet.reloadData()
            view.endEditing(true)
        } else {
            searchUsed = true
            afterSearchPokemonResults = pokemonData.filter({ $0.name.range(of: searchText) != nil })
            collectionViewOutlet.reloadData()
        }
    }
}
