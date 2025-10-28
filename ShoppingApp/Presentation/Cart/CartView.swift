//
//  CartView.swift
//  ShoppingApp
//

import UIKit

final class CartView: UIView {
    struct Props {
        let items: [CartItem]
        let onDelete: (IndexPath) -> Void
        let onEdit: (IndexPath) -> Void
    }
    
    private var props: Props?
    private var items: [CartItem] = []
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let orderButton = HighlightButton(
        title: "Place Order",
        background: .systemPurple,
        foreground: .white,
        cornerRadius: 12,
        height: 50
    )
    private let padding: CGFloat = 20
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setup() {
        backgroundColor = .systemBackground
        configureTableView()
        configureOrderButton()
    }
    
    private func configureTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func configureOrderButton() {
        orderButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(orderButton)
        
        NSLayoutConstraint.activate([
            orderButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -padding),
            orderButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            orderButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            orderButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    func render(_ p: Props) {
        self.props = p
        self.items = p.items
        tableView.reloadData()
    }
}

extension CartView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = "\(item.title) (\(item.quantity))"
        content.secondaryText = String(format: "$%.2f", item.priceCents * item.quantity / 100)
        cell.contentConfiguration = content
        return cell
    }
}

extension CartView: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _,_,done in
            self?.props?.onDelete(indexPath)   // bubble to VC/VM
            done(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        let edit = UIContextualAction(style: .normal, title: "Edit") { [weak self] _,_,done in
            self?.props?.onEdit(indexPath)   // bubble to VC/VM
            done(true)
        }
        return UISwipeActionsConfiguration(actions: [edit])
    }
}
