//
//  ShoppingAppTests.swift
//  ShoppingAppTests
//
//  Created by Tín Phạm on 11/10/25.
//

import XCTest
@testable import ShoppingApp

// MARK: - Mock Repository
final class MockProductRepository: ProductRepository {
    var shouldThrowError = false
    var mockProducts: [Product] = []
    var fetchProductsCallCount = 0
    var lastFetchLimit: Int?
    
    func fetchProducts(limit: Int?) async throws -> [Product] {
        fetchProductsCallCount += 1
        lastFetchLimit = limit
        
        if shouldThrowError {
            throw NSError(domain: "TestError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Network error"])
        }
        
        return mockProducts
    }
}

// MARK: - MainViewModel Tests
@MainActor
final class MainViewModelTests: XCTestCase {
    
    var sut: MainViewModel!
    var mockRepository: MockProductRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockProductRepository()
        sut = MainViewModel(repository: mockRepository)
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState_ShouldBeIdle() {
        // Given & When: ViewModel is initialized in setUp
        
        // Then
        if case .idle = sut.state {
            // Success
        } else {
            XCTFail("Initial state should be idle, but got \(sut.state)")
        }
    }
    
    // MARK: - Loading Products Tests
    
    func testLoadProducts_ShouldChangeStateToLoading() async {
        // Given
        mockRepository.mockProducts = [createMockProduct(id: 1)]
        var capturedStates: [MainViewModel.ViewState] = []
        
        sut.onStateChange = { state in
            capturedStates.append(state)
        }
        
        // When
        sut.load()
        
        // Give it a moment to process
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Then
        XCTAssertTrue(capturedStates.contains { state in
            if case .loading = state { return true }
            return false
        }, "State should have changed to loading")
    }
    
    func testLoadProducts_WithSuccess_ShouldReturnLoadedStateWithCellViewModels() async {
        // Given
        let mockProducts = [
            createMockProduct(id: 1, name: "iPhone 15", category: "Electronics", price: 999.99),
            createMockProduct(id: 2, name: "MacBook Pro", category: "Computers", price: 2499.50)
        ]
        mockRepository.mockProducts = mockProducts
        
        let expectation = XCTestExpectation(description: "Load products")
        var finalState: MainViewModel.ViewState?
        
        sut.onStateChange = { state in
            finalState = state
            if case .loaded = state {
                expectation.fulfill()
            }
        }
        
        // When
        sut.load()
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        
        guard case .loaded(let cellViewModels) = finalState else {
            XCTFail("Expected loaded state")
            return
        }
        
        XCTAssertEqual(cellViewModels.count, 2)
        XCTAssertEqual(cellViewModels[0].id, 1)
        XCTAssertEqual(cellViewModels[0].title, "iPhone 15")
        XCTAssertTrue(cellViewModels[0].subtitle.contains("Electronics"), "Subtitle should contain category")
        XCTAssertTrue(cellViewModels[0].subtitle.contains("999.99"), "Subtitle should contain price")
        XCTAssertEqual(cellViewModels[1].id, 2)
        XCTAssertEqual(cellViewModels[1].title, "MacBook Pro")
        XCTAssertTrue(cellViewModels[1].subtitle.contains("Computers"), "Subtitle should contain category")
        // Price can be formatted as either 2499.50 or 2,499.50 depending on locale
        XCTAssertTrue(cellViewModels[1].subtitle.contains("2499.50") || cellViewModels[1].subtitle.contains("2,499.50"), 
                      "Subtitle should contain price, got: \(cellViewModels[1].subtitle)")
    }
    
    func testLoadProducts_WithError_ShouldReturnErrorState() async {
        // Given
        mockRepository.shouldThrowError = true
        
        let expectation = XCTestExpectation(description: "Load products with error")
        var finalState: MainViewModel.ViewState?
        
        sut.onStateChange = { state in
            finalState = state
            if case .error = state {
                expectation.fulfill()
            }
        }
        
        // When
        sut.load()
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        
        guard case .error(let message) = finalState else {
            XCTFail("Expected error state")
            return
        }
        
        XCTAssertEqual(message, "Network error")
    }
    
    func testLoadProducts_ShouldCallRepository() async {
        // Given
        mockRepository.mockProducts = [createMockProduct(id: 1)]
        let expectation = XCTestExpectation(description: "Repository called")
        
        sut.onStateChange = { state in
            if case .loaded = state {
                expectation.fulfill()
            }
        }
        
        // When
        sut.load(limit: 10)
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertEqual(mockRepository.fetchProductsCallCount, 1)
        XCTAssertEqual(mockRepository.lastFetchLimit, 10)
    }
    
    // MARK: - Product Selection Tests
    
