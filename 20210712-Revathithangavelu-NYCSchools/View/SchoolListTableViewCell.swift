//
//  SchoolListTableViewCell.swift
//  20210712-Revathithangavelu-NYCSchools
//
//  Created by Revathi on 13/07/21.
//

import UIKit

class SchoolListTableViewCell: UITableViewCell {

    @IBOutlet weak var schoolNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
