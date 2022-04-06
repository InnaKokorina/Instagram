//
//  NetworkManager.swift
//  Instagram
//
//  Created by Inna Kokorina on 28.03.2022.
//

import Foundation
import CoreText
import UIKit

protocol NetworkManagerDelegate {
    func didUpdateImages(_ networkManager:NetworkManager, image: [DataModel])
    func didFailWithError()
}

protocol NetworkManagerCellDelegate {
    func didUpdateImageCell(_ networkManager: NetworkManager, with: Data)
}
struct NetworkManager {
    
    var delegate: NetworkManagerDelegate?
    var delegateCell: NetworkManagerCellDelegate?
    var dataModel = [DataModel]()
    
    
    // MARK: - fetch data from URL
    func fetchImages(imagesCount n: Int) {
        let url = "https://zoo-animal-api.herokuapp.com/animals/rand/\(n)"
        
        performRequest(url: url) { result in
            print("here")
            var dbmodel = DataModel()
            var dataModel = [DataModel]()
            guard let safeResult = result
            else {
                self.delegate?.didFailWithError()
                return
            }
            for model in safeResult {
                dbmodel.photoImageUrl = model.image_link
                dbmodel.description = "anymal_type: \(model.animal_type), lifespan: \(model.lifespan), diet: \(model.diet)"
                dbmodel.likesCount = Int.random(in: 0...100)
                dbmodel.author = model.name
                dataModel.append(dbmodel)
            }
            
            self.delegate?.didUpdateImages(self, image: dataModel)
        }
    }
    
    func performRequest(url: String?, completion:@escaping ([ImagesModelAPI]?) -> Void) {
        guard
            let stringUrl = url,
            let url = URL(string: stringUrl)
        else {
            completion(nil)
            return
        }
        DispatchQueue.global(qos: .background).async {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if error == nil{
                    let decoder = JSONDecoder()
                    if let safeData = data {
                        do {
                            let result = try decoder.decode([ImagesModelAPI].self, from: safeData)
                            completion(result)
                        } catch {
                            completion(nil)
                            return
                        }
                    }
                }
            }
            task.resume()
        }
    }
    // MARK: - downloadImage
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        DispatchQueue.global(qos: .background).async{
            URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
        }
    }
    func downloadImage(from url: URL) -> Void  {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            delegateCell?.didUpdateImageCell(self ,with: data)
        }
    }
}



