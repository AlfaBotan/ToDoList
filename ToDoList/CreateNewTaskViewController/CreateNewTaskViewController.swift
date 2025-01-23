//
//  CreateNewTaskViewController.swift
//  ToDoList
//
//  Created by Илья Волощик on 23.01.25.
//

import UIKit

final class CreateNewTaskViewController: UIViewController {
    
    private lazy var titleTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textColor = .white
        textField.font = .systemFont(ofSize: 34, weight: .bold)
        textField.backgroundColor = .clear
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemGray4.cgColor
        textField.textAlignment = .center
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        textField.leftViewMode = .always
        textField.placeholder = "Введите заголовок"
        return textField
    }()
    
    private lazy var descriptionTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textColor = .white
        textField.font = .systemFont(ofSize: 16, weight: .regular)
        textField.borderStyle = .line
        return textField
    }()
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = self
        textView.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        textView.textColor = .white
        textView.backgroundColor = .clear
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        return textView
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .white
        label.text = DateFormatterManager.shared.dateFormatter.string(from: Date.now)
        return label
    }()
    
    private lazy var rightBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Сохранить", style: .plain, target: self, action: #selector(saveNewTaskButtonPress))
        button.tintColor = .yellow
        button.isEnabled = false
        return button
    }()
    
    private let coreDataManager = CoreDataManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUIElements()
        setUpConstraints()
    }
    
    private func setUpUIElements() {
        view.backgroundColor = .black
        navigationItem.rightBarButtonItem = rightBarButton
        
        [titleTextField,
         dateLabel,
         textView].forEach {view.addSubview($0) }
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            titleTextField.heightAnchor.constraint(equalToConstant: 40),
            
            dateLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            dateLabel.heightAnchor.constraint(equalToConstant: 16),
            
            textView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc
    func saveNewTaskButtonPress() {
        let title = titleTextField.text ?? "Без категории"
        guard let description = textView.text else {return}
        coreDataManager.saveTask(id: UUID(), title: title, details: description, date: Date.now, isDone: false)
        navigationController?.popViewController(animated: true)
    }
}

extension CreateNewTaskViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let size = textView.sizeThatFits(CGSize(width: textView.frame.width, height: .infinity))
        textView.constraints.forEach { constraint in
            if constraint.firstAttribute == .height {
                constraint.constant = size.height
            }
        }
        
        rightBarButton.isEnabled = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
