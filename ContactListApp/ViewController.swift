//
//  ViewController.swift
//  ContactListApp
//
//  Created by Ahmed on 13/12/2022.
//

import UIKit
import SQLite3


class ViewController: UITableViewController {
    var deleteindex : String?
    var db : OpaquePointer?
    var dataSource : [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = openDB()
        query(db: db)
        setup()
      // createTable(db: db)
    }

// setup
    func setup() {
       // add button
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showAlertController))
    }
    
    
    
    
// open connection with data base
    
    func openDB() -> OpaquePointer? {

        var db : OpaquePointer?
        let fileUrl = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathExtension("Contact.sqlite")
        if sqlite3_open(fileUrl?.path, &db) == SQLITE_OK{
            print("success")
            return db
        }else{
            print("failed")
            return nil
        }
    }
    

// creating table
    func createTable(db:OpaquePointer?){
        let createTableString = """
        CREATE TABLE Contact1 (Id INT PRIMARY KEY NOT NULL ,
        Name CHAR(255),
        number Char(255));
        
        """
        
        var createTableStatment : OpaquePointer?
        
        
        if sqlite3_prepare(db, createTableString, -1,&createTableStatment, nil) == SQLITE_OK {
            
            if sqlite3_step(createTableStatment) == SQLITE_DONE{
                
                print("Table created")
                
            }else{
                
                print("Table Not created")
            }
            
            
        }else{
            print("Create table statment is not prepared")
        }
        
        sqlite3_finalize(createTableStatment)
        
    }
    
/// insert data into database
    func insertIntoDB (id:Int32,name:NSString,number:NSString,db:OpaquePointer?){
        
        let insertStatmentString = """
        INSERT INTO Contact1 (id,name,number) values (?,?,?);
"""
        var insertStatment : OpaquePointer?
        
        
        if sqlite3_prepare_v2(db, insertStatmentString, -1, &insertStatment, nil) == SQLITE_OK {
            
            sqlite3_bind_int(insertStatment, 1, id)
            sqlite3_bind_text(insertStatment, 2, name.utf8String, -1, nil)
            sqlite3_bind_text(insertStatment, 3, number.utf8String, -1, nil)
            if sqlite3_step(insertStatment) == SQLITE_DONE {
                print("insert done")
                
            }else {
                showErrorMessage()
                print("Not inserted")
            }
            //query(db: self.db)
            
        }else{
            print("insert Statment not prepared ")
            
        }
        
           sqlite3_finalize(insertStatment)
    }
    
    
// retrive data from database
    
    func query (db:OpaquePointer?){
        let queryStatmentString = """
        
        Select * from Contact1
"""
        var queryStatment : OpaquePointer?
        
        if sqlite3_prepare_v2(db,queryStatmentString, -1, &queryStatment, nil) == SQLITE_OK {
            
            while sqlite3_step(queryStatment) == SQLITE_ROW {
                
                
                let id = sqlite3_column_int(queryStatment, 0)
                
                
                guard let QuaryResultsCol1 = sqlite3_column_text(queryStatment, 1) else {
                    print("nulllll")
                    return
                }
                
                
                guard let QuaryResultsCol2 = sqlite3_column_text(queryStatment, 2) else {
                    print("nulllll")
                    return
                }
                
                let name = String(cString: QuaryResultsCol1)
                
                let number = String(cString: QuaryResultsCol2)
                //dataSource.removeAll()
                if dataSource.contains("\(id) | \(name) | \(number)"){
                    continue
                }else{
                    dataSource.append("\(id) | \(name) | \(number)")
                }
                
                
            }
           
            self.tableView.reloadData()
        }else{
            print("query statment not prepared")
        }
        
        sqlite3_finalize(queryStatment)
    }
    
// delete from database
    func deleteFromDB(deleteindex: String,db:OpaquePointer?) {
    
        // delete cell index from database
        var index = 0
        var newindex = ""
        for i in deleteindex{
            
            if i == " "{
                break
            }else{
                newindex.append(i)
                index = Int(newindex)!
            }
        }
        
        
        
        let deleteStatmentString = """
        delete from Contact1 where id = \(index)
"""
        var deleteStatment : OpaquePointer?
        if sqlite3_prepare_v2(db, deleteStatmentString, -1, &deleteStatment, nil) == SQLITE_OK {
            
            if sqlite3_step(deleteStatment) == SQLITE_DONE {
                
                
                print("DELETED")
            }else{
                print("NOOT")
            }
        
            
        }else{
            print("not prepersd")
        }
        
        sqlite3_finalize(deleteStatment)
        
    }
    
// Alert button
    
    
    @objc func showAlertController() {
      
        let ac = UIAlertController(title: "Enter Contact", message: nil , preferredStyle: .alert)
        ac.addTextField(configurationHandler: { tf in
            tf.placeholder = "Enter Order Code"
        })
        ac.addTextField(configurationHandler: { tf in
            tf.placeholder = "Enter Name"
        })
        ac.addTextField { tf in
            tf.placeholder = "Enter Phone Number"
        }
        let submitBtn = UIAlertAction(title: "Submit",style: .default,handler: { action in
            guard let id = ac.textFields?[0].text else { return }
            print(id)
            
            guard let name = ac.textFields?[1].text else {return}
            print(name)
            
            guard let phone = ac.textFields?[2].text else {return}
            print(phone)
            
            guard let idInt32 = Int32(id) else {return}
            //guard let phoneInt32 = Int32(phone) else {return}
            self.insertIntoDB(id: idInt32, name: name as NSString, number: phone as NSString , db: self.db)
            self.query(db: self.db)
        })
        
       
        
        ac.addAction(submitBtn)
        
        self.present(ac, animated: true)
        
    }
    
/// reapeating id handling
    ///
    func showErrorMessage(){
        
        let ac = UIAlertController(title: "User with this Id already exists", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
                     
        self.present(ac, animated: true)
        
    }
 
/// Table View Cell
    
 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = dataSource[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
/// Delete From Table View
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            deleteindex = dataSource[indexPath.row]
            dataSource.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            deleteFromDB(deleteindex: deleteindex!, db: db)
          
            tableView.endUpdates()
           
        }
    }
    
}

