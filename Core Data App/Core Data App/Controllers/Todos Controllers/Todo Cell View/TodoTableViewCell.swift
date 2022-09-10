//
//  TodoTableViewCell.swift
//  Core Data App
//
//  Created by Apple Macbook Pro 13 on 10.09.22.
//

import UIKit

class TodoTableViewCell: UITableViewCell {

    @IBOutlet private weak var idLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    
    static let identifier = "TodoTableViewCell"

    func refresh(model: TodoModel) {
        idLabel.text = String(model.id)
        titleLabel.text = model.name
    }
}
