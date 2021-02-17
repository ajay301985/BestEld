//
//  DailyLogTableViewCell.swift
//  BestELD
//
//  Created by Ajay Rawat on 2021-02-17.
//

import UIKit

class DailyLogTableViewCell: UITableViewCell {

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var infoLabel: UILabel!
  @IBOutlet weak var iconImageView: UIImageView!
  @IBOutlet weak var valueTextField: UITextField!
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
