import UIKit

final class ProductDetailsView: UIView {
    
    struct Props {
        let title: String
        let category: String
        let price: String
        let imageURL: URL?
        let rating: String
        let stockCount: Int
        let stockText: String
        let description: String
        let isFavorite: Bool
        let quantity: Int                  // NEW
        let onIncrease: () -> Void         // NEW
        let onDecrease: () -> Void         // NEW
        let onFavoriteTapped: () -> Void
        let onAddToCartTapped: (_ quantity: Int) -> Void
    }

    // MARK: - Subviews
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    
    private let productImage = UIImageView()
    private let nameLabel = UILabel()
    private let categoryLabel = UILabel()
    private let priceLabel = UILabel()
    
    private let ratingStack = UIStackView()
    private let ratingLabel = UILabel()
    private let starImageView = UIImageView(image: UIImage(systemName: "star.fill"))
    
    private let stockLabel = UILabel()

    // NEW: quantity selector
    private let quantityContainer = UIView()
    private let quantityStack = UIStackView()
    private let minusButton = UIButton(type: .system)
    private let quantityLabel = UILabel()
    private let plusButton = UIButton(type: .system)
    
    private let descriptionStack = UIStackView()
    private let descriptionTitleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    private let buttonStack = UIStackView()
    private let favoriteButton = HighlightButton(
        systemImageName: "heart",
        background: .white,
        tint: .systemPurple,
        cornerRadius: 10,
        height: 50
    )

    private let addToCartButton = HighlightButton(
        title: "Add to cart",
        background: .systemPurple,
        foreground: .white,
        cornerRadius: 10,
        height: 50,
        font: .boldSystemFont(ofSize: 17)
    )

    private var props: Props?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemGroupedBackground
        setupHierarchy()
        setupConstraints()
        style()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Setup
    private func setupHierarchy() {
        setupScrollView()
        setupRatingStack()
        setupQuantityStack()   // NEW
        setupDescriptionStack()
        setupButtons()

        [productImage,
         nameLabel,
         categoryLabel,
         priceLabel,
         ratingStack,
         stockLabel,
         quantityContainer,        // NEW (inserted above description)
         descriptionStack,
         buttonStack].forEach { stackView.addArrangedSubview($0) }
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
    }
    
    private func setupRatingStack() {
        ratingStack.axis = .horizontal
        ratingStack.spacing = 4
        ratingStack.alignment = .center
        ratingStack.addArrangedSubview(starImageView)
        ratingStack.addArrangedSubview(ratingLabel)
    }

