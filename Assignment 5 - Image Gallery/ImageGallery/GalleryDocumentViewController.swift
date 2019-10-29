//
//  GalleryDocumentViewController.swift
//  ImageGallery
//
//  Created by Jon Mak on 2019-02-02.
//  Copyright © 2019 Jon Mak. All rights reserved.
//

import UIKit

class GalleryDocumentViewController: UITableViewController {
    
    var sections = ["Documents", "Recently Deleted"]
    var documents: [(docId: Int, name: String, imageInfo: [ImageModel])] =
        [(docId: getDocId, name: "My Gallery", imageInfo: [ImageModel(url: URL(string: "https://www.imore.com/sites/imore.com/files/field/image/2017/11/iphone-x-home-screen-angle.jpg")!, aspectRatio: 1.33)])]
    var recentlyDeleted: [(docId: Int, name: String, imageInfo: [ImageModel])] = [(Int, String, [ImageModel])]()
    
    private var activeDocId: Int? = 1
    private static var docId = 1
    private static var getDocId: Int {
        docId = docId + 1
        return docId
    }
    
    private var editableCell = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = #colorLiteral(red: 0.1790721416, green: 0.1813634336, blue: 0.1812815964, alpha: 0.7048640839)
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.1776998043, green: 0.1782446504, blue: 0.1848969758, alpha: 0.7023223459)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(chooseGallery(_:)))
        tap.numberOfTapsRequired = 1
        tableView.addGestureRecognizer(tap)
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(tapEdit(_:)))
        doubleTap.numberOfTapsRequired = 2
        tableView.addGestureRecognizer(doubleTap)
        tap.require(toFail: doubleTap)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if splitViewController?.preferredDisplayMode != .primaryOverlay {
            splitViewController?.preferredDisplayMode = .primaryOverlay
        }
    }
    
    @IBAction func addGalleryDocument(_ sender: Any) {
        let documentNames = documents.map { $0.name }
        let uniqueName = "New Gallery".madeUnique(withRespectTo: documentNames)
        documents += [(docId: GalleryDocumentViewController.getDocId, name: uniqueName, imageInfo: [ImageModel]())]
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return documents.count
        case 1: return recentlyDeleted.count
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if editableCell == true {
            let cell = tableView.dequeueReusableCell(withIdentifier: "InputCell", for: indexPath)
            if let inputCell = cell as? TextFieldTableViewCell {
                inputCell.textField?.text = documents[indexPath.row].name
                inputCell.resignationHandler = { [weak self, unowned inputCell] in
                    if let newText = inputCell.textField.text {
                        self?.documents[indexPath.row].name = newText
                    }
                    self?.editableCell = false
                    self?.tableView.reloadData()
                }
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentCell", for: indexPath)
            cell.textLabel?.textColor = #colorLiteral(red: 0.7975574136, green: 0.7928175926, blue: 0.8012018204, alpha: 1)
            if indexPath.section == 0 {
                cell.textLabel?.text = documents[indexPath.row].name
            }
            if indexPath.section == 1 {
                cell.textLabel?.text = recentlyDeleted[indexPath.row].name
            }
            return cell
        }
    }
    
    @objc func tapEdit(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            let tapLocation = gesture.location(in: self.tableView)
            if let tapIndexPath = self.tableView.indexPathForRow(at: tapLocation), tapIndexPath.section == 0 {
                editableCell = true
                tableView.reloadRows(at: [tapIndexPath], with: .automatic)
            }
        }
    }
    
    @objc func chooseGallery(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            if let nvc = splitViewController?.viewControllers.last as? UINavigationController,
                let igvc = nvc.viewControllers[0] as? ImageGalleryViewController {
                let tapLocation = gesture.location(in: self.tableView)
                if let tapIndexPath = self.tableView.indexPathForRow(at: tapLocation), tapIndexPath.section == 0 {
                    let document = documents[tapIndexPath.row]
                    configure(igvc, with: document)
                }
            }
        }
    }
    
    func nextAvailableGallery() {
        if documents.indices.contains(0) {
            if let igvc = splitViewController?.viewControllers.last as? ImageGalleryViewController {
                let document = documents[0]
                configure(igvc, with: document)
            }
        } else {
            activeDocId = nil
        }
    }
    
    private func configure(_ igvc: ImageGalleryViewController, with document: (docId: Int, name: String, imageInfo: [ImageModel])) {
        self.activeDocId = document.docId
        igvc.imageCollection = document.imageInfo
        igvc.modelUpdateHandler = { (imageInfo) in
            let indexToUpdate = self.documents.firstIndex(where: { (docId, _, _) -> Bool in
                return docId == self.activeDocId
            })
            if indexToUpdate != nil {
                self.documents[indexToUpdate!].imageInfo = imageInfo
            }
        }
        igvc.title = document.name
        igvc.reloadImages()
    }
    
    // Mark: - UICollectionViewDelegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.textLabel?.textColor = #colorLiteral(red: 0.7975574136, green: 0.7928175926, blue: 0.8012018204, alpha: 1)
        cell.backgroundColor = #colorLiteral(red: 0.1866446435, green: 0.1866828799, blue: 0.1866396666, alpha: 0.7541202911)
        cell.selectionStyle = .blue
        
        if let inputCell = cell as? TextFieldTableViewCell {
            inputCell.textField.becomeFirstResponder()
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let removeDocId = documents[indexPath.row].docId
        if editingStyle == .delete {
            if indexPath.section == 0 {
                tableView.performBatchUpdates({
                    recentlyDeleted.insert(documents[indexPath.row], at: 0)
                    documents.remove(at: indexPath.row)
                    tableView.moveRow(at: indexPath, to: IndexPath(row: 0, section: 1))
                })
                if activeDocId == removeDocId {
                    nextAvailableGallery()
                }
            }
            if indexPath.section == 1 {
                tableView.performBatchUpdates({
                    recentlyDeleted.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                })
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 1 {
            let recoverAction = UIContextualAction(style: .normal, title: "Recover") { (UIContextualAction, UIView, completionHandler: (Bool) -> Void) in
                tableView.performBatchUpdates({
                    self.documents.insert(self.recentlyDeleted[indexPath.row], at: 0)
                    self.recentlyDeleted.remove(at: indexPath.row)
                    tableView.moveRow(at: indexPath, to: IndexPath(row: self.documents.endIndex - 1, section: 0))
                })
                completionHandler(true)
            }
            recoverAction.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
            return UISwipeActionsConfiguration(actions: [recoverAction])
        }
        return nil
    }

    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
