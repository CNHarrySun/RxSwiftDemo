//
//  ContactsViewModel.swift
//  RxSwiftTest
//
//  Created by HarrySun on 2019/7/26.
//  Copyright © 2019 HarrySun. All rights reserved.
//

import RxSwift

struct ContactsViewModel {
    // 创建发送指定值的 Observerble
    let data = Observable.just([
        Contacts("HarrySun1", phoneNumber: "1"),
        Contacts("HarrySun2", phoneNumber: "12"),
        Contacts("HarrySun3", phoneNumber: "123"),
        Contacts("HarrySun4", phoneNumber: "1234"),
        Contacts("HarrySun5", phoneNumber: "12345")
        ])
}
