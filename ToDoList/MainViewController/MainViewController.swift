//
//  MainViewController.swift
//  ToDoList
//
//  Created by Илья Волощик on 20.01.25.
//

import UIKit

final class MainViewController: UIViewController {
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Задачи"
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 34, weight: .bold)
        return titleLabel
    }()
    
    private lazy var searchField: UISearchTextField = {
        let searchField = UISearchTextField()
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.clearButtonMode = .whileEditing
        searchField.textColor = .textForPlaceholder
        searchField.layer.masksToBounds = true
        searchField.layer.cornerRadius = 10
        let textForPlaceholder = "search"
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.textForPlaceholder,
            .font: UIFont.systemFont(ofSize: 17, weight: .regular)
        ]
        searchField.attributedPlaceholder = NSAttributedString(string: textForPlaceholder, attributes: attributes)
        searchField.tintColor = .textForPlaceholder
        let searchIcon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        searchIcon.tintColor = .textForPlaceholder
        searchIcon.frame = CGRect(x: 8, y: 0, width: 16, height: 16)
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 16))
        paddingView.addSubview(searchIcon)
        searchField.leftView = paddingView
        searchField.leftViewMode = .unlessEditing
        searchField.leftViewMode = .always
        searchField.backgroundColor = .myBackground
        return searchField
    }()
    
    private lazy var taskTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CustomTableViewCell.identifer)
        tableView.separatorColor = .gray
        
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    private lazy var footerView: UIView = {
        let footerView = UIView()
        footerView.translatesAutoresizingMaskIntoConstraints = false
        footerView.backgroundColor = .myBackground
        
        return footerView
    }()
    
    private lazy var newTaskButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let configuration = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular, scale: .medium)
        let image = UIImage(systemName: "square.and.pencil", withConfiguration: configuration)
        button.setImage(image, for: .normal)
        button.tintColor = .yellow
        button.addTarget(self, action: #selector(newTaskButtonPress), for: .touchUpInside)
        return button
    }()
    
    private lazy var countTaskLabel: UILabel = {
        let countTaskLabel = UILabel()
        countTaskLabel.translatesAutoresizingMaskIntoConstraints = false
        countTaskLabel.text = String.localizedStringWithFormat(
            NSLocalizedString("numberOfTasks", comment: "подбор формы записи"),
            countTask.count
        )
        countTaskLabel.textColor = .white
        countTaskLabel.font = .systemFont(ofSize: 13, weight: .regular)
        return countTaskLabel
    }()
    
    private var blurView: UIVisualEffectView?
    private var countTask: [Task] = []
    
    private let toDoLoadService = ToDoLoadService.shared
    private let coreDataMadager = CoreDataManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coreDataMadager.delegate = self
        coreDataMadager.configureFetchedResultsController()
        
        setUpUIElements()
        setUpConstraints()
        
//        coreDataMadager.deleteAllTasks()
        loadData()
    }
    
    private func setUpUIElements() {
        view.backgroundColor = .black
        [titleLabel,
         searchField,
         taskTableView,
         footerView].forEach {view.addSubview($0) }
        
        [countTaskLabel,
         newTaskButton].forEach {footerView.addSubview($0)}
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            titleLabel.heightAnchor.constraint(equalToConstant: 41),
            
            searchField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            searchField.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            searchField.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            searchField.heightAnchor.constraint(equalToConstant: 36),
            
            taskTableView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 10),
            taskTableView.leadingAnchor.constraint(equalTo: searchField.leadingAnchor),
            taskTableView.trailingAnchor.constraint(equalTo: searchField.trailingAnchor),
            taskTableView.bottomAnchor.constraint(equalTo: footerView.topAnchor),
            
            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            footerView.heightAnchor.constraint(equalToConstant: 75),
            
            countTaskLabel.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
            countTaskLabel.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 20),
            
            newTaskButton.heightAnchor.constraint(equalToConstant: 44),
            newTaskButton.widthAnchor.constraint(equalToConstant: 68),
            newTaskButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor),
            newTaskButton.topAnchor.constraint(equalTo: footerView.topAnchor)
        ])
    }
    
    private func loadData() {
        let isDataLoaded = UserDefaults.standard.bool(forKey: "isDataLoaded")
        if !isDataLoaded {
            ToDoLoadService.shared.fetchTodos { [weak self] result in
                guard let self = self else {return}
                DispatchQueue.main.async {
                    switch result {
                    case .success(let toDo):
                        UserDefaults.standard.set(true, forKey: "isDataLoaded")
                        toDo.forEach {self.coreDataMadager.saveTask(id: UUID(), title: "Без категории", details: $0.todo, date: Date.now, isDone: false)}
                    case .failure(let error):
                        print("Не удалось загрузить данный из API ошибка: \(error)")
                    }
                }
            }
        }
    }
    
    @objc
    private func newTaskButtonPress() {
        let viewController = CreateNewTaskViewController()
        let backButton = UIBarButtonItem()
        backButton.tintColor = .yellow
        backButton.title = "Назад"
        navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        navigationController?.pushViewController(viewController, animated: true)
    }
    
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        countTask.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CustomTableViewCell.identifer, for: indexPath) as? CustomTableViewCell else {
            assertionFailure("Не удалось выполнить приведение к EventAndHabitTableViewСеll")
            return UITableViewCell()
        }
        cell.configCell(data: countTask[indexPath.row])
        return cell
    }
}

extension MainViewController: UITableViewDelegate {
    
}

extension MainViewController: CoreDataManagerDelegate {
    func didChangeData(_ data: [Task]) {
        countTask = data
        taskTableView.reloadData()
        countTaskLabel.text = String.localizedStringWithFormat(
            NSLocalizedString("numberOfTasks", comment: "подбор формы записи"),
            countTask.count
        )
    }
}

