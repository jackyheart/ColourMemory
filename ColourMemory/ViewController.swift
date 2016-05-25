//
//  ViewController.swift
//  ColourMemory
//
//  Created by Jacky Tjoa on 12/5/16.
//  Copyright © 2016 Coolheart. All rights reserved.
//

import UIKit
import CoreData

//array shuffling code from:
//http://stackoverflow.com/questions/24026510/how-do-i-shuffle-an-array-in-swift

extension CollectionType {
    /// Return a copy of `self` with its elements shuffled
    func shuffle() -> [Generator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

extension MutableCollectionType where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }
        
        for i in 0..<count - 1 {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}

class ViewController: UIViewController {
    
    //outlets
    @IBOutlet weak var logoImgView: UIImageView!
    @IBOutlet weak var scoreLbl: UILabel!
    @IBOutlet weak var btnHighScore: UIButton!
    @IBOutlet weak var gameAreaView: UIView!
    @IBOutlet weak var gameOverImgView: UIImageView!
    @IBOutlet weak var btnRestart: UIButton!
    
    //variables
    var cardData:[Card] = []//card database
    var cardPlayArr:[Card?] = []//card play array
    var cardBg:UIImage!
    let CARD_TYPES = 8
    let MAX_CHOSEN_CARD = 2
    let MATCH_SCORE = 2
    let MISMATCH_SCORE = -1
    var score = 0
    var screenLock:Bool = false
    var chosenCardImgViewArr:[UIImageView] = []
    var matchCardRemoved = 0
    var isGameBoardLoaded:Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //card bg
        let bg = UIImage(named: "card_bg")
        if let bg = bg {
            self.cardBg = bg
        }
        
        //load card database
        for(var i=0; i < CARD_TYPES; i++) {
        
            let imageName = "colour\(i+1)"
            let image = UIImage(named: imageName)
            
            if let image = image {
                let card = Card(image: image, color: i+1)
                self.cardData.append(card)
            }
        }
        
        //init game board
        self.loadGameBoard()
        
