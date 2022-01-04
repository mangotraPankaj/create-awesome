//
//  UITableView+Dequeueing.swift
//  EssentialFeediOS
//
//  Created by Pankaj Mangotra on 02/11/21.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
