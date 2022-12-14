//
//  ContactsTableViewController.swift
//  Ch12 - Contact List
//
//  Created by user216619 on 9/18/22.
//

import UIKit
import CoreData

class ContactsTableViewController: UITableViewController {
    
    // let contacts = ["Jim", "John", "Dana", "Rosie", "Justin", "Jeremy", "Sarah", "Matt", "Joe", "Donald", "Jeff"]
       
    var contacts:[NSManagedObject] = []
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
       
    override func viewDidLoad() {
        super.viewDidLoad()
        //loadDataFromDatabase()
        self.navigationItem.leftBarButtonItem = self.editButtonItem
           
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
       
    override func viewWillAppear(_ animated: Bool) {
        loadDataFromDatabase()
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }

    func loadDataFromDatabase() {
        // Read settings to enable sorting
        let settings = UserDefaults.standard
        let sortField = settings.string(forKey: Constants.kSortField)
        let sortAscending = settings.bool(forKey: Constants.kSortDirectionAscending)
        
        //Set up Core Data Context
        let context = appDelegate.persistentContainer.viewContext
        
        //Set up Request
        //defines what data is to be pulled from CoreData
        let request = NSFetchRequest<NSManagedObject>(entityName: "Contact")
        
        //Specify sorting
        let sortDescriptor = NSSortDescriptor(key: sortField, ascending: sortAscending)
        let sortDescriptorArray = [sortDescriptor]
        
        //to sort by multiple fields, add more sort descriptors to the array
        request.sortDescriptors = sortDescriptorArray
        
        //Execute request & stores results in contacts array
        //placed in do block bc fetch may fail
        do {
            contacts = try context.fetch(request)
        }
        catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
      
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //creates cell object
        //dequeue...Identifier: = method dequeues existing cell if one available or creates new one using class/nib file previously registered
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactsCell", for: indexPath)
           
        // Configure the cell...
        let contact = contacts[indexPath.row] as? Contact
        //textLabel = cell property used to set text that will show up on screen; data pulled from contacts array using requested row number as index
        cell.textLabel?.text = contact?.contactName
        cell.detailTextLabel?.text = contact?.city
        cell.accessoryType = .detailDisclosureButton
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditContact" {
            let contactController = segue.destination as? ContactsViewController
            let selectedRow = self.tableView.indexPath(for: sender as! UITableViewCell)?.row
            let selectedContact = contacts[selectedRow!] as? Contact
            contactController?.currentContact = selectedContact!
        }
    }
     
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedContact = contacts[indexPath.row] as? Contact
        let name = selectedContact!.contactName!
        let actionHandler = {
            (action:UIAlertAction!) -> Void in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "ContactController")
                as? ContactsViewController
            controller?.currentContact = selectedContact
            self.navigationController?.pushViewController(controller!, animated: true)
        }
           
        //alertController = pops up message on screen with 1+ buttons for user to click
        let alertController = UIAlertController(title: "Contact selected", message: "Selected row: \(indexPath.row) (\(name))", preferredStyle: .alert)
        //actionCancel = dismisses alert
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        //showDetails = takes user to ContactsController to see all contact data
        //if clicked, actionHandler method is called (above)
        let actionDetails = UIAlertAction(title: "Show Details", style: .default, handler: actionHandler)
        alertController.addAction(actionCancel)
        alertController.addAction(actionDetails)
        present(alertController, animated: true, completion: nil)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
           return true
    }
     */

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let contact = contacts[indexPath.row] as? Contact
            let context = appDelegate.persistentContainer.viewContext
            context.delete(contact!)
            do {
                try context.save()
            }
            catch  {
                fatalError("Error saving context: \(error)")
            }
            loadDataFromDatabase()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
}
