//
//  Contacts.swift
//  RxSwiftTest
//
//  Created by HarrySun on 2019/7/26.
//  Copyright © 2019 HarrySun. All rights reserved.
//

import UIKit

class Contacts: NSObject {
    var name = ""
    var phoneNumber = ""
    
    init(_ name: String, phoneNumber: String) {
        self.name = name
        self.phoneNumber = phoneNumber
    }
}
