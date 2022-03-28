//
//  NetworkManager.swift
//  Instagram
//
//  Created by Inna Kokorina on 28.03.2022.
//

import Foundation

protocol NetworkManagerDelegate {
    func didUpdateImages(_ networkManager:NetworkManager, image: [DataModel])
    func didFailWithError(error:Error)
}
struct NetworkManager {
    
    var delegate: NetworkManagerDelegate?
    private let apiKey = "26357557-9da21e542a629f8ca8cf5dafb"
    var dataModel = [DataModel]()
    
    func fetchImages() {
        let url = "https://pixabay.com/api/?key=\(apiKey)&q=fruits=photo"
        performRequest(with: url)
    }
    
    func performRequest(with url: String) {
        if let url = URL(string: url) {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if error == nil{
                    let decoder = JSONDecoder()
                    if let safeData = data {
                        do {
                            let result = try decoder.decode(ImagesModelAPI.self, from: safeData)
                            var dbmodel = DataModel()
                            var dataModel = [DataModel]()
                            for model in result.hits {
                                dbmodel.photoImageUrl = model.webformatURL
                                dbmodel.description = model.tags
                                dbmodel.likesCount = model.likes
                                dbmodel.author = model.user
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
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
}
