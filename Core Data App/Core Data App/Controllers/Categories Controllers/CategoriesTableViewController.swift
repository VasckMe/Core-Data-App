//
//  CategoriesTableViewController.swift
//  Core Data App
//
//  Created by Apple Macbook Pro 13 on 10.09.22.
//

import UIKit
import CoreData

class CategoriesTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    var categories = [CategoryModel]()
    
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadContext()
        tableView.register(
            UINib(nibName: CategoryTableViewCell.identifier, bundle: nil),
            forCellReuseIdentifier: CategoryTableViewCell.identifier)
    }
    
    // MARK: - IBActions
    
    @IBAction func newCategoryAction(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add category",
                                      message: "Write the name of category",
                                      preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "category"
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let action = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            if
                let textField = alert.textFields?.first,
                let text = textField.text,
                !text.isEmpty,
                let self = self
            {
                let category = CategoryModel(context: self.context)
                category.name = text
                category.id = Int16(self.categories.count + 1)
                self.categories.append(category)
                self.saveContext()
                self.tableView.insertRows(at: [IndexPath(row: self.categories.count-1, section: 0)], with: .automatic)
                self.ControllerID()
            }
        }
        alert.addAction(cancel)
        alert.addAction(action)
        
        self.present(alert, animated: true)
    }
    
    // MARK: - Private functions
    
    private func ControllerID() {
        guard categories.count >= 1 else { return }
        for index in 0...categories.count-1 {
            categories[index].id = Int16(index+1)
        }
        saveContext()
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: CategoryTableViewCell.identifier,
                for: indexPath) as? CategoryTableViewCell else { return UITableViewCell() }

        let category = categories[indexPath.row]
        
        cell.refresh(model: category)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let id = categories[indexPath.row].id
            let request: NSFetchRequest<CategoryModel> = CategoryModel.fetchRequest()
            request.predicate = NSPredicate(format: "id==\(id)")
            
            if let categories = try? context.fetch(request) {
                for category in categories {
                    context.delete(category)
                }
                
                self.categories.remove(at: indexPath.row)
                saveContext()
                tableView.deleteRows(at: [indexPath], with: .fade)
                ControllerID()
            }
        }
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    
    // Override to support conditional rearranging of the table view.
//    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
//        // Return false if you do not want the item to be re-orderable.
//        return true
//    }
    

    // MARK: - Table view delegates
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "GoToTodosTVC", sender: nil)
    }
    
    // MARK: - Core Data
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Saving error \(error)")
        }
    }
    
    private func loadContext(with request: NSFetchRequest<CategoryModel> = CategoryModel.fetchRequest()) {
        do {
            categories = try context.fetch(request)
        } catch {
            print("Load error \(error)")
        }
        tableView.reloadData()
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let todosTVC = segue.destination as? TodosTableViewController,
           let indexPath = tableView.indexPathForSelectedRow {
            todosTVC.category = categories[indexPath.row]
        }
    }
}
