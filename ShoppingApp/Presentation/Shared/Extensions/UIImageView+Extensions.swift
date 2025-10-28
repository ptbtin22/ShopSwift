//
//  UIImageView+Extensions.swift
//  ShoppingApp
//
//  Created by Tín Phạm on 13/10/25.
//

import UIKit


extension UIImageView {
    func load(_ url: URL?) {
        guard let url else { return }
        
        URLSession.shared.dataTask(with: url) { data, resp, err in
            guard let data, let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                self.image = image
            }
        }.resume()
    }
}
