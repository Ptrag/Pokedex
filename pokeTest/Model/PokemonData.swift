import Foundation
import UIKit

class PokemonData {
    var id: Int!
    var basicInfoUrl: String?
    var name: String!
    var image: UIImage?
    
    init(id: Int, name: String, image: UIImage) {
        self.id = id
        self.name = name
        self.image = image
        self.basicInfoUrl = BASE_URL + "\(id)"
    }
}


//struct PokemonData: Codable {
//    let next: String
//    let count: Int
//    let results: [Result]
//}
//
//struct Result: Codable {
//    var name: String
//    var url: String
//}
