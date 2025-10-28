//
//  CartBadgeButton.swift
//  ShoppingApp
//
//  Created by Tín Phạm on 14/10/25.
//

import UIKit

final class CartBadgeButton: UIButton {
    private let badge = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        let img = UIImage(systemName: "cart")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 18, weight: .medium))
        setImage(img, for: .normal)
        tintColor = .label

        // Badge style
        badge.backgroundColor = .systemRed
        badge.textColor = .white
        badge.font = .systemFont(ofSize: 12, weight: .bold)
        badge.textAlignment = .center
        badge.layer.cornerRadius = 9
        badge.layer.masksToBounds = true
        badge.isHidden = true

        addSubview(badge)
        badge.translatesAutoresizingMaskIntoConstraints = false

        // Position badge at top-right corner of the icon
        NSLayoutConstraint.activate([
            badge.heightAnchor.constraint(equalToConstant: 18),
            badge.centerXAnchor.constraint(equalTo: imageView!.trailingAnchor, constant: -2),
            badge.centerYAnchor.constraint(equalTo: imageView!.topAnchor, constant: 2),
            badge.widthAnchor.constraint(greaterThanOrEqualTo: badge.heightAnchor) // pill shape
        ])

        // Touch feedback (optional)
        addTarget(self, action: #selector(down), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(up), for: [.touchUpInside, .touchCancel, .touchDragExit])
    }

    required init?(coder: NSCoder) { fatalError() }

    func setCount(_ count: Int) {
        if count <= 0 {
            badge.isHidden = true
        } else {
            badge.isHidden = false
            badge.text = count > 99 ? "99+" : "\(count)"
            // Update intrinsic size
            let w = max(18, (badge.intrinsicContentSize.width + 10))
            badge.widthAnchor.constraint(equalToConstant: w).isActive = true
        }
    }

    @objc private func down() { animate(scale: 0.92, alpha: 0.85) }
    @objc private func up()   { animate(scale: 1.0,  alpha: 1.0)  }
    private func animate(scale: CGFloat, alpha: CGFloat) {
        UIView.animate(withDuration: 0.12) {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
            self.alpha = alpha
        }
    }
}
