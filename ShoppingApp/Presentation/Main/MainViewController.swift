//
//  MainViewController.swift
//  ShoppingApp
//
//  Created by Tín Phạm on 12/10/25.
//

import UIKit
import RxSwift
import RxCocoa

final class MainViewController: UIViewController {
    
    // MARK: - Coordinator
    weak var coordinator: AppCoordinator?

    private let viewModel: MainViewModel
    private let mainView = MainView()
    private let disposeBag = DisposeBag()
    
    private var cellViewModels: [MainViewModel.ProductCellViewModel] = []
    
    // Pagination
    private var currentPage = 0
    private let perPage = 20
    private var isLoadingMore = false
    private var hasMore = true

    // MARK: DI
    init(productRepository: ProductRepository) {
        self.viewModel = MainViewModel(repository: productRepository)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("Use init(productRepository:)") }

    // MARK: Lifecycle
    override func loadView() { view = mainView }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Products"
        setupNavigationBar()
        setupTable()
        bindViewModel()
        setupSearch()
        loadInitialData()
    }
    
    private func setupNavigationBar() {
        // Add logout button to left side
        let logoutButton = UIBarButtonItem(
            title: "Logout",
            style: .plain,
            target: self,
            action: #selector(logoutTapped)
        )
        logoutButton.tintColor = .systemRed
        navigationItem.rightBarButtonItem = logoutButton
    }
    
    @objc private func logoutTapped() {
        let alert = UIAlertController(
            title: "Logout",
            message: "Are you sure you want to logout?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { [weak self] _ in
            self?.coordinator?.logout()
        })
        
        present(alert, animated: true)
    }
    
    private func loadInitialData() {
        currentPage = 0
        viewModel.load(offset: currentPage * perPage)
    }

    private func setupTable() {
        let tableView = mainView.tableView
        tableView.register(ProductCell.self, forCellReuseIdentifier: ProductCell.reuseID)
        tableView.dataSource = self
        tableView.delegate = self
        
        // Reactive pull-to-refresh
        mainView.refreshControl.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.currentPage = 0
                self.viewModel.load(offset: 0)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupSearch() {
        mainView.searchTextField.rx.text.orEmpty
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] query in
                print("🔍 Searching for: \(query)")
                self?.viewModel.search(query: query)
            })
            .disposed(by: disposeBag)
    }

    private func bindViewModel() {
        // Subscribe to state changes
        viewModel.state
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] state in
                self?.handleStateChange(state)
            })
            .disposed(by: disposeBag)
        
        // Subscribe to hasMore changes
        viewModel.hasMore
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] hasMore in
                self?.hasMore = hasMore
            })
            .disposed(by: disposeBag)
    }
    
    private func handleStateChange(_ state: MainViewModel.ViewState) {
        switch state {
        case .idle:
            break
            
        case .loading:
            // Only show refresh control if it's already visible (user pulled)
            // Don't force it on initial load
            if mainView.refreshControl.isRefreshing {
                // Already refreshing, keep it going
            }
            
        case .loadingMore:
            // Show loading indicator in footer (optional)
            print("📦 Loading more products...")
            
        case .loaded(let cellViewModels):
            self.cellViewModels = cellViewModels
            mainView.tableView.reloadData()
            mainView.refreshControl.endRefreshing()
            isLoadingMore = false
            
        case .error(let message):
            mainView.refreshControl.endRefreshing()
            isLoadingMore = false
            showError(message: message)
        }
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Load More Logic
    private func loadMoreIfNeeded() {
        guard hasMore && !isLoadingMore else {
            return
        }
        
        isLoadingMore = true
        currentPage += 1
        
        let offset = currentPage * perPage
        print("📥 Loading more: page \(currentPage), offset \(offset)")
        
        viewModel.load(offset: offset)
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int {
        cellViewModels.count
    }

    func tableView(_ tv: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellViewModel = cellViewModels[indexPath.row]
        let cell = tv.dequeueReusableCell(withIdentifier: ProductCell.reuseID, for: indexPath) as! ProductCell
        cell.configure(.init(
            title: cellViewModel.title,
            subtitle: cellViewModel.subtitle,
            imageURL: cellViewModel.imageURL
        ))
        return cell
    }

    func tableView(_ tv: UITableView, didSelectRowAt indexPath: IndexPath) {
        tv.deselectRow(at: indexPath, animated: true)
        guard let product = viewModel.didSelectProduct(at: indexPath.row) else { return }
        // WARNING: fix later
//        UIApplication.sceneDelegate?.showProductDetails(product, from: self)
    }
    
    // MARK: - Pagination Trigger
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Trigger load more when user is 3 items away from the bottom
        let threshold = cellViewModels.count - 2
        if indexPath.row >= threshold {
            loadMoreIfNeeded()
        }
    }
}
