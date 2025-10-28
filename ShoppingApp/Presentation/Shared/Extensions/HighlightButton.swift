//
//  UIButton+Extensions.swift
//  ShoppingApp
//
//  Created by Tín Phạm on 13/10/25.
//

import UIKit

final class HighlightButton: UIButton {

    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    convenience init(
        title: String,
        background: UIColor,
        foreground: UIColor = .white,
        cornerRadius: CGFloat = 10,
        height: CGFloat? = nil,
        font: UIFont = .boldSystemFont(ofSize: 17)
    ) {
        self.init(type: .system)

        var configuration = UIButton.Configuration.filled()
        configuration.title = title
        configuration.baseBackgroundColor = background
        configuration.baseForegroundColor = foreground
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20)
        configuration.cornerStyle = .fixed
        configuration.background.cornerRadius = cornerRadius

        var titleAttr = AttributeContainer()
        titleAttr.font = font
        configuration.attributedTitle = AttributedString(title, attributes: titleAttr)

        self.configuration = configuration

        if let h = height { heightAnchor.constraint(equalToConstant: h).isActive = true }
    }

    convenience init(
        systemImageName: String,
        background: UIColor,
        tint: UIColor = .label,
        cornerRadius: CGFloat = 10,
        height: CGFloat? = nil
    ) {
        self.init(type: .system)

        var configuration = UIButton.Configuration.filled()
        configuration.image = UIImage(systemName: systemImageName)
        configuration.baseBackgroundColor = background
        configuration.baseForegroundColor = tint
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        configuration.cornerStyle = .fixed
        configuration.background.cornerRadius = cornerRadius

        self.configuration = configuration

        if let h = height { heightAnchor.constraint(equalToConstant: h).isActive = true }
    }

    required init?(coder: NSCoder) { super.init(coder: coder); commonInit() }

    private func commonInit() {
        // Custom highlight animation is handled in isHighlighted property observer
    }

    // MARK: - Interaction feedback
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.12) {
                self.alpha = self.isHighlighted ? 0.7 : 1.0
                self.transform = self.isHighlighted
                    ? CGAffineTransform(scaleX: 0.96, y: 0.96)
                    : .identity
            }
        }
    }

    // Optional: soften when disabled
    override var isEnabled: Bool {
        didSet {
            UIView.animate(withDuration: 0.12) {
                self.alpha = self.isEnabled ? 1.0 : 0.5
            }
        }
    }
}
