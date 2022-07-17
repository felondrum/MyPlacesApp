//
//  NewPlaceVC.swift
//  MyPlacesApp
//
//  Created by Антон Филиппов on 17.07.2022.
//

import UIKit

class NewPlaceVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }

// MARK: Table view deligate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
        } else {
            view.endEditing(true)
        }
    }
  
}

// MARK: Text field deligate

extension NewPlaceVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
