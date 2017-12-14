//
//  DepartureTableViewCell.swift
//  AirPollution
//
//  Created by Gokturk Ramazanoglu on 14.12.17.
//  Copyright © 2017 zigzag. All rights reserved.
//

import UIKit

class DepartureTableViewCell: UITableViewCell {
    @IBOutlet weak var departureLabel: UILabel!
    @IBOutlet weak var lineLabel: UILabel!
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var delayLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
