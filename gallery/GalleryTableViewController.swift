//
//  GalleryTableViewController.swift
//  gallery
//
//  Created by Alex Hunsader on 4/9/18.
//  Copyright © 2018 Alex Hunsader. All rights reserved.
//

import UIKit

class GalleryTableViewController: UITableViewController {

    var im_galleries = Image_galleries()

    var selected: Int?
    var rename: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        clearsSelectionOnViewWillAppear = false
        if im_galleries.count == 0 {
            selected = 0
            performSegue(withIdentifier: "addGallery", sender: self)
        }
    }
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return section == 1 ? im_galleries.dead : (im_galleries.count - im_galleries.dead)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if im_galleries.get_index(indexPath: indexPath) != rename {
            cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
            cell.textLabel?.text = indexPath.section == 1 ? im_galleries.get_dead(num: indexPath.row) : im_galleries.get_alive(num: indexPath.row)
            cell.backgroundColor = (selected == im_galleries.get_index(indexPath: indexPath)) ?  #colorLiteral(red: 0.598716259, green: 0.8336279988, blue: 1, alpha: 1) : UIColor.white
        }
        else {
            cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath)
            if let inputCell = cell as? TextFieldTableViewCell {
                inputCell.textField.text = ""
                inputCell.resignation_handler = {
                    if let new = inputCell.textField.text {
                        let old = indexPath.section == 1 ? self.im_galleries.get_dead(num: indexPath.row) : self.im_galleries.get_alive(num: indexPath.row)
                        if new != "" {
                            self.im_galleries.change_name(old: old, new: new, index: self.im_galleries.get_index(indexPath: indexPath))
                        }
                        self.rename = nil
                        tableView.reloadData()
                    }
                }
                inputCell.textField.becomeFirstResponder()
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 1 ? "Recently Deleted" : ""
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected = im_galleries.get_alive_at(im_galleries.get_index(indexPath: indexPath)) ? im_galleries.get_index(indexPath: indexPath) : nil
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            var count = -1
            for i in 0..<self.im_galleries.count {
                if self.im_galleries.get_alive_at(i) { count += 1 }
                if count == indexPath.row { self.im_galleries.set_alive_at(i, false); break; }
            }
            self.selected = (self.selected == count) ? nil : self.selected
            tableView.reloadData()
        }
        delete.backgroundColor = UIColor.red
        if (im_galleries.get_alive_at(im_galleries.get_index(indexPath: indexPath)) && im_galleries.get_index(indexPath: indexPath) != rename) {
            return [delete]
        }
        return []
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let add_back = UIContextualAction(style: .normal, title: "Move from Trash") { action, index, idk  in
            var count = -1;
            for i in 0..<self.im_galleries.count {
                if !self.im_galleries.get_alive_at(i) { count += 1}
                if count == indexPath.row { self.im_galleries.set_alive_at(i, true); }
            }
            tableView.reloadData()
        }
        add_back.backgroundColor = UIColor.blue
        if indexPath.section == 1 {
            return UISwipeActionsConfiguration(actions: [add_back])
        }
        return nil
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("idk")
        if let id = segue.identifier {
            print("something")
            if id == "showGallery" {
                print("showGallery")
                if let index = tableView.indexPathForSelectedRow?.row {
                    if let destination = segue.destination.childViewControllers.first as? GalleryCollectionViewController {
                        print("hey")
                        destination.images = im_galleries.get_gallery(name: im_galleries.get_alive(num: index))
                        destination.id = im_galleries.get_id(im_galleries.get_alive(num: index))!
                        destination.im_galleries = im_galleries
                    }
                }
            } else {
                if let destination = segue.destination.childViewControllers.first as? GalleryCollectionViewController {
                    destination.images = im_galleries.get_gallery(name: "Untitled")
                    selected = im_galleries.get_gallery_num(name: "Untitled \(Image_galleries.u() - 1)")
                    destination.id = Image_galleries.u() - 1
                    destination.im_galleries = im_galleries
                    tableView.reloadData()
                }
            }
            
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        print("fuck")
        if identifier == "showGallery" {
            if let section = tableView.indexPathForSelectedRow?.section, section == 1 {
                print("not performing")
                return false
            }
            if let indexPath = tableView.indexPathForSelectedRow {
                if selected == im_galleries.get_index(indexPath: indexPath) {
                    print("not performing")
                    rename = im_galleries.get_index(indexPath: indexPath)
                    tableView.reloadData()
                    return false
                }
            }
        }
        print("performing")
        return true
    }

}
