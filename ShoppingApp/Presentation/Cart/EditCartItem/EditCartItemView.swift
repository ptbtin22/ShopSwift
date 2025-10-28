//
//  EditCartItemView.swift
//  ShoppingApp
//
//  Created by Tín Phạm on 14/10/25.
//

import UIKit


final class EditCartItemView: UIView {
    struct Props {
        let itemName: String
        let quantity: Int
        let onQuantityChanged: (Int) -> Void
        let onSaveTapped: () -> Void
    }
    
    private var props: Props?
    
    private let nameLabel = UILabel()
    private let quantityLabel = UILabel()
    private let stepper = UIStepper()
    private let saveButton = UIButton(type: .system)
    private let stack = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = .systemBackground

        stack.axis = .vertical
        stack.spacing = 24
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24)
        ])

        nameLabel.font = .systemFont(ofSize: 22, weight: .semibold)

        quantityLabel.font = .systemFont(ofSize: 18, weight: .medium)

        stepper.minimumValue = 0
        stepper.maximumValue = 99
        stepper.addTarget(self, action: #selector(stepperChanged), for: .valueChanged)

        saveButton.setTitle("Save", for: .normal)
        saveButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        saveButton.backgroundColor = .systemPurple
        saveButton.tintColor = .white
        saveButton.layer.cornerRadius = 10
        saveButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 30, bottom: 12, right: 30)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        [nameLabel, quantityLabel, stepper, saveButton].forEach { stack.addArrangedSubview($0) }
    }

    func render(_ p: Props) {
        props = p
        nameLabel.text = p.itemName
        quantityLabel.text = "Quantity: \(p.quantity)"
        stepper.value = Double(p.quantity)
    }

    @objc private func stepperChanged() {
        let value = Int(stepper.value)
        quantityLabel.text = "Quantity: \(value)"
        props?.onQuantityChanged(value)
    }

    @objc private func saveTapped() {
        props?.onSaveTapped()
    }
}