        //misc
        self.gameAreaView.backgroundColor = UIColor.clearColor()
        self.btnHighScore.layer.cornerRadius = 5.0
        self.btnRestart.layer.cornerRadius = 5.0
        self.gameOverImgView.hidden = true
        self.btnRestart.hidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if(!self.isGameBoardLoaded) {
            self.isGameBoardLoaded = true
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Game board
    
    func loadGameBoard() {
    
        //hide views
        self.gameOverImgView.hidden = true
        self.btnRestart.hidden = true
        
        //reset counter & score
        self.matchCardRemoved = 0
        self.score = 0
        self.scoreLbl.text = "Score: 0"
        
        //clear card play array
        self.cardPlayArr.removeAll()
        
        //clear card image view from board
        for v:UIView in self.gameAreaView.subviews {
            v.removeFromSuperview()
        }
        
        //load cards to play array
        for(var i=0; i < CARD_TYPES; i++) {
            
            let card = self.cardData[i]
            card.isFront = false //set all card to face down
            self.cardPlayArr.append(card)
            
            //make a card copy
            let cardCopy = card.copy() as? Card
            
            if let cardCopy = cardCopy {
                self.cardPlayArr.append(cardCopy)//append twice !
            }
        }
        
        //constants
        let offsetY:CGFloat = 20
        let padding:CGFloat = 10
        let numOfCardPerRow = 4
        let cardWHRatio = self.cardBg.size.width / self.cardBg.size.height
        
        //calculate card size
        let availSpace = self.view.bounds.size.width - (CGFloat(numOfCardPerRow) + 1) * padding
        let cardWidth = availSpace / CGFloat(numOfCardPerRow)
        let cardHeight = cardWidth / cardWHRatio
        
        //shuffle cards
        self.cardPlayArr.shuffleInPlace()
        
        //layout cards
        var i = 0
        var j = 0
        for(var idx=0; idx < self.cardPlayArr.count; idx++) {
            
            //let card = self.cardPlayArr[idx]
            
            if(idx > 0 && idx % numOfCardPerRow == 0) {
                //new row
                i++
                j = 0
            }
            
            //card view
            let imgView = UIImageView(image: self.cardBg)
            imgView.userInteractionEnabled = true
            imgView.tag = idx //image tag as card index
            imgView.frame = CGRectMake(
                padding + CGFloat(j) * (cardWidth + padding) + 5.0, //5.0 is extra offset
                offsetY + CGFloat(i) * (cardHeight + padding),
                cardWidth,
                cardHeight)
            
            //gesture recognizer
            let tapGesture = UITapGestureRecognizer(target: self, action: "cardTapped:")
            imgView.addGestureRecognizer(tapGesture)
            
            //add to view
            self.gameAreaView.addSubview(imgView)
            
            j++
        }
    }
    
    //MARK: - Gesture handlers
    
    func cardTapped(recognizer: UITapGestureRecognizer) {
    
        if recognizer.view is UIImageView {
            
            if (self.screenLock) {
                //screen lock activated !
                return
            }
            
            let imgView = recognizer.view as! UIImageView
            
            //retrieve Card
            let card = self.cardPlayArr[imgView.tag]//image tag is card index
            
            //debugging
            //print("sel card val: \(card.color), tag: \(imgView.tag)")
            
            //add to chosen card array
            if(self.chosenCardImgViewArr.count < MAX_CHOSEN_CARD && !self.chosenCardImgViewArr.contains(imgView)) {
                self.chosenCardImgViewArr.append(imgView)
            }
            
            if(self.chosenCardImgViewArr.count >= MAX_CHOSEN_CARD) {
                self.screenLock = true
            }
            
            //animate flip
            if let card = card {
                self.flipCard(card, imageView: imgView)
            }
        }
    }
    
    //MARK: - Helper
    
    func flipCard(card: Card, imageView: UIImageView) {
        
        var animationOptions:UIViewAnimationOptions = .TransitionFlipFromLeft
        
        if card.isFront {
            imageView.image = self.cardBg //shows card back
        } else {
            animationOptions = .TransitionFlipFromRight
            imageView.image = card.image
        }
        
        UIView.transitionWithView(imageView, duration: 0.5, options: animationOptions, animations: { () -> Void in
            
            }) { (finished) -> Void in
                
            if(finished) {
                
                if(self.chosenCardImgViewArr.count == self.MAX_CHOSEN_CARD) {
                    
                    sleep(1)//pause 1 seconds
                    
                    let tag1 = self.chosenCardImgViewArr[0].tag
                    let tag2 = self.chosenCardImgViewArr[1].tag
                    
                    let card1 = self.cardPlayArr[tag1]
                    let card2 = self.cardPlayArr[tag2]
                    
                    if let card1 = card1, card2 = card2 {
                    
                        if(card1.color == card2.color) {
                            
                            self.score += self.MATCH_SCORE
                            self.scoreLbl.text = "Score: \(self.score)"
                        
                            while(self.chosenCardImgViewArr.count > 0) {
                            
                                let index = self.chosenCardImgViewArr.count - 1
                                let chosenCardImgView:UIImageView = self.chosenCardImgViewArr[index]
                                let chosenCardTag = chosenCardImgView.tag
                                
                                //remove from play array
                                self.cardPlayArr[chosenCardTag] = nil
                                
                                UIView.animateWithDuration(0.5, animations: { () -> Void in
                                    
                                    chosenCardImgView.center = CGPointMake(self.logoImgView.center.x, self.logoImgView.center.y - 100)//animate to far top left of the screen
                                    chosenCardImgView.alpha = 0.0
                                    
                                }, completion: { (finished) -> Void in
                                    
                                    if(finished) {
                                        //remove from superview
                                        chosenCardImgView.removeFromSuperview()
                                    }
                                })
                                
                                //remove entry from chosen card image view array
                                self.chosenCardImgViewArr.removeAtIndex(index)
                                
                                //count matching removed cards
                                self.matchCardRemoved++
                            }
                            
                            if(self.matchCardRemoved == self.cardPlayArr.count) {
                                
                                //Game Over !
                                
                                //present name input
                                self.presentAlertInputName()
                                
                                //show & animate 'Game' over text
                                self.gameOverImgView.hidden = false
                                self.gameOverImgView.transform = CGAffineTransformMakeScale(3.0, 3.0)
                                
                                UIView.animateWithDuration(0.5, animations: { () -> Void in
                                    
                                    self.gameOverImgView.transform = CGAffineTransformMakeScale(1.0, 1.0)
                                    
                                    }, completion: { (finished) -> Void in
                                        
                                        if(finished) {
                                            self.btnRestart.hidden = false
                                        }
                                })
                            }
                        }
                        else {
                            
                            self.score += self.MISMATCH_SCORE
                            self.scoreLbl.text = "Score: \(self.score)"
                            
                            //turn card face down & remove from card chosen array
                            while(self.chosenCardImgViewArr.count > 0) {
                                
                                //card image view
                                let index = self.chosenCardImgViewArr.count - 1
                                let chosenCardImgView:UIImageView = self.chosenCardImgViewArr[index]
                                let chosenCardTag = chosenCardImgView.tag
                                
                                //card data
                                let chosenCard = self.cardPlayArr[chosenCardTag]
                                
                                //debugging
                                //print("chosenCard: \(chosenCard.color), tag: \(chosenCardTag)")
                                
                                //flip back
                                if let chosenCard = chosenCard {
                                    if(chosenCard.isFront) {
                                        
                                        chosenCard.isFront = false
                                        chosenCardImgView.image = self.cardBg //shows card back
                                        
                                        UIView.transitionWithView(chosenCardImgView, duration: 0.5, options: .TransitionFlipFromLeft, animations: nil, completion: nil)
                                    }
                                }
                                
                                //remove card image view
                                self.chosenCardImgViewArr.removeAtIndex(index)
                                
                            }//end while
                            
                        }//end else
                        
                        if (self.chosenCardImgViewArr.count == 0) {
                            
                            //release screen lock !
                            self.screenLock = false
                        }
                        
                    }//end if both card exists
                    
                }//if chosen card reach maximum allowed chosen cards
            }
        }
        
        card.isFront = !card.isFront //toggle front/back
    }
    
    //MARK: - Input Popup
    
    func presentAlertInputName(){
    
        //popup
        let alert = UIAlertController(title: "Game Over !", message: "Enter your name:", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.placeholder = "Your name here..."
        })
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            
            let textField = alert.textFields![0]
            
            let inputString = textField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())//remove leading/trailing spaces & newlines
            
