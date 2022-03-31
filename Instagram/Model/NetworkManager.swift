//
//  NetworkManager.swift
//  Instagram
//
//  Created by Inna Kokorina on 28.03.2022.
//

import Foundation

protocol NetworkManagerDelegate {
    func didUpdateImages(_ networkManager:NetworkManager, image: [DataModel])
    func didFailWithError(error: Error)
}
struct NetworkManager {
    
    var delegate: NetworkManagerDelegate?
    var dataModel = [DataModel]()
    
    // MARK: - fetch data from URL
    func fetchImages() {
        let url = "https://zoo-animal-api.herokuapp.com/animals/rand/10"
        performRequest(with: url)
    }
    
    func performRequest(with url: String) {
        if let url = URL(string: url) {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if error == nil{
                    let decoder = JSONDecoder()
                    if let safeData = data {
                        do {
                            let result = try decoder.decode([ImagesModelAPI].self, from: safeData)
                            var dbmodel = DataModel()
                            var dataModel = [DataModel]()
                            for model in result {
                                dbmodel.photoImageUrl = model.image_link
                                dbmodel.description = "anymal_type: \(model.animal_type), lifespan: \(model.lifespan), diet: \(model.diet)"
                                dbmodel.likesCount = Int.random(in: 0...100)
                                dbmodel.author = model.name
                                dataModel.append(dbmodel)
                            }
                            delegate?.didUpdateImages(self, image: dataModel)
                            
                        } catch {
                            delegate?.didFailWithError(error: error)
                            
                        }
                    }
                }
            }
            task.resume()
        }
    }
    // MARK: - fetch image from URL
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
}
