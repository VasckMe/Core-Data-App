//
//  CategoriesTableViewController.swift
//  Core Data App
//
//  Created by Apple Macbook Pro 13 on 10.09.22.
//

import UIKit
import CoreData

final class CategoriesTableViewController: UITableViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet private weak var searchBar: UISearchBar! {
        didSet {
            searchBar.searchTextField.textColor = .white
        }
    }
    
    // MARK: - Properties
    
    var categories = [CategoryModel]()
        
    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        tableView.register(
            UINib(nibName: CategoryTableViewCell.identifier, bundle: nil),
            forCellReuseIdentifier: CategoryTableViewCell.identifier)
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        searchBar.delegate = self
    }
    
    // MARK: - IBActions
    
    @IBAction private func newCategoryAction(_ sender: UIBarButtonItem) {
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
                let category = CategoryModel(context: CoreDataManager.context)
                category.name = text
                category.id = Int16(self.categories.count + 1)
                self.categories.append(category)
                CoreDataManager.saveContext()
                self.tableView.insertRows(at: [IndexPath(row: self.categories.count-1, section: 0)], with: .automatic)
                self.ControllerID()
            }
        }
        alert.addAction(cancel)
        alert.addAction(action)
        
        self.present(alert, animated: true)
    }
    
    // MARK: - Private functions
    
    private func loadCategories() {
        if let categories = CoreDataManager.loadCategories() {
            self.categories = categories
        }
    }
    
    private func ControllerID() {
        guard categories.count >= 1 else { return }
        for index in 0...categories.count-1 {
            categories[index].id = Int16(index+1)
        }
        CoreDataManager.saveContext()
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
            if let categories = CoreDataManager.loadCategories(predicate: NSPredicate(format: "id==\(id)")) {
                for category in categories {
                    CoreDataManager.context.delete(category)
                }
                self.categories.remove(at: indexPath.row)
                CoreDataManager.saveContext()
                tableView.deleteRows(at: [indexPath], with: .fade)
                ControllerID()
            }
        }
    }

    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let category = self.categories.remove(at: fromIndexPath.row)
        self.categories.insert(category, at: to.row)
        ControllerID()
//        CoreDataManager.saveContext()
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // MARK: - Table view delegates
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "GoToTodosTVC", sender: nil)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let todosTVC = segue.destination as? TodosTableViewController,
           let indexPath = tableView.indexPathForSelectedRow {
            todosTVC.category = categories[indexPath.row]
        }
    }
}

// MARK: - Extension

extension CategoriesTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let predicate = searchText.isEmpty ? nil : NSPredicate(
            format: "name CONTAINS %@",searchText)
        guard let categories = CoreDataManager.loadCategories(predicate: predicate) else { return }
        self.categories = categories
        tableView.reloadData()
    }
}
