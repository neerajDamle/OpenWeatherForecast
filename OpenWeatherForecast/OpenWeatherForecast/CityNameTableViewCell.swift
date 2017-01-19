//
//  CityNameTableViewCell.swift
//  OpenWeatherForecast
//
//  Created by Neeraj Damle on 9/4/15.
//  Copyright (c) 2015 Neeraj Damle. All rights reserved.
//

import UIKit

class CityNameTableViewCell: UITableViewCell {

    @IBOutlet var cityNameLabel: UILabel!
    @IBOutlet var progressIconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
