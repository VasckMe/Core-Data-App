//
//  TodosTableViewController.swift
//  Core Data App
//
//  Created by Apple Macbook Pro 13 on 10.09.22.
//

import UIKit
import CoreData

class TodosTableViewController: UITableViewController {

    // MARK: - Properties
    
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var category: CategoryModel? {
        didSet {
            self.title = category?.name
            loadContext()
        }
    }
    
    var todos = [TodoModel]()
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(
            UINib(nibName: TodoTableViewCell.identifier, bundle: nil),
            forCellReuseIdentifier: TodoTableViewCell.identifier)
    }
    
    // MARK: - IBActions
    
    @IBAction func newTodoAction(_ sender: UIBarButtonItem) {
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
                let todo = TodoModel(context: self.context)
                todo.name = text
                todo.id_category = self.category
                todo.id = Int16(self.todos.count+1)
                
                self.todos.append(todo)
                self.saveContext()
                self.tableView.insertRows(at: [IndexPath(row: self.todos.count-1, section: 0)], with: .automatic)
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
        saveContext()
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
            let request: NSFetchRequest<TodoModel> = TodoModel.fetchRequest()
            request.predicate = NSPredicate(format: "id==\(idTodo)")
            
            if let todos = try? context.fetch(request) {
                for todo in todos {
                    context.delete(todo)
                }
                self.todos.remove(at: indexPath.row)
                saveContext()
                tableView.deleteRows(at: [indexPath], with: .fade)
                IDController()
            }
        }
    }
    
    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Table view delegates
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        todos[indexPath.row].done.toggle()
        saveContext()
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    // MARK: - Core Data
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Saving error \(error)")
        }
    }
    
    private func loadContext(with request: NSFetchRequest<TodoModel> = TodoModel.fetchRequest(),
                             predicate: NSPredicate? = nil) {
        guard let categoryID = category?.id else { return }
        let todoPredicate = NSPredicate(format: "id_category.id==\(categoryID)")
        
        if let predicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [todoPredicate, predicate])
        } else {
            request.predicate = todoPredicate
        }
        
        do {
            todos = try context.fetch(request)
        } catch {
            print("Load error \(error)")
        }
        tableView.reloadData()
    }
}
