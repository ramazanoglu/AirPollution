//
//  AirDataAnnotationView.swift
//  AirPollution
//
//  Created by Gokturk Ramazanoglu on 12.12.17.
//  Copyright © 2017 zigzag. All rights reserved.
//

import UIKit
import MapKit

class AirDataAnnotationView: MKAnnotationView {
    var imageView: UIView!
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        self.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        self.imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        self.addSubview(self.imageView)
        
        self.imageView.layer.cornerRadius = 5.0
        self.imageView.layer.masksToBounds = true
        
        
    }
    
    var color: UIColor? {
        get {
            return self.imageView.backgroundColor
        }
        
        set {
            self.imageView.backgroundColor = newValue
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
