//
//  CoreDataManager.swift
//  Core Data App
//
//  Created by Apple Macbook Pro 13 on 10.09.22.
//

import UIKit
import CoreData

final class CoreDataManager {
    static let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    static func saveContext() {
        do {
            try context.save()
        } catch {
            print("Saving erro:\(error)")
        }
    }
    
    static func loadCategories(
        with request: NSFetchRequest<CategoryModel> = CategoryModel.fetchRequest(),
        predicate: NSPredicate? = nil) -> [CategoryModel]?
    {
        if let predicate = predicate {
            request.predicate = predicate
        }
        do {
            return try context.fetch(request)
        } catch {
            print("Load error \(error)")
            return nil
        }
    }
    
    static func loadTodos(
        selectedCategory: CategoryModel,
        with request: NSFetchRequest<TodoModel> = TodoModel.fetchRequest(),
        predicate: NSPredicate? = nil) -> [TodoModel]?
    {
        let categoryId = selectedCategory.id
        let categoryPredicate = NSPredicate(format: "id_category.id==\(categoryId)")
        if let predicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, predicate])
        } else {
            request.predicate = categoryPredicate
        }
        do {
            return try context.fetch(request)
        } catch {
            print("Load error \(error)")
            return nil
        }
    }
}
