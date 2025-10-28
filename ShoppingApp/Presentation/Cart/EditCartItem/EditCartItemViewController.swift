//
//  EditCartItemViewController.swift
//  ShoppingApp
//
//  Created by Tín Phạm on 14/10/25.
//

import UIKit

final class EditCartItemViewController: UIViewController {

    private let editCartItemView = EditCartItemView()
    private let viewModel: EditCartItemViewModel

    init(viewModel: EditCartItemViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("Use init(viewModel:)") }

    override func loadView() {
        view = editCartItemView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Edit Item"
        bind()
        render()
    }

    private func bind() {
        viewModel.onSave = { [weak self] updatedItem in
            // Notify whoever presented this VC
            NotificationCenter.default.post(
                name: .cartDidChange,
                object: nil,
                userInfo: ["updatedItem": updatedItem]
            )
            self?.dismiss(animated: true)
        }
    }

    private func render() {
        editCartItemView.render(
            .init(
                itemName: viewModel.itemName,
                quantity: viewModel.quantity,
                onQuantityChanged: { [weak self] qty in
                    self?.viewModel.updateQuantity(qty)
                },
                onSaveTapped: { [weak self] in
                    self?.viewModel.save()
                }
            )
        )
    }
}
