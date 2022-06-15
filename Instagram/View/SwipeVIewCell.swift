//
//  SwipeVIewCell.swift
//  Instagram
//
//  Created by Inna Kokorina on 15.06.2022.
//

import UIKit
import SwipeCellKit

class SwipeViewController: UITableViewController, SwipeTableViewCellDelegate {
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        tableView.rowHeight = 80
//
//    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTableViewCell") as! SwipeTableViewCell
        cell.delegate = self
        return cell
    }
  
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
//        guard orientation == .right else { return nil }
//        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
//            self.updatedModel(at: indexPath)
//
//        }
//
//        deleteAction.image = UIImage(systemName: "trash.fill")
//
//        return [deleteAction]
//    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            self.deleteItem(at: indexPath)
        }
        deleteAction.image = UIImage(systemName: "trash.fill")

        return [deleteAction]
    }
//    func collectionView(_ collectionView: UICollectionView, editActionsOptionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
//        var options = SwipeOptions()
//        options.expansionStyle = .destructive
//        options.transitionStyle = .border
//        return options
//    }
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        return options
    }
    
    func deleteItem(at indexPath: IndexPath) {
        
    }
}
