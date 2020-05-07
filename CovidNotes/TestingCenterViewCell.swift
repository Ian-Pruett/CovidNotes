//
//  TestingCenterViewCell.swift
//  CovidNotes
//
//  Created by Ian Pruett on 5/5/20.
//  Copyright © 2020 Ian Pruett. All rights reserved.
//

import UIKit

// https://www.youtube.com/watch?v=fzjtvq-jC4E
protocol TestingCenterTableView {
    func onClickCell(index: Int)
}


class TestingCenterViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    var cellDelegate: TestingCenterTableView?
    var indexPath: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func infoButtonAction(_ sender: Any) {
        cellDelegate?.onClickCell(index: indexPath!.row)
    }
    

}