    private func setupQuantityStack() {
        // Container (self-contained row)
        quantityContainer.translatesAutoresizingMaskIntoConstraints = false
        quantityContainer.backgroundColor = .secondarySystemBackground
        quantityContainer.layer.cornerRadius = 12

        // Inner horizontal stack
        quantityStack.axis = .horizontal
        quantityStack.alignment = .center
        quantityStack.distribution = .equalSpacing
        quantityStack.spacing = 16
        quantityStack.translatesAutoresizingMaskIntoConstraints = false
        quantityContainer.addSubview(quantityStack)

        // Buttons
        configureCircleButton(minusButton, systemName: "minus")
        configureCircleButton(plusButton,  systemName: "plus", tint: .systemGreen)
        minusButton.addTarget(self, action: #selector(didTapMinus), for: .touchUpInside)
        plusButton.addTarget(self,  action: #selector(didTapPlus),  for: .touchUpInside)

        // Quantity label (fixed width, won’t stretch)
        quantityLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        quantityLabel.textAlignment = .center
        quantityLabel.widthAnchor.constraint(equalToConstant: 36).isActive = true

        // Prevent stretching of any arranged view
        [minusButton, quantityLabel, plusButton].forEach {
            $0.setContentHuggingPriority(.required, for: .horizontal)
            $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        }

        [minusButton, quantityLabel, plusButton].forEach(quantityStack.addArrangedSubview)

        // Padding inside the pill + compact height
        NSLayoutConstraint.activate([
            quantityStack.topAnchor.constraint(equalTo: quantityContainer.topAnchor, constant: 8),
            quantityStack.leadingAnchor.constraint(equalTo: quantityContainer.leadingAnchor, constant: 12),
            quantityStack.trailingAnchor.constraint(equalTo: quantityContainer.trailingAnchor, constant: -12),
            quantityStack.bottomAnchor.constraint(equalTo: quantityContainer.bottomAnchor, constant: -8),
            quantityContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
    }


    private func configureCircleButton(_ button: UIButton,
                                       systemName: String,
                                       tint: UIColor = .systemGray,
                                       bg: UIColor = .clear) {
        button.setImage(UIImage(systemName: "\(systemName).circle.fill"), for: .normal)
        button.tintColor = tint
        button.backgroundColor = bg
        button.layer.cornerRadius = 18
        button.widthAnchor.constraint(equalToConstant: 36).isActive = true
        button.heightAnchor.constraint(equalToConstant: 36).isActive = true
    }

    
    private func setupDescriptionStack() {
        [descriptionTitleLabel, descriptionLabel].forEach { descriptionStack.addArrangedSubview($0) }
    }
    
    private func setupButtons() {
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        addToCartButton.addTarget(self, action: #selector(addToCartButtonTapped), for: .touchUpInside)
        
        buttonStack.axis = .horizontal
        buttonStack.spacing = 12
        buttonStack.distribution = .fillEqually
        [favoriteButton, addToCartButton].forEach { buttonStack.addArrangedSubview($0) }
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            productImage.heightAnchor.constraint(equalToConstant: 300)
        ])
    }

    private func style() {
        // Product Image
        productImage.contentMode = .scaleAspectFill
        productImage.clipsToBounds = true
        productImage.layer.cornerRadius = 12
        productImage.backgroundColor = .white
        
        // Labels
        nameLabel.font = .systemFont(ofSize: 26, weight: .semibold)
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 0

        categoryLabel.font = .preferredFont(forTextStyle: .subheadline)
        categoryLabel.textColor = .secondaryLabel
        categoryLabel.textAlignment = .center

        priceLabel.font = .systemFont(ofSize: 24, weight: .bold)
        priceLabel.textColor = .systemGreen
        priceLabel.textAlignment = .center

        // rating
        ratingLabel.font = .systemFont(ofSize: 16, weight: .medium)
        ratingLabel.textColor = .secondaryLabel

        starImageView.tintColor = .systemYellow
        starImageView.contentMode = .scaleAspectFit
        starImageView.widthAnchor.constraint(equalToConstant: 18).isActive = true
        starImageView.heightAnchor.constraint(equalToConstant: 18).isActive = true

        stockLabel.font = .systemFont(ofSize: 16)
        stockLabel.textColor = .secondaryLabel
        stockLabel.textAlignment = .natural

        descriptionTitleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        descriptionTitleLabel.text = "Description"
        descriptionTitleLabel.textColor = .label

        descriptionLabel.font = .preferredFont(forTextStyle: .body)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = .secondaryLabel
        
        descriptionStack.axis = .vertical
        descriptionStack.spacing = 4
    }
    
    private func setAddToCartEnabled(_ enabled: Bool) {
        addToCartButton.isEnabled = enabled
        addToCartButton.backgroundColor = addToCartButton.isEnabled ? .systemPurple : .systemGray5
        addToCartButton.setTitleColor(addToCartButton.isEnabled ? .white : .systemGray2, for: .normal)
        addToCartButton.alpha = addToCartButton.isEnabled ? 1.0 : 0.6
        // You could also disable quantity controls if out of stock:
        minusButton.isEnabled = enabled
        plusButton.isEnabled  = enabled
        minusButton.alpha = enabled ? 1.0 : 0.5
        plusButton.alpha  = enabled ? 1.0 : 0.5
    }
    
    @objc private func favoriteButtonTapped () { props?.onFavoriteTapped() }
    @objc private func addToCartButtonTapped() { props?.onAddToCartTapped(Int(quantityLabel.text ?? "0") ?? 0) }

    // NEW: quantity taps
    @objc private func didTapMinus() { props?.onDecrease() }
    @objc private func didTapPlus()  { props?.onIncrease() }
    
    private func updateFavoriteIcon(isFavorite: Bool) {
        let iconName = isFavorite ? "heart.fill" : "heart"
        favoriteButton.setImage(UIImage(systemName: iconName), for: .normal)
        favoriteButton.tintColor = isFavorite ? .systemPink : .systemPurple
    }
    
    private func updateStockUI(count: Int, quantity: Int) {
        // color & add-to-cart enablement
        switch count {
        case 10...:
            stockLabel.textColor = .systemGreen
            setAddToCartEnabled(true)
        case 1..<5:
            stockLabel.textColor = .systemRed
            setAddToCartEnabled(true)
        case 0:
            stockLabel.textColor = .tertiaryLabel
            setAddToCartEnabled(false)
        default:
            stockLabel.textColor = .secondaryLabel
            setAddToCartEnabled(true)
        }
        // quantity caps
        minusButton.isEnabled = quantity > 1
        plusButton.isEnabled  = quantity < count
        minusButton.alpha = minusButton.isEnabled ? 1.0 : 0.4
        plusButton.alpha  = plusButton.isEnabled  ? 1.0 : 0.4
    }

    // Convenience binder
    func render(_ p: Props) {
        props = p
        nameLabel.text = p.title
        categoryLabel.text = p.category
        priceLabel.text = p.price
        productImage.load(p.imageURL)
        ratingLabel.text = p.rating
        stockLabel.text = p.stockText
        descriptionLabel.text = p.description

        // quantity
        quantityLabel.text = "\(p.quantity)"

        // update dependent UIs
        updateStockUI(count: p.stockCount, quantity: p.quantity)
        updateFavoriteIcon(isFavorite: p.isFavorite)
    }
}
