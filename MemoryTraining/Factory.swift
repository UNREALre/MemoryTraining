//
//  Factory.swift
//  SlotMachine
//
//  Created by Александр Подрабинович on 03/01/15.
//  Copyright (c) 2015 Alex Podrabinovich. All rights reserved.
//

import Foundation
import UIKit

class Factory {
    class func generateEmpty() -> [[MainImages]] {
        var images: [[MainImages]] = []
        
        let kNumberOfSlots = 3
        let kNumberOfContainers = 3
        
        for var containerNumber=0; containerNumber<kNumberOfContainers; containerNumber++ {
            var imageArray: [MainImages] = []
            for var slotNumber=0; slotNumber<kNumberOfSlots; slotNumber++ {
                var image: MainImages!
                image = MainImages(id: 0, name: "default", image: UIImage(named: "default"))
                imageArray.append(image)
            }
            images.append(imageArray)
        }
        
        return images
    }
    
    class func getImageByID(id: Int) -> MainImages {
        var image: MainImages!
        
        switch id {
        case 1:
            image = MainImages(id: 1, name: "me", image: UIImage(named: "me"))
        case 2:
            image = MainImages(id: 2, name: "mother", image: UIImage(named: "mother"))
        case 3:
            image = MainImages(id: 3, name: "father", image: UIImage(named: "father"))
        case 4:
            image = MainImages(id: 4, name: "parents", image: UIImage(named: "parents"))
        case 5:
            image = MainImages(id: 5, name: "cat", image: UIImage(named: "cat"))
        case 6:
            image = MainImages(id: 6, name: "bridge", image: UIImage(named: "bridge"))
        case 7:
            image = MainImages(id: 7, name: "bigben", image: UIImage(named: "bigben"))
        case 8:
            image = MainImages(id: 8, name: "panda", image: UIImage(named: "panda"))
        case 9:
            image = MainImages(id: 9, name: "koala", image: UIImage(named: "koala"))
        default:
            image = MainImages(id: 0, name: "default", image: UIImage(named: "default"))
        }
        
        return image
    }
    
    class func createPreviewImages() -> [[MainImages]] {
        let kNumberOfSlots = 3
        let kNumberOfContainers = 3
        
        var images: [[MainImages]] = []
        
        for var containerNumber=0; containerNumber<kNumberOfContainers; containerNumber++ {
            var imageArray: [MainImages] = []
            for var slotNumber=0; slotNumber<kNumberOfSlots; slotNumber++ {
                var image = Factory.createPreviewImage(containerNumber, col: slotNumber)
                imageArray.append(image)
            }
            imageArray = shuffle(imageArray)
            images.append(imageArray)
        }
        
        return images
    }
    
    class func createPreviewImage(row: Int, col: Int) -> MainImages {
        var currentImage: MainImages!
        
        var myTuple = (row, col)
        
        switch myTuple {
        case (0,0):
            currentImage = MainImages(id: 1, name: "me", image: UIImage(named: "me"))
        case (0,1):
            currentImage = MainImages(id: 2, name: "mother", image: UIImage(named: "mother"))
        case (0,2):
            currentImage = MainImages(id: 3, name: "father", image: UIImage(named: "father"))
        case (1,0):
            currentImage = MainImages(id: 4, name: "parents", image: UIImage(named: "parents"))
        case (1,1):
            currentImage = MainImages(id: 5, name: "cat", image: UIImage(named: "cat"))
        case (1,2):
            currentImage = MainImages(id: 6, name: "bridge", image: UIImage(named: "bridge"))
        case (2,2):
            currentImage = MainImages(id: 7, name: "bigben", image: UIImage(named: "bigben"))
        case (2,0):
            currentImage = MainImages(id: 8, name: "panda", image: UIImage(named: "panda"))
        case (2,1):
            currentImage = MainImages(id: 9, name: "koala", image: UIImage(named: "koala"))
        default:
            currentImage = MainImages(id: 0, name: "default", image: UIImage(named: "default"))
        }
        
        return currentImage
    }
    
    class func createMainImages (imagesNum: Int) -> [[MainImages]] {
        let kNumberOfSlots = 3
        let kNumberOfContainers = 3
        
        var images: [[MainImages]] = []
        var usedIDS: [Int] = []
        
        for var containerNumber=0; containerNumber<kNumberOfContainers; containerNumber++ {
            var imageArray: [MainImages] = []
            for var slotNumber=0; slotNumber<kNumberOfSlots; slotNumber++ {
                var image: MainImages!
                image = Factory.createImage(usedIDS)
                usedIDS.append(image.id)
                imageArray.append(image)
            }
            images.append(imageArray)
        }
        
        let total = 9
        if imagesNum < total {
            var diff = total - imagesNum
            var usedImages: [(Int, Int)] = []
            var defaultImage = MainImages(id: 0, name: "default", image: UIImage(named: "default"))
            while diff > 0 {
                var randomRow = Int(arc4random_uniform(UInt32(images.count)))
                var randomCol = Int(arc4random_uniform(UInt32(images[randomRow].count)))
                
                if usedImages.count > 0 {
                    var tupleExist = true
                    while tupleExist {
                        var isHere = false
                        for indexPath in usedImages {
                            if (indexPath.0 == randomRow) && (indexPath.1 == randomCol) {
                                isHere = true
                                randomRow = Int(arc4random_uniform(UInt32(images.count)))
                                randomCol = Int(arc4random_uniform(UInt32(images[randomRow].count)))
                            }
                        }
                        if !isHere {
                            tupleExist = false
                        }
                    }
                    
                }

                usedImages += [(randomRow,randomCol)]

                images[randomRow][randomCol] = defaultImage
                diff--
            }
        }
        
        return images
    }
    
    class func createImage(usedIDS: [Int]) -> MainImages {
        
        var randomNumber = Int(arc4random_uniform(UInt32(9)))
        
        while (contains(usedIDS, (randomNumber+1))) {
            randomNumber = Int(arc4random_uniform(UInt32(9)))
        }

        var image: MainImages!
        
        switch randomNumber {
        case 0:
            image = MainImages(id: 1, name: "me", image: UIImage(named: "me"))
        case 1:
            image = MainImages(id: 2, name: "mother", image: UIImage(named: "mother"))
        case 2:
            image = MainImages(id: 3, name: "father", image: UIImage(named: "father"))
        case 3:
            image = MainImages(id: 4, name: "parents", image: UIImage(named: "parents"))
        case 4:
            image = MainImages(id: 5, name: "cat", image: UIImage(named: "cat"))
        case 5:
            image = MainImages(id: 6, name: "bridge", image: UIImage(named: "bridge"))
        case 6:
            image = MainImages(id: 7, name: "bigben", image: UIImage(named: "bigben"))
        case 7:
            image = MainImages(id: 8, name: "panda", image: UIImage(named: "panda"))
        case 8:
            image = MainImages(id: 9, name: "koala", image: UIImage(named: "koala"))
        default:
            image = MainImages(id: 0, name: "default", image: UIImage(named: "default"))
        }
        
        return image
    }
    
    class func shuffle<C: MutableCollectionType where C.Index == Int>(var list: C) -> C {
        let count = countElements(list)
        for i in 0..<(count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            swap(&list[i], &list[j])
        }
        return list
    }

}