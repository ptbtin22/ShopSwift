//
//  FavoritesViewController.swift
//  ShoppingApp
//
//  Created by Tín Phạm on 16/10/25.
//

import UIKit
import RxSwift

final class FavoritesViewController: UIViewController {

    // MARK: - Coordinator
    weak var coordinator: AppCoordinator?

    // MARK: - Dependencies
    private let viewModel: FavoritesViewModel
    private let disposeBag = DisposeBag()

    // MARK: - UI
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let refreshControl = UIRefreshControl()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No favorites yet"
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18, weight: .regular)
        return label
    }()

    // MARK: - State
    private var cellViewModels: [FavoritesViewModel.FavoritesCellViewModel] = []

    // MARK: - Init
    init(api: ProductAPI, store: FavoritesStore = UserDefaultsFavoritesStore()) {
        self.viewModel = FavoritesViewModel(api: api, store: store)
        super.init(nibName: nil, bundle: nil)
        self.title = "Favorites"
        self.tabBarItem = UITabBarItem(
            title: "Favorites",
            image: UIImage(systemName: "heart"),
            selectedImage: UIImage(systemName: "heart.fill")
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureTable()
        bindViewModel()
        viewModel.load()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.refresh()
    }

    // MARK: - UI Setup
    private func configureTable() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
        
        tableView.refreshControl = refreshControl
        
        // Reactive pull-to-refresh
        refreshControl.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] in
                self?.viewModel.refresh()
            })
            .disposed(by: disposeBag)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Binding
    private func bindViewModel() {
        viewModel.state
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] state in
                self?.handleStateChange(state)
            })
            .disposed(by: disposeBag)
    }
    
    private func handleStateChange(_ state: FavoritesViewModel.ViewState) {
        switch state {
        case .idle:
            break
            
        case .loading:
            // Show loading spinner (optional)
            break
            
        case .loaded(let cellViewModels):
            self.cellViewModels = cellViewModels
            tableView.backgroundView = nil
            tableView.reloadData()
            refreshControl.endRefreshing()
            
        case .empty:
            self.cellViewModels = []
            tableView.backgroundView = emptyLabel
            tableView.reloadData()
            refreshControl.endRefreshing()
            
        case .error(let message):
            refreshControl.endRefreshing()
            showError(message: message)
        }
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension FavoritesViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cellViewModels.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let cellViewModel = cellViewModels[indexPath.row]

        var config = cell.defaultContentConfiguration()
        config.text = cellViewModel.title
        config.secondaryText = cellViewModel.description
        config.secondaryTextProperties.numberOfLines = 3
        
        if cellViewModel.isLoading {
            cell.accessoryType = .none
            cell.selectionStyle = .none
        } else {
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .default
        }

        cell.contentConfiguration = config
        return cell
    }

    func tableView(_ tv: UITableView, didSelectRowAt indexPath: IndexPath) {
        tv.deselectRow(at: indexPath, animated: true)
        
        let cellViewModel = cellViewModels[indexPath.row]
        
        // Don't navigate if still loading
        guard !cellViewModel.isLoading else { return }
        
        guard let product = viewModel.didSelectProduct(at: indexPath.row) else { return }
        
        // WARNING: fix later
//        UIApplication.sceneDelegate?.showProductDetails(product, from: self)
    }
}
