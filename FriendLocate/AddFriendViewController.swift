//
//  AddFriendViewController.swift
//  FriendLocate
//
//  Created by Petr Reshetin on 09/11/2016.
//  Copyright © 2016 Petr Reshetin. All rights reserved.
//

import UIKit

class AddFriendViewController: UIViewController {
    
    
    @IBAction func cancel(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindToMap", sender: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
