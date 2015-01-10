//
//  ViewController.swift
//  MemoryTraining
//
//  Created by Александр Подрабинович on 09/01/15.
//  Copyright (c) 2015 Alex Podrabinovich. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    var firstContainer: UIView!
    var secondContainer: UIView!
    var thirdContainer: UIView!
    var fourthContainer: UIView!
    var firstSubContainerFirst: UIView!
    var firstSubContainerSecond: UIView!
    
    var titleLabel: UILabel!
    var levelTitleLabel: UILabel!
    var levelLabel: UILabel!
    var winLabel: UILabel!
    var loseLabel: UILabel!
    
    var startGameButton: UIButton!
    var resetGameButton: UIButton!
    
    var mainPicButtons: [UIButton] = []
    var picButtons: [UIButton] = []

    let kMarginForView:CGFloat = 10
    let kMarginFromTop:CGFloat = 20
    let kMarginForPic:CGFloat = 5
    
    let kParts:CGFloat = 1/8
    let kHalf:CGFloat = 1/2
    let kFourth:CGFloat = 1/4
    let kThird:CGFloat = 1/3
    
    let iRows = 3
    let iCols = 3
    let hideInterval:Double = 6.0
    
    var disableButtons = true
    
    var level:Int = 0
    
    var mainImages: [[MainImages]] = []
    var previewImages: [[MainImages]] = []
    
    var currentShownPics: [(picID: Int, row: Int, col: Int)] = []
    var defaultImage = MainImages(id: 0, name: "default", image: UIImage(named: "default"))
    var openedImages: [[MainImages]] = []
    
    
    let managedObject = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext!
    var fetchedResultsController: NSFetchedResultsController = NSFetchedResultsController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setupContainers()
        setupFirstContainer()
        setupSecondContainer()
        setupThirdContainer()
        setupFourthContainer()
        
        fetchedResultsController = getFetchResultsController()
        fetchedResultsController.delegate = self
        fetchedResultsController.performFetch(nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //IBAction functions
    func startGameButtonPressed(button: UIButton?) {
        if level == 0 {
            removeImageViews()
            currentShownPics.removeAll(keepCapacity: true)
            picButtons.removeAll(keepCapacity: true)
            openedImages.removeAll(keepCapacity: true)
            
            level++
            
            openedImages = Factory.generateEmpty()
            
            let currentLevel = levelLabel.text?.toInt()
            mainImages = Factory.createMainImages(level)
            previewImages = Factory.createPreviewImages()
            
            setupSecondContainer()
            setupThirdContainer()
            
            updateMainView()
            
            NSTimer.scheduledTimerWithTimeInterval(hideInterval, target: self, selector: Selector("hidePictures"), userInfo:nil, repeats:false)
        }
    }
    
    func resetGameButtonPressed(button: UIButton) {
        level = 0
        startGameButtonPressed(button)
    }
    
    func previewImagePressed(button: UIButton) {
        if !disableButtons {
            for but in picButtons {
                but.layer.borderWidth = 0
            }
            
            button.layer.borderColor = UIColor.redColor().CGColor
            button.layer.borderWidth = 3
        }
    }
    func mainImagePressed(button: UIButton) {
        var selectedPreview = 0
        for but in picButtons {
            if but.layer.borderWidth > 0 {
                selectedPreview = but.tag
                break
            }
        }
        
        if !disableButtons && selectedPreview > 0 {
            if button.tag == selectedPreview {
                var sourceImage = Factory.getImageByID(button.tag)
                var row: Int?
                var col: Int?
                for shown in currentShownPics {
                    if shown.picID == selectedPreview {
                        row = shown.row
                        col = shown.col
                    }
                }
                
                var cOpened = 0
                for var i=0; i<iRows; i++ {
                    for var j=0; j<iCols; j++ {
                        if openedImages[i][j].id == 0
                        {
                            if row == nil && col == nil {
                                openedImages[i][j] = defaultImage
                            }
                            else if row == i && col == j {
                                cOpened++
                                openedImages[i][j] = sourceImage
                            }
                            else {
                                openedImages[i][j] = defaultImage
                            }
                        }
                        else {
                            cOpened++
                        }
                    }
                }
                
                setupSecondContainer(isDefault: true, imagesToFill: openedImages)
                
                if currentShownPics.count == cOpened {
                    if level < 9 {
                        goToNextLevel()
                    }
                    else {
                        removeImageViews()
                        
                        self.loseLabel = UILabel()
                        self.loseLabel.text = "Кроля, ты УМНИЧКА!!! Победа! :-)"
                        self.loseLabel.textColor = UIColor.greenColor()
                        self.loseLabel.font = UIFont(name: "MarkerFelt-Wide", size: 35)
                        self.loseLabel.sizeToFit()
                        self.loseLabel.center = CGPointMake(self.secondContainer.bounds.width * kHalf, self.secondContainer.bounds.height * kHalf)
                        self.secondContainer.addSubview(loseLabel)
                        
                        let appDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
                        let managedObjectContext = appDelegate.managedObjectContext
                        let entityDescription = NSEntityDescription.entityForName("History", inManagedObjectContext: managedObjectContext!)
                        let currentItem = History(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext!)
                        
                        currentItem.level = level
                        currentItem.date = NSDate()
                        
                        appDelegate.saveContext()
                    }
                }
            }
            else {
                removeImageViews()
                
                self.loseLabel = UILabel()
                self.loseLabel.text = "Кроля, ты проиграла! Тренируйся усерднее!"
                self.loseLabel.textColor = UIColor.redColor()
                self.loseLabel.font = UIFont(name: "MarkerFelt-Wide", size: 35)
                self.loseLabel.sizeToFit()
                self.loseLabel.center = CGPointMake(self.secondContainer.bounds.width * kHalf, self.secondContainer.bounds.height * kHalf)
                self.secondContainer.addSubview(loseLabel)
                
                let appDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
                let managedObjectContext = appDelegate.managedObjectContext
                let entityDescription = NSEntityDescription.entityForName("History", inManagedObjectContext: managedObjectContext!)
                let currentItem = History(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext!)
                
                currentItem.level = level
                currentItem.date = NSDate()
                
                appDelegate.saveContext()
            }
        }
    }
    
    func showHistoryButtonPressed(button: UIButton) {
        self.performSegueWithIdentifier("showHistoryTable", sender: self)
    }
    //IBAction functions end
    
    

    //Helper functions
    func goToNextLevel() {
        disableButtons = true
        
        removeImageViews()
        currentShownPics.removeAll(keepCapacity: true)
        picButtons.removeAll(keepCapacity: true)
        openedImages.removeAll(keepCapacity: true)
        
        level++
        
        openedImages = Factory.generateEmpty()
        
        let currentLevel = levelLabel.text?.toInt()
        mainImages = Factory.createMainImages(level)
        previewImages = Factory.createPreviewImages()
        
        setupSecondContainer()
        setupThirdContainer()
        
        updateMainView()
        
        NSTimer.scheduledTimerWithTimeInterval(hideInterval, target: self, selector: Selector("hidePictures"), userInfo:nil, repeats:false)
    }
    
    func hidePictures() {
        for var i=0; i<mainImages.count; i++ {
            for var j=0; j<mainImages[i].count; j++ {
                if mainImages[i][j].id > 0 {
                    let curItem = (mainImages[i][j].id, i,j)
                    currentShownPics += [curItem]
                }
            }
        }
        
        disableButtons = false
        
        setupSecondContainer(isDefault: true)
    }
    
    func updateMainView() {
        self.levelLabel.text = "\(level)"
    }
    
    func setupContainers() {
        self.firstContainer = UIView(frame: CGRectMake(self.view.bounds.origin.x + kMarginForView, self.view.bounds.origin.y + kMarginFromTop, self.view.bounds.width - (kMarginForView*2), self.view.bounds.height * kParts))
        self.firstContainer.backgroundColor = UIColor.blueColor()
        self.view.addSubview(firstContainer)
        
        self.secondContainer = UIView(frame: CGRectMake(self.view.bounds.origin.x + kMarginForView, self.view.bounds.origin.y + self.firstContainer.bounds.height, self.view.bounds.width - (kMarginForView*2), self.view.bounds.height * kParts*4))
        self.secondContainer.backgroundColor = UIColor.lightGrayColor()
        self.view.addSubview(secondContainer)
        
        self.thirdContainer = UIView(frame: CGRectMake(self.view.bounds.origin.x + kMarginForView, self.view.bounds.origin.y + self.firstContainer.bounds.height + self.secondContainer.bounds.height + 20
            , self.view.bounds.width * kThird * 2, self.view.bounds.height * kParts*2))
        self.thirdContainer.backgroundColor = UIColor.grayColor()
        self.thirdContainer.center = CGPoint(x: (self.view.bounds.width * kHalf), y: (self.thirdContainer.bounds.height * kHalf + 10) + self.secondContainer.bounds.height + self.firstContainer.bounds.height)
        self.view.addSubview(thirdContainer)
        
        self.fourthContainer = UIView(frame: CGRectMake(self.view.bounds.origin.x + kMarginForView, self.view.bounds.origin.y + self.firstContainer.bounds.height + self.secondContainer.bounds.height + self.thirdContainer.bounds.height + 20, self.view.bounds.width - (kMarginForView*2), self.view.bounds.height * kParts))
        self.fourthContainer.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(fourthContainer)
    }
    
    func setupFirstContainer() {
        self.firstSubContainerFirst = UIView(frame: CGRectMake(self.firstContainer.bounds.origin.x, self.firstContainer.bounds.origin.y, self.firstContainer.bounds.width * kHalf, self.firstContainer.bounds.height))
        self.firstContainer.addSubview(firstSubContainerFirst)
        
        self.firstSubContainerSecond = UIView(frame: CGRectMake(self.firstContainer.bounds.origin.x + self.firstSubContainerFirst.bounds.width, self.firstContainer.bounds.origin.y, self.firstContainer.bounds.width * kHalf, self.firstContainer.bounds.height))
        self.firstContainer.addSubview(firstSubContainerSecond)
        
        
        self.titleLabel = UILabel()
        self.titleLabel.text = "Тренировка Памяти"
        self.titleLabel.textColor = UIColor.yellowColor()
        self.titleLabel.font = UIFont(name: "MarkerFelt-Wide", size: 35)
        self.titleLabel.sizeToFit()
        self.titleLabel.center = CGPointMake(self.firstSubContainerFirst.bounds.width * kHalf, self.firstSubContainerFirst.bounds.height * kHalf)
        self.firstSubContainerFirst.addSubview(titleLabel)
        
        self.levelTitleLabel = UILabel()
        self.levelTitleLabel.text = "Текущий уровень"
        self.levelTitleLabel.textColor = UIColor.yellowColor()
        self.levelTitleLabel.font = UIFont(name: "Menlo-Bold", size: 16)
        self.levelTitleLabel.sizeToFit()
        self.levelTitleLabel.center = CGPointMake((self.firstSubContainerSecond.bounds.width * kFourth*3) - kMarginForView*2, self.firstSubContainerSecond.bounds.height * kHalf)
        self.firstSubContainerSecond.addSubview(levelTitleLabel)
        
        self.levelLabel = UILabel()
        self.levelLabel.text = "00"
        self.levelLabel.textColor = UIColor.redColor()
        self.levelLabel.font = UIFont(name: "Menlo-Bold", size: 20)
        self.levelLabel.sizeToFit()
        self.levelLabel.center = CGPointMake((self.firstSubContainerSecond.bounds.width * kFourth * 4) - kMarginForView*2, self.firstSubContainerSecond.bounds.height * kHalf)
        self.firstSubContainerSecond.addSubview(levelLabel)
    }
    
    func setupSecondContainer(isDefault: Bool = false, imagesToFill: [[MainImages]] = []) {
        for var i=0; i<iRows; i++ {
            for var j=0; j<iCols; j++ {
                
                var imageView = UIImageView()
                var imageViewButton = UIButton()
                
                if !isDefault && mainImages.count > 0 {
                    var currentImage = mainImages[i][j]
                    imageView.image = currentImage.image
                    imageViewButton.tag = currentImage.id
                }
                else {
                    if imagesToFill.count > 0 {
                        var currentImage = imagesToFill[i][j]
                        imageView.image = currentImage.image
                    }
                    else {
                        imageView.image = UIImage(named: "default")
                    }
                }
                

                imageView.frame = CGRectMake(self.secondContainer.bounds.origin.x + (self.secondContainer.bounds.width * kThird * CGFloat(j)), self.secondContainer.bounds.origin.y + (self.secondContainer.bounds.height * kThird * CGFloat(i)), self.secondContainer.bounds.width * kThird - kMarginForPic, self.secondContainer.bounds.height * kThird - kMarginForPic)
                
                if !isDefault {
                    imageViewButton.frame = CGRectMake(self.secondContainer.bounds.origin.x + (self.secondContainer.bounds.width * kThird * CGFloat(j)), self.secondContainer.bounds.origin.y + (self.secondContainer.bounds.height * kThird * CGFloat(i)), self.secondContainer.bounds.width * kThird - kMarginForPic, self.secondContainer.bounds.height * kThird - kMarginForPic)
                    imageViewButton.addTarget(self, action: "mainImagePressed:", forControlEvents: UIControlEvents.TouchUpInside)
                    
                    mainPicButtons.append(imageViewButton)
                    self.secondContainer.addSubview(imageViewButton)
                }
                
                self.secondContainer.addSubview(imageView)

            }
        }
    }
    
    func setupThirdContainer() {
        for var i=0; i<iRows; i++ {
            for var j=0; j<iCols; j++ {
                
                var imageView = UIImageView()
                var imageViewButton = UIButton()

                if previewImages.count > 0 {
                    var currentImage = previewImages[i][j]
                    imageView.image = currentImage.image
                    imageViewButton.tag = currentImage.id
                }
                else {
                    imageView.image = UIImage(named: "default")
                }
                
                imageView.frame = CGRectMake(self.thirdContainer.bounds.origin.x + (self.thirdContainer.bounds.width * kThird * CGFloat(j)), self.thirdContainer.bounds.origin.y + (self.thirdContainer.bounds.height * kThird * CGFloat(i)), self.thirdContainer.bounds.width * kThird - kMarginForPic, self.thirdContainer.bounds.height * kThird - kMarginForPic)
                
                imageViewButton.frame = CGRectMake(self.thirdContainer.bounds.origin.x + (self.thirdContainer.bounds.width * kThird * CGFloat(j)), self.thirdContainer.bounds.origin.y + (self.thirdContainer.bounds.height * kThird * CGFloat(i)), self.thirdContainer.bounds.width * kThird - kMarginForPic, self.thirdContainer.bounds.height * kThird - kMarginForPic)
                imageViewButton.addTarget(self, action: "previewImagePressed:", forControlEvents: UIControlEvents.TouchUpInside)
                
                picButtons.append(imageViewButton)
                    
                self.thirdContainer.addSubview(imageView)
                self.thirdContainer.addSubview(imageViewButton)
            }
        }
    }
    
    func setupFourthContainer() {
        
        self.startGameButton = UIButton()
        self.startGameButton.setTitle("Начать игру!", forState: UIControlState.Normal)
        self.startGameButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        self.startGameButton.titleLabel?.font = UIFont(name: "Superclarendon-Bold", size: 16)
        self.startGameButton.sizeToFit()
        self.startGameButton.center = CGPointMake(self.fourthContainer.bounds.width * kHalf / 2, self.fourthContainer.bounds.height * kHalf)
        self.startGameButton.addTarget(self, action: "startGameButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        self.fourthContainer.addSubview(startGameButton)
        
        self.resetGameButton = UIButton()
        self.resetGameButton.setTitle("Начать сначала", forState: UIControlState.Normal)
        self.resetGameButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        self.resetGameButton.titleLabel?.font = UIFont(name: "Superclarendon-Bold", size: 16)
        self.resetGameButton.sizeToFit()
        self.resetGameButton.center = CGPointMake(self.fourthContainer.bounds.width * kHalf, self.fourthContainer.bounds.height * kHalf)
        self.resetGameButton.addTarget(self, action: "resetGameButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        self.fourthContainer.addSubview(resetGameButton)

        self.resetGameButton = UIButton()
        self.resetGameButton.setTitle("Таблица успехов", forState: UIControlState.Normal)
        self.resetGameButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        self.resetGameButton.titleLabel?.font = UIFont(name: "Superclarendon-Bold", size: 16)
        self.resetGameButton.sizeToFit()
        self.resetGameButton.center = CGPointMake(self.fourthContainer.bounds.width * 3/4, self.fourthContainer.bounds.height * kHalf)
        self.resetGameButton.addTarget(self, action: "showHistoryButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        self.fourthContainer.addSubview(resetGameButton)
    }
    
    func removeImageViews() {
        if self.secondContainer != nil {
            let container: UIView = self.secondContainer!
            let subViews: Array = container.subviews
            for view in subViews {
                view.removeFromSuperview()
            }
        }
        if self.thirdContainer != nil {
            let container: UIView = self.thirdContainer!
            let subViews: Array = container.subviews
            for view in subViews {
                view.removeFromSuperview()
            }
        }
    }
    
    //Helper functions end
    
    
    //Data Core Functions
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
    }
    
    func pillsFetchRequest() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: "History")
        let activeSortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [activeSortDescriptor]
        
        return fetchRequest
    }
    
    func getFetchResultsController() -> NSFetchedResultsController {
        fetchedResultsController = NSFetchedResultsController(fetchRequest: pillsFetchRequest(), managedObjectContext: managedObject, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }
    //Data Core Functions end
    
}

