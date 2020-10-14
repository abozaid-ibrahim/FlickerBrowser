//
//  Destination.swift
//
//  Created by abuzeid on 14.10.20.
//  Copyright © 2020 abuzeid. All rights reserved.
//

import Foundation
import UIKit
typealias Contact = String
enum Destination {
    case photos
    
    var controller: UIViewController {
        switch self {
        case .photos:
            return AlbumsController(viewModel: AlbumsViewModel())
       
        }
    }
}
