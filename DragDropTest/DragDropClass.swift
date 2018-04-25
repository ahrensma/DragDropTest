//
//  ViewController.swift
//  DragDropTable
//
//  Created by Martin Ahrens on 01/04/18.
//  Copyright © 2017 Developer Fly. All rights reserved.
//

import UIKit

class DragDropClass: UIViewController {

    @IBOutlet weak var bottomTableView: UITableView!
    @IBOutlet weak var topTableView: UITableView!
    
    var str : String = ""
    var TopArray_Data       = ["1","2"]
    var ButtonArray_Data    = ["a","b"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.topTableView.dragInteractionEnabled = true
        self.topTableView.dragDelegate = self
        
        self.bottomTableView.dropDelegate = self
        self.bottomTableView.isEditing = true

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// EXTENSION - load table data (rows and cells)

extension DragDropClass: UITableViewDataSource {
    
    func tableView(_ TableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if TableView == topTableView {
            return TopArray_Data.count
        } else {
            return ButtonArray_Data.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == topTableView {
            let cell = topTableView.dequeueReusableCell(withIdentifier: "TopTableViewCell", for: indexPath) as! TopTable
            cell.old_array.text = TopArray_Data[indexPath.row]
            return cell
        } else {
            let cell = bottomTableView.dequeueReusableCell(withIdentifier: "BottomTableViewCell", for: indexPath) as! BottomTable
            cell.new_array.text = ButtonArray_Data[indexPath.row]
            return cell
        }
    }

}

// EXTENSION - table delegate (currently nothing to do)

extension DragDropClass: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}

}

// EXTENSION - table drag delegate

extension DragDropClass: UITableViewDragDelegate {
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = self.dragItem(forDragItem: indexPath)
        return [dragItem]
    }
    
    func tableView(_ tableView: UITableView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        let dragItem = self.dragItem(forDragItem: indexPath)
        return [dragItem]
    }
    
    func tableView(_ tableView: UITableView, dragPreviewParametersForRowAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        return previewParameters(forItemAt:indexPath)
    }
    
    private func dragItem(forDragItem indexPath: IndexPath) -> UIDragItem {
        
        let array = TopArray_Data[indexPath.row]
        let itemProvider = NSItemProvider(object: array as NSItemProviderWriting)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = array
        
        str = dragItem.localObject as! String
        
        return dragItem
    }
    
    private func previewParameters(forItemAt indexPath:IndexPath) -> UIDragPreviewParameters? {
        let cell = self.topTableView.cellForRow(at: indexPath) as! TopTable
        let previewParameters = UIDragPreviewParameters()
        previewParameters.visiblePath = UIBezierPath(rect: cell.old_array.frame)
        return previewParameters
    }
    
}

// EXTENSION - table drop delegate

extension DragDropClass: UITableViewDropDelegate {
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        let destinationIndexPath: IndexPath

        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            let section = tableView.numberOfSections - 1
            let row = tableView.numberOfRows(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }

        coordinator.session.loadObjects(ofClass: NSString.self) { items in
            guard let string = items as? [String] else { return }

            var indexPaths = [IndexPath]()

            for (index, _) in string.enumerated() {
                let indexPath = IndexPath(row: destinationIndexPath.row + index, section: destinationIndexPath.section)
                self.ButtonArray_Data.insert(self.str, at: indexPath.row)
                indexPaths.append(indexPath)
            }
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidEnter session: UIDropSession) {}
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        return UITableViewDropProposal(operation: .copy, intent: .automatic)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = self.ButtonArray_Data[sourceIndexPath.row]
        ButtonArray_Data.remove(at: sourceIndexPath.row)
        ButtonArray_Data.insert(movedObject, at: destinationIndexPath.row)
        NSLog("%@", "\(sourceIndexPath.row) => \(destinationIndexPath.row) \(ButtonArray_Data)")
        // To check for correctness enable: self.tableView.reloadData()
    }
    
    func doSomeThingAfterDrop() {}

}
