//
//  FeedImageCell.swift
//  Prototype
//
//  Created by Pankaj Mangotra on 06/09/21.
//

import UIKit

final class FeedImageCell: UITableViewCell {
    
    @IBOutlet weak var locationContainer: UIView!
    @IBOutlet private(set) var locationLabel: UILabel!
    @IBOutlet private(set) var feedImageView: UIImageView!
    @IBOutlet private(set) var descriptionLabel: UILabel!
}
