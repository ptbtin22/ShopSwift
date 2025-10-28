//
//  ProductDetailsViewController.swift
//  ShoppingApp
//

import UIKit

// ProductDetailsViewController.swift (key parts)
final class ProductDetailsViewController: UIViewController {
    private let viewModel: ProductDetailsViewModel
    private let productView = ProductDetailsView()
    
    

    init(viewModel: ProductDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func loadView() { view = productView }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Re-render whenever VM changes
        viewModel.onUpdate = { [weak self] in self?.render() }
        // initial render
        setupNavigationBar()
        
        render()
    }
    
    private func setupNavigationBar() {
            // Create trash/clear button
        let cartButton = UIBarButtonItem(
            image: UIImage(systemName: "cart.fill"),
            style: .plain,
            target: self,
            action: #selector(onCartButtonTapped)
        )
        
        navigationItem.rightBarButtonItem = cartButton
    }
    
    @objc func onCartButtonTapped() {
        
    }

    private func render() {
        productView.render(.init(
            title:       viewModel.titleText,
            category:    viewModel.categoryText,
            price:       viewModel.priceText,
            imageURL:    viewModel.imageURL,
            rating:      viewModel.ratingText,
            stockCount:  viewModel.stockCount,
            stockText:   viewModel.stockText,
            description: viewModel.descriptionText,
            isFavorite:  viewModel.isFavorite,
            quantity:    viewModel.quantity,
            onIncrease:  { [weak self] in self?.viewModel.increase() },
            onDecrease:  { [weak self] in self?.viewModel.decrease() },
            onFavoriteTapped: { [weak self] in self?.viewModel.toggleFavorite() },
            // We ignore the incoming qty and use VM.quantity to be source of truth
            onAddToCartTapped: { [weak self] _ in
                guard let self else { return }
                if self.viewModel.quantity <= 0 {
                    self.presentAlertOnMainThread(
                        title: "Select a quantity",
                        message: "Please choose at least 1 item before adding to cart.",
                        buttonTitle: "OK"
                    )
                    return
                }
                self.viewModel.addToCart()
                self.presentAlertOnMainThread(
                    title: "Added to Cart",
                    message: "\(self.viewModel.quantity) × \(self.viewModel.titleText) added.",
                    buttonTitle: "OK"
                )
            }
        ))
    }
}
