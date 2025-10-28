//
//  CartViewController.swift
//  ShoppingApp
//

import UIKit
import RxSwift

final class CartViewController: UIViewController {
    private let cartView = CartView()
    private let cartViewModel: CartViewModel
    private let disposeBag = DisposeBag()
    
    init(cartStore: CartStore = UserDefaultsCartStore()) {
        self.cartViewModel = CartViewModel(store: cartStore)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = cartView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Cart"
        bindViewModel()
    }
    
    private func bindViewModel() {
        // Subscribe to cart items changes
        cartViewModel.items
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.render()
            })
            .disposed(by: disposeBag)
    }

    private func render() {
        cartView.render(.init(items: cartViewModel.items.value, onDelete: {_ in }, onEdit: {_ in }))
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: String(format: "Total: %@", cartViewModel.subtotalFormatted),
            style: .plain,
            target: nil,
            action: nil
        )
    }
}
