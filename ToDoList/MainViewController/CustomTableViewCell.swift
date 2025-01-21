//
//  CustomTableViewCell.swift
//  ToDoList
//
//  Created by Илья Волощик on 21.01.25.
//

import UIKit

final class CustomTableViewCell: UITableViewCell {
    
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let configuration = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular, scale: .medium)
        let image = UIImage(systemName: "circle", withConfiguration: configuration)
        button.setImage(image, for: .normal)
        button.tintColor = .yellow
        button.addTarget(self, action: #selector(reverseDoneButtoneState), for: .touchUpInside)
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Сходить в магазин"
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        return titleLabel
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = "Купить молоко и яйца"
        descriptionLabel.textColor = .white
        descriptionLabel.font = .systemFont(ofSize: 12, weight: .regular)
        descriptionLabel.numberOfLines = 2
        return descriptionLabel
    }()
    
    private lazy var burnDateLabel: UILabel = {
        let burnDateLabel = UILabel()
        burnDateLabel.translatesAutoresizingMaskIntoConstraints = false
        burnDateLabel.text = "12:10:2024"
        burnDateLabel.textColor = .white
        burnDateLabel.font = .systemFont(ofSize: 12, weight: .regular)
        return burnDateLabel
    }()
    
    private var taskIsDone = false
    
    static let identifer = "CustomTableViewCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        configureSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureSubviews() {
        [titleLabel,
         descriptionLabel,
         burnDateLabel,
         doneButton].forEach {contentView.addSubview($0)}
        
        let heightCell = contentView.heightAnchor.constraint(equalToConstant: 100)
        heightCell.priority = .defaultHigh
        
        NSLayoutConstraint.activate([
            heightCell,
            
            doneButton.heightAnchor.constraint(equalToConstant: 40),
            doneButton.widthAnchor.constraint(equalToConstant: 40),
            doneButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            doneButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: doneButton.trailingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 22),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: doneButton.trailingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 38),
            
            burnDateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor),
            burnDateLabel.leadingAnchor.constraint(equalTo: doneButton.trailingAnchor),
            burnDateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            burnDateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    @objc
    private func reverseDoneButtoneState() {
        let configuration = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular, scale: .medium)
        var image = UIImage(systemName: "circle", withConfiguration: configuration)
        if taskIsDone {
            image = UIImage(systemName: "circle", withConfiguration: configuration)
        } else {
            image = UIImage(systemName: "checkmark.circle", withConfiguration: configuration)
        }
        taskIsDone.toggle()
        doneButton.setImage(image, for: .normal)
    }
}
