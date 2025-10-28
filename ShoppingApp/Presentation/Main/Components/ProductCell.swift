//
//  ProductCell.swift
//  ShoppingApp
//
//  Created by Tín Phạm on 12/10/25.
//

import UIKit


struct ProductCellViewData {
    let title: String
    let subtitle: String
    let imageURL: URL?
}

final class ProductCell: UITableViewCell {
    static let reuseID = "ProductCell"

    private let thumbnail = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let hstack = UIStackView()
    private var currentTask: URLSessionDataTask?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator

        thumbnail.contentMode = .scaleAspectFill
        thumbnail.clipsToBounds = true
        thumbnail.layer.cornerRadius = 8
        thumbnail.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            thumbnail.widthAnchor.constraint(equalToConstant: 56),
            thumbnail.heightAnchor.constraint(equalToConstant: 56)
        ])

        let vstack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        vstack.axis = .vertical
        vstack.spacing = 4

        hstack.axis = .horizontal
        hstack.spacing = 12
        hstack.alignment = .center
        hstack.translatesAutoresizingMaskIntoConstraints = false
        hstack.addArrangedSubview(thumbnail)
        hstack.addArrangedSubview(vstack)

        contentView.addSubview(hstack)
        NSLayoutConstraint.activate([
            hstack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            hstack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            hstack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            hstack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])

        titleLabel.font = .preferredFont(forTextStyle: .headline)
        subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        subtitleLabel.textColor = .secondaryLabel
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        currentTask?.cancel()
        currentTask = nil
        thumbnail.image = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
    }

    func configure(_ data: ProductCellViewData) {
        titleLabel.text = data.title
        subtitleLabel.text = data.subtitle
        loadImage(url: data.imageURL)
    }

    private func loadImage(url: URL?) {
        guard let url else { return }
        // Simple demo loader; swap for Nuke/Kingfisher + caching in production
        currentTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self, let data, let img = UIImage(data: data) else { return }
            DispatchQueue.main.async { self.thumbnail.image = img }
        }
        currentTask?.resume()
    }
}
