//
//  ViewController.swift
//  RxSwiftTest
//
//  Created by HarrySun on 2019/7/26.
//  Copyright © 2019 HarrySun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    let errorLabel = UILabel()
    let button = UIButton()
    let textField = UITextField()
    let number: BehaviorRelay = BehaviorRelay<Int>(value: 0)
    
    let tableView = UITableView()
    
    // 联系人列表数据源
    let contactsViewModel = ContactsViewModel()
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        rxButton()
//        rxNotification()
        rxDelegate()
//        rcTableView()
//        rxBinding()
    }
    
    // 测试 button
    func rxButton() {
        view.addSubview(button)
        button.frame = CGRect(x: 100, y: 100, width: 100, height: 50)
        button.backgroundColor = .red
        
        button.rx.tap
            .subscribe(onNext: {
                print("button event")
                NotificationCenter.default.post(name: NSNotification.Name("NotificationName"), object: nil)
            })
            .disposed(by: disposeBag)
    }
    
    // 测试 Notification
    func rxNotification() {
        NotificationCenter.default.rx.notification(NSNotification.Name("NotificationName"))
            .subscribe(onNext: { (notification) in
                print("notification")
            })
            .disposed(by: disposeBag)
    }
    
    // 测试 delegate
    func rxDelegate() {
        view.addSubview(textField)
        textField.layer.borderWidth = 1
        textField.frame = CGRect(x: 10, y: 100, width: 300, height: 50)
        
        textField.rx.controlEvent([.editingChanged])
            .asObservable()
            .subscribe(onNext: { _ in
                print("字符输入：\(self.textField.text ?? "")")
            })
            .disposed(by: disposeBag)
        // 或者
        textField.rx.text
            .subscribe(onNext: { text in
                print("text:\(text ?? "")")
            })
            .disposed(by: disposeBag)
        
        textField.rx.controlEvent([.editingDidEnd])
            .asObservable()
            .subscribe(onNext: { _ in
                // do something
            })
            .disposed(by: disposeBag)
    }
    
    // 测试 BehaviorRelay
    func rcBehaviorRelay() {
        number.skip(1).subscribe(onNext: { (num) in
            print("数字变化：\(num)")
        }).disposed(by: disposeBag)
        
        for i in 1...5 {
            number.accept(i)
        }
    }
    
    // 测试数据绑定
    func rxBinding() {
        let isCodeValid = textField.rx.text
            .orEmpty
            .map { $0.count == 6 }
            .share(replay: 1)
        // share(replay: 1) 是用来做什么的？
        // 我们用 isCodeValid 来控制验证码提示语是否隐藏以及登录按钮是否可用。shareReplay 就是让他们共享这一个源，而不是为他们单独创建新的源。这样可以减少不必要的开支。
        // 验证码输入是否有效 -> 提交按钮是否可点击
        isCodeValid
            .bind(to: errorLabel.rx.isHidden)
            .disposed(by: disposeBag)
        isCodeValid
            .bind(to: button.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
    // 测试 tableView
    func rcTableView() {
        view.addSubview(tableView)
        tableView.frame = view.frame
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        //将数据源数据绑定到tableView上
        contactsViewModel.data
            .bind(to: tableView.rx.items(cellIdentifier:"Cell")) { _, contacts, cell in
                cell.textLabel?.text = "\(contacts.name) : \(contacts.phoneNumber)"
            }.disposed(by: disposeBag)
        
        //tableView点击响应
        tableView.rx.modelSelected(Contacts.self).subscribe(onNext: { contacts in
            print("你选中的联系人信息【\(contacts)】")
        }).disposed(by: disposeBag)
    }
    
}
