//
//  ViewModel.swift
//  CompositionalLayoutGrid
//
//  Created by Kevin Hoàng on 19.04.22.
//

import UIKit

final class ViewModel {
    let url = URL(string: "https://picsum.photos/200")!
    var contents: [CellContent] = []
    
    weak var delegate: ViewModelDelegate?
    
    init() {
        for _ in 0...15 {
            getImage()
        }
    }
    
    func getImage() {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            
            DispatchQueue.main.async { [weak self] in
                let image = UIImage(data: data)!
                self?.contents.append(CellContent(image: image))
                self?.delegate?.didLoad()
            }
        }
        
        task.resume()
    }
}

protocol ViewModelDelegate: NSObject {
    func didLoad()
}