    func testDidSelectProduct_WithValidIndex_ShouldReturnProduct() async {
        // Given
        let mockProducts = [
            createMockProduct(id: 1, name: "Product 1"),
            createMockProduct(id: 2, name: "Product 2")
        ]
        mockRepository.mockProducts = mockProducts
        
        let expectation = XCTestExpectation(description: "Products loaded")
        sut.onStateChange = { state in
            if case .loaded = state {
                expectation.fulfill()
            }
        }
        
        sut.load()
        await fulfillment(of: [expectation], timeout: 2.0)
        
        // When
        let selectedProduct = sut.didSelectProduct(at: 1)
        
        // Then
        XCTAssertNotNil(selectedProduct)
        XCTAssertEqual(selectedProduct?.id, 2)
        XCTAssertEqual(selectedProduct?.name, "Product 2")
    }
    
    func testDidSelectProduct_WithInvalidIndex_ShouldReturnNil() async {
        // Given
        mockRepository.mockProducts = [createMockProduct(id: 1)]
        
        let expectation = XCTestExpectation(description: "Products loaded")
        sut.onStateChange = { state in
            if case .loaded = state {
                expectation.fulfill()
            }
        }
        
        sut.load()
        await fulfillment(of: [expectation], timeout: 2.0)
        
        // When
        let selectedProduct = sut.didSelectProduct(at: 999)
        
        // Then
        XCTAssertNil(selectedProduct, "Should return nil for invalid index")
    }
    
    func testDidSelectProduct_WithNegativeIndex_ShouldReturnNil() {
        // Given & When
        let selectedProduct = sut.didSelectProduct(at: -1)
        
        // Then
        XCTAssertNil(selectedProduct, "Should return nil for negative index")
    }
    
    // MARK: - Data Transformation Tests
    
    func testCellViewModel_ShouldFormatPriceCorrectly() async {
        // Given
        let products = [
            createMockProduct(id: 1, price: 10.5),
            createMockProduct(id: 2, price: 999.99),
            createMockProduct(id: 3, price: 1234.567)
        ]
        mockRepository.mockProducts = products
        
        let expectation = XCTestExpectation(description: "Products loaded")
        var cellViewModels: [MainViewModel.ProductCellViewModel]?
        
        sut.onStateChange = { state in
            if case .loaded(let vms) = state {
                cellViewModels = vms
                expectation.fulfill()
            }
        }
        
        // When
        sut.load()
        await fulfillment(of: [expectation], timeout: 2.0)
        
        // Then
        XCTAssertNotNil(cellViewModels)
        // Test that prices are formatted to 2 decimal places
        XCTAssertTrue(cellViewModels![0].subtitle.contains("10.50"))
        XCTAssertTrue(cellViewModels![1].subtitle.contains("999.99"))
        XCTAssertTrue(cellViewModels![2].subtitle.contains("1") && cellViewModels![2].subtitle.contains("234.57"))
    }
    
    func testCellViewModel_ShouldCombineCategoryAndPrice() async {
        // Given
        let product = createMockProduct(id: 1, name: "Test", category: "Electronics", price: 99.99)
        mockRepository.mockProducts = [product]
        
        let expectation = XCTestExpectation(description: "Products loaded")
        var cellViewModel: MainViewModel.ProductCellViewModel?
        
        sut.onStateChange = { state in
            if case .loaded(let vms) = state {
                cellViewModel = vms.first
                expectation.fulfill()
            }
        }
        
        // When
        sut.load()
        await fulfillment(of: [expectation], timeout: 2.0)
        
        // Then
        XCTAssertNotNil(cellViewModel)
        XCTAssertEqual(cellViewModel?.subtitle, "Electronics • $99.99")
    }
    
    // MARK: - Helper Methods
    
    private func createMockProduct(
        id: Int,
        name: String = "Test Product",
        category: String = "Category",
        price: Double = 99.99,
        imageURL: URL? = URL(string: "https://example.com/image.jpg"),
        stock: Int = 10,
        rating: Double = 4.5,
        description: String = "Test description"
    ) -> Product {
        return Product(
            id: id,
            name: name,
            category: category,
            price: price,
            imageURL: imageURL,
            stock: stock,
            rating: rating,
            description: description
        )
    }
}

// MARK: - Example Test to Keep
final class ShoppingAppTests: XCTestCase {
    
    func testExample() throws {
        // This is an example showing the Given-When-Then pattern
        
        // Given (Arrange): Set up test data
        let expectedValue = 5
        
        // When (Act): Execute the code being tested
        let actualValue = 2 + 3
        
        // Then (Assert): Verify the results
        XCTAssertEqual(actualValue, expectedValue, "2 + 3 should equal 5")
    }
}
