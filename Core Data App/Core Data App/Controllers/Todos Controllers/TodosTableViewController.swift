//
//  TodosTableViewController.swift
//  Core Data App
//
//  Created by Apple Macbook Pro 13 on 10.09.22.
//

import UIKit
import CoreData

final class TodosTableViewController: UITableViewController {

    // MARK: IBOutlets
    
    @IBOutlet private weak var searchBar: UISearchBar! {
        didSet {
            searchBar.searchTextField.textColor = .white
        }
    }
    
    // MARK: - Properties
        
    var category: CategoryModel? {
        didSet {
            self.title = category?.name
            guard
                let category = category,
                let todos = CoreDataManager.loadTodos(selectedCategory: category)else { return }
            self.todos = todos
        }
    }
    
    var todos = [TodoModel]()
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.register(
            UINib(nibName: TodoTableViewCell.identifier, bundle: nil),
            forCellReuseIdentifier: TodoTableViewCell.identifier)
        self.navigationItem.rightBarButtonItems?.append(self.editButtonItem)
    }
    
    // MARK: - IBActions
    
    @IBAction private func newTodoAction(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add todo", message: "write todo's name", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "todo"
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let action = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            if
                let textField = alert.textFields?.first,
                let text = textField.text,
                !text.isEmpty,
                let self = self
            {
                let todo = TodoModel(context: CoreDataManager.context)
                todo.name = text
                todo.id_category = self.category
                todo.id = Int16(self.todos.count+1)
                
                self.todos.append(todo)
                CoreDataManager.saveContext()
                self.tableView.insertRows(at: [IndexPath(row: self.todos.count-1, section: 0)], with: .automatic)
                self.IDController()
            }
        }
        
        alert.addAction(cancel)
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
    // MARK: - Private functions
    
    private func IDController() {
        guard todos.count >= 1 else { return }
        for index in 0...todos.count-1 {
            todos[index].id = Int16(index+1)
        }
        CoreDataManager.saveContext()
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: TodoTableViewCell.identifier,
                for: indexPath) as? TodoTableViewCell else { return UITableViewCell() }
        let todo = todos[indexPath.row]
        cell.refresh(model: todo)
        cell.accessoryType = todo.done ? .checkmark : .none
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let idTodo = todos[indexPath.row].id
            if
                let category = category,
                let todos = CoreDataManager.loadTodos(
                    selectedCategory: category,
                    predicate: NSPredicate(format: "id==\(idTodo)"))
            {
                for todo in todos {
                    CoreDataManager.context.delete(todo)
                }
                self.todos.remove(at: indexPath.row)
                CoreDataManager.saveContext()
                tableView.deleteRows(at: [indexPath], with: .automatic)
                IDController()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let removedTodo = todos.remove(at: fromIndexPath.row)
        todos.insert(removedTodo, at: to.row)
        IDController()
        
        tableView.reloadData()
    }
    
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // MARK: - Table view delegates
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        todos[indexPath.row].done.toggle()
        CoreDataManager.saveContext()
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

// MARK: - Extension

extension TodosTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let predicate = searchText.isEmpty ? nil : NSPredicate(
            format: "name CONTAINS %@", searchText.lowercased())
        guard
            let category = category,
            let todos = CoreDataManager.loadTodos(selectedCategory: category, predicate: predicate)
        else {
            return
        }
        self.todos = todos
        tableView.reloadData()
    }
}
