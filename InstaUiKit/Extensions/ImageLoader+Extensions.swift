//
//  ImageLoader+Extensions.swift
//  InstaUiKit
//
//  Created by IPS-161 on 11/08/23.
//
import UIKit
import Kingfisher

class ImageLoader {
    static func loadImage(for url: URL?, into imageView: UIImageView, withPlaceholder placeholder: UIImage? = nil) {
        guard let url = url, !url.absoluteString.isEmpty else {
            imageView.image = placeholder
            return
        }
        
        let processor = DownsamplingImageProcessor(size: imageView.bounds.size)
                         |> RoundCornerImageProcessor(cornerRadius: 20)
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(
            with: url,
            placeholder: placeholder,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
            ])
        {
            result in
            switch result {
            case .success(let value):
                print("Image loaded successfully from: \(value.source.url?.absoluteString ?? "")")
            case .failure(let error):
                print("Image loading failed: \(error.localizedDescription)")
            }
        }
    }
}
