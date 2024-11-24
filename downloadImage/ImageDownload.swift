//
//  ImageDownload.swift


//  Created by Александр Белый on 24.11.2024.
//

import UIKit

enum DownloadOptions: Hashable {
    enum From: Hashable {
        case disk
        case memory
    }

    case circle
    case cached(From)
    case resize
}

protocol Downloadable {
    func loadImage(from url: URL, withOptions: [DownloadOptions])
}

extension Downloadable where Self: UIImageView {
    func loadImage(from url: URL, withOptions options: [DownloadOptions]) {
        let uniqueOptions = Array(Set(options)) 

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, let image = UIImage(data: data) else { return }
            var processedImage = image

            for option in uniqueOptions {
                switch option {
                case .circle:
                    processedImage = processedImage.rounded()
                case .resize:
                    DispatchQueue.main.async {
                        if let bounds = self?.bounds {
                            processedImage = processedImage.resized(to: bounds.size)
                        }
                    }
                default:
                    break
                }
            }

            DispatchQueue.main.async {
                self?.image = processedImage
            }
        }.resume()
    }
}
