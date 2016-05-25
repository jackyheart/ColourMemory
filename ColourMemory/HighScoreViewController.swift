//
//  HighScoreViewController.swift
//  ColourMemory
//
//  Created by Jacky Tjoa on 15/5/16.
//  Copyright © 2016 Coolheart. All rights reserved.
//

import UIKit
import CoreData

class HighScoreViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    //outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnClose: UIButton!
    
    //variables
    var highScoreArray:[HighScore] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.backgroundColor = UIColor.clearColor()
        self.btnClose.layer.cornerRadius = 5.0
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //fetch Highscore from CoreData
        let fetchRequest = NSFetchRequest(entityName: "HighScore")
        let sortDescriptor = NSSortDescriptor(key: "score", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            self.highScoreArray = try CDHelper.sharedInstance.managedObjectContext.executeFetchRequest(fetchRequest) as! [HighScore]
            self.tableView.reloadData()
            
        } catch {
            print("Error fetching entity 'HighScore': \(error)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.highScoreArray.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 30.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("CellIdentifier", forIndexPath: indexPath) as! HighScoreCell
        cell.backgroundColor = UIColor.clearColor()
        
        //data
        let highScore = self.highScoreArray[indexPath.row]
    
        cell.nameLbl.text = highScore.name
        cell.scoreLbl.text = "\(highScore.score!)"
        cell.rankLbl.text = "\(indexPath.row + 1)"
        
        return cell
    }
    
    //MARK: - IBActions
    
    @IBAction func closeBtnTapped(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
