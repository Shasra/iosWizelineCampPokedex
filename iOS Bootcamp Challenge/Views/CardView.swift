//
//  CardView.swift
//  iOS Bootcamp Challenge
//
//  Created by Marlon David Ruiz Arroyave on 28/09/21.
//

import UIKit

class CardView: UIView {

    private let margin: CGFloat = 30
    var card: Card?

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 27)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    required init(card: Card) {
        self.card = card
        super.init(frame: .zero)
        setup()
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
        setupUI()
    }

    private func setup() {
        guard let card = card else { return }

        titleLabel.text = card.title
        backgroundColor = .white
        layer.cornerRadius = 20
    }

    private func setupUI() {

        addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: margin * 2).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: margin).isActive = true
        titleLabel.widthAnchor.constraint(lessThanOrEqualTo: self.widthAnchor, multiplier: 0.70).isActive = true

        // TODO: Display pokemon info (eg. types, abilities)
        guard let card = card else { return }

        var magicNumber: CGFloat = 3.5

        card.items.forEach { item in
            let fullDescription = "\(item.title) : \(item.description)"
            let label = UILabel()
            label.font = UIFont.boldSystemFont(ofSize: 15)
            label.textAlignment = .left
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = fullDescription

            addSubview(label)
            label.topAnchor.constraint(equalTo: self.topAnchor, constant: margin * magicNumber).isActive = true
            label.leftAnchor.constraint(equalTo: self.leftAnchor, constant: margin).isActive = true
            label.widthAnchor.constraint(lessThanOrEqualTo: self.widthAnchor, multiplier: 1.70).isActive = true
            magicNumber =  magicNumber + 1.0
        }

    }

}
