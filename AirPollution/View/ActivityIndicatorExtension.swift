//
//  ActivityIndicatorExtension.swift
//  AirPollution
//
//  Created by Gokturk Ramazanoglu on 24.01.18.
//  Copyright © 2018 zigzag. All rights reserved.
//

import Foundation
import UIKit

extension UIActivityIndicatorView {
    
    
    func hideActivityIndicator() {
        alpha = 0
        stopAnimating()
    }
    
    func showActivityIndicator() {
        alpha = 1
        startAnimating()
    }
    
}
