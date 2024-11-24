//
//  ViewModel.swift
//  
//
//  Created by Александр Белый on 24.11.2024.
//
import Foundation
import UIKit

class ImageGridViewModel {
    private let downloadOptions: [DownloadOptions]
    private var imageCache: [URL: UIImage] = [:] // Кэш для изображений

    var images: [ImageModel] = []

    init(downloadOptions: [DownloadOptions]) {
        self.downloadOptions = downloadOptions
    }

    // Загружаем список URL изображений
    func loadRandomImages(completion: @escaping () -> Void) {
        let baseUrls = [
            "https://cdn-icons-png.freepik.com/512/1818/1818334.png",
            "https://cdn-icons-png.freepik.com/512/1818/1818376.png",
            "https://cdn-icons-png.freepik.com/512/1818/1818306.png",
            "https://cdn-icons-png.freepik.com/512/1818/1818283.png",
            "https://cdn-icons-png.freepik.com/512/17925/17925195.png",
            "https://cdn-icons-png.freepik.com/512/16611/16611998.png",
            "https://cdn-icons-png.freepik.com/512/3360/3360323.png",
            "https://cdn-icons-png.freepik.com/512/9602/9602945.png"
        ]

        self.images = (0..<64).map { _ in
            let randomURL = baseUrls.randomElement()!
            return ImageModel(url: URL(string: randomURL)!, options: downloadOptions) 
        }
        completion()
    }

    // Загрузка изображения с кэшированием
    func fetchImage(for url: URL, completion: @escaping (UIImage?) -> Void) {
        // Проверяем кэш
        if let cachedImage = imageCache[url] {
            completion(cachedImage) // Возвращаем из кэша
            return
        }

        // Если в кэше нет, загружаем изображение
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else {
                completion(nil)
                return
            }

            // Применяем опции обработки
            var processedImage = image
            for option in self?.downloadOptions ?? [] {
                switch option {
                case .circle:
                    processedImage = processedImage.rounded()
                case .resize:
                    processedImage = processedImage.resized(to: CGSize(width: 80, height: 80))
                default:
                    break
                }
            }

            // Кэшируем обработанное изображение
            self?.imageCache[url] = processedImage
            
            // Возвращаем изображение
            DispatchQueue.main.async {
                completion(processedImage)
            }
        }.resume()
    }
}
