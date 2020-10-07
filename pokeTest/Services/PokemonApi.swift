import Foundation
import UIKit

class PokemonApi {
    
    func fetchPokemon(completion: @escaping([PokemonData]) -> ()) {
        var pokemonArray = [PokemonData]()
        
        fetchData { (results) in
            for (key, result) in results.enumerated() {
                guard let name = result["name"] as? String else { return }
                let id = key + 1
                let imageUrl = IMG_BASE_URL + "\(id).png"
                
                self.setImage(withUrlString: imageUrl, completion: { (image) in
                    let pokemon = PokemonData(id: id, name: name, image: image)
                    pokemonArray.append(pokemon)
                    pokemonArray.sort(by: { (poke1, poke2) -> Bool in
                        poke1.id < poke2.id
                    })
                    completion(pokemonArray)
                })
            }
        }
    }
    
    private func setImage(withUrlString urlString: String, completion: @escaping(UIImage) -> ()) {
        self.beginURLSession(with: urlString) { (data) in
            guard let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
    
    private func fetchData(completionHandler: @escaping([[String: AnyObject]]) -> ()){
        beginURLSession(with: BASE_URL_LIMITED) { (data) in
            do {
                guard let dictonary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] else {return}
                if let results = dictonary["results"] as? [[String: AnyObject]] {
                    
                    completionHandler(results)
                }
            }catch let error {
                print("Failed to fetch data with errors: ", error)
            }
        }
    }
    
//    func fetchPokemonData(completionHandler: @escaping (PokemonData) -> Void){
//
//        guard let url = URL(string: BASE_URL) else { return }
//
//        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
//            guard let data = data else { return }
//            let jsonDecoder = JSONDecoder()
//            do{
//                let pokemon = try jsonDecoder.decode(PokemonData.self, from: data)
//                completionHandler(pokemon)
//            }catch{
//                let error = error
//                print(error)
//            }
//
//
//        }.resume()
//    }
    
    private func beginURLSession(with urlString: String, completionHandler: @escaping(Data) -> ()) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Failed to fetch pokemon with error: ", error)
                return
            }
            
            guard let data = data else { return }
            completionHandler(data)
        }.resume()
    }
}
