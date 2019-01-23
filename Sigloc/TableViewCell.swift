//
//  TableViewCell.swift
//  Sigloc
//
//  Created by jay on 1/21/19.
//  Copyright © 2019 jay. All rights reserved.
//

import UIKit
import CoreLocation

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    var display: Display?
    var location: Location? {
        didSet {
            display = Display(self)
            display?.display()
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        display = nil
    }
}

struct Display {
    weak var cell: TableViewCell?
    init(_ cell: TableViewCell) {
        self.cell = cell
    }
    func display() {
        if let cell = cell,
            let location = cell.location {
            var log = ""
            if let placemark = location.placemark {
                log = String(format: "%@, %@ - %@",
                             placemark.subAdministrativeArea ?? "unknown",
                             placemark.administrativeArea ?? "unknown",
                             location.timestamp.description(with: NSLocale.current))
            } else {
                log = String(format: "%d, %d - %@",
                             location.location.coordinate.latitude,
                             location.location.coordinate.longitude,
                             location.timestamp.description(with: NSLocale.current))
            }
            cell.label.text = log
        }
    }
}