            //validation
            if(inputString?.characters.count == 0) {
                
                let alertInvalidInput = UIAlertController(title: "Invalid Input", message: "Please enter your name", preferredStyle: .Alert)
                alertInvalidInput.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
                    self.presentAlertInputName()//show input popup again
                }))

                self.presentViewController(alertInvalidInput, animated: true, completion: nil)
            }
            else {
                
                //save to CoreData
                let highScore = NSEntityDescription.insertNewObjectForEntityForName("HighScore", inManagedObjectContext: CDHelper.sharedInstance.managedObjectContext) as! HighScore
                highScore.name = inputString
                highScore.score = self.score
                
                do {
                    try CDHelper.sharedInstance.managedObjectContext.save()
                    
                    let successAlert = UIAlertController(title: "Score saved", message: "Your score is: \(self.score)\n Your score has been saved to the database", preferredStyle: .Alert)
                    successAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(successAlert, animated: true, completion: nil)
                    
                } catch {
                    print("error saving to CoreData: \(error)")
                }
            }
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: - IBAction
    
    @IBAction func highScoresTapped(sender: AnyObject) {
        
        performSegueWithIdentifier("SegueHighScore", sender: self)
    }
    
    @IBAction func restartTapped(sender: AnyObject) {
        
        self.loadGameBoard()
    }
}

