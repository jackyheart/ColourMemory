//
//  Card.swift
//  ColourMemory
//
//  Created by Jacky Tjoa on 12/5/16.
//  Copyright © 2016 Coolheart. All rights reserved.
//

import UIKit

class Card: NSObject, NSCopying {

    var image:UIImage;
    var color:Int;
    var isFront:Bool;
    
    required init(image:UIImage, color:Int) {
        self.image = image;
        self.color = color;
        self.isFront = false;
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        return self.dynamicType.init(image: image, color: color)
    }
}
