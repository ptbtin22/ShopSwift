//
//  GFButton.swift
//  GitHub Followers
//
//  Created by Tín Phạm on 15/10/25.
//

import UIKit

class MyCustomButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // custom code go here
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    init(backgroundColor: UIColor, title: String) {
        super.init(frame: .zero)
        self.backgroundColor = backgroundColor
        self.setTitle(title, for: .normal)
        configure()
    }
    
    private func configure() {
        layer.cornerRadius = 10
        titleLabel?.textColor = .white
        titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        translatesAutoresizingMaskIntoConstraints = false
    }
}
