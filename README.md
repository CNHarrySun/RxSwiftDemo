# 函数响应式编程 FRP

> #### Function Reactive Programming：函数响应式编程是种编程范式。我们通过不同的构建函数，来创建所需要的数据序列。最后通过适当的方式来响应这个序列。这就是函数响应式编程。它结合了函数式编程以及响应式编程。

> ##### 函数式编程
> Masonry、SnapKit 就是我们最常见的函数式编程,通过对象.方法1().方法2.....

> 在程序开发中：
> a ＝ b ＋ c 
>
> 赋值之后 b 或者 c 的值变化后，a 的值不会跟着变化

> ##### 响应式编程 
> 
> 响应式编程，目标就是，如果 b 或者 c 的数值发生变化，a 的数值会同时发生变化；


> #### RxSwift 核心思想就是 FRP。

## 一、RxSwift 是什么？

###### 先说下 Rx：
ReactiveX，简写 Rx，是一个可以帮助我们简化异步编程的框架，它对观察者模式进行了扩展，让我们可以自由组合多个事件。(Rx 支持几乎全部的流行编程语言，有 RxJava/RxJS/Rx.NET 等)

社区网站： [reactivex.io](http://reactivex.io/)


###### 然后再说下 RxSwift ：
RxSwift 是 Rx 的 Swift 版本，它尝试将原有的一些概念移植到 iOS/macOS 平台。

RxSwift 将程序中的事件传递相应方法进行了统一，将其（delegate、notification、target-action 等）全替换成 Rx 的“信号链”方式


###### 基本原理：

用户输入、点击事件、定时器、网络请求等都可以当成 Observable（被观察者），Observer（观察者）总会在 Observable 处注册一个订阅，当事件发生时，Observable 找到所有的订阅并通知观察者。

## 二、为什么要使用 RxSwift

> 复合 - Rx 就是复合的代名词
>
> 复用 - 因为它易复合
>
> 清晰 - 因为声明都是不可变更的
>
> 易用 - 因为它抽象的了异步编程，使我们统一了代码风格
>
> 稳定 - 因为 Rx 是完全通过单元测试的

具体来说就是

在编写代码时我们经常会需要检测某些值的变化，然后进行相应的处理。比如说按钮的点击事件、textFiled 值的变化、tableView 中 cell 的点击事件等等。在日常搬砖中，我们针对不同的情况，需要采用不同的事件传递方法去处理，比如 delegate、Notifinotion、Target Action、KVO 等等。

## 三、如何使用 RxSwift


引入的两个库
```
import RxSwift
import RxCocoa
```
- RxSwift：它只是基于 Swift 语言的 Rx 标准实现接口库，所以 RxSwift 里不包含任何 Cocoa 或者 UI 方面的类。
- RxCocoa：是基于 RxSwift 针对于 iOS 开发的一个库，它通过 Extension 的方法给原生的比如 UI 控件添加了 Rx 的特性，使得我们更容易订阅和响应这些控件的事件。



### 看下面几个例子：

**1. Target Action**

传统方式实现
```
button.addTarget(self, action: #selector(buttonEvent), for: .touchUpInside)

@objc func buttonEvent() {
print("button Event")
}
```

用 RxSwift 实现
```
button.rx.tap
.subscribe(onNext: {
print("button event")
})
.disposed(by: disposeBag)
```

**2. Notifinotion**

传统方式实现
```
NotificationCenter.default.addObserver(self, selector: #selector(notificationAction(_:)), name: NSNotification.Name("NotificationName"), object: nil)

@objc func notificationAction(_ notification: Notification) {
// do something
}
```

用 RxSwift 实现
```
NotificationCenter.default.rx.notification(NSNotification.Name("NotificationName"))
.subscribe(onNext: { (notification) in
// do something
})
.disposed(by: disposeBag)
```


**3. delegate**

传统方式实现
```
// 遵循代理
class ViewController: UITextFieldDelegate 
// 设置代理
textField.delegate = self
// 实现代理方法
func textFieldDidEndEditing(_ textField: UITextField) {
// do something
}
```

用 RxSwift 实现
```
textField.rx.controlEvent([.editingDidEnd])
.asObservable()
.subscribe(onNext: { _ in
// do something
})
.disposed(by: disposeBag)


// 字符输入时
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
```
> RxCocoa 用 extensiton 的方式，为 UITextfield，UIlabel 等控件添加了很多可监听的属性，这里的 textfield.rx.text 就是一个

> **看上面几个例子，和传统方式相比，Rx 的代码更加清晰简洁，易读、易维护。**



**4. BehaviorRelay**

作用：存储时常需要更新的数据

```
let number: BehaviorRelay = BehaviorRelay<Int>(value: 0)
let disposeBag = DisposeBag()

// 订阅 number 的变化，skip(1): 跳过初始化时值的变化
number.skip(1).subscribe(onNext: { (num) in
print("数字变化：\(num)")
}).disposed(by: disposeBag)


for i in 1...5 {
number.accept(i)
}
```
输出结果
```
数字变化：1
数字变化：2
数字变化：3
数字变化：4
数字变化：5
```


**5. 绑定**
```
let isCodeValid = textField.rx.text
.orEmpty
.map { $0.count == 6 }
.share(replay: 1)

// 验证码输入是否有效 -> 验证码提示语是否隐藏
isCodeValid
.bind(to: errorLabel.rx.isHidden)
.disposed(by: disposeBag)
// 验证码输入是否有效 -> 提交按钮是否可点击
isCodeValid
.bind(to: button.rx.isEnabled)
.disposed(by: disposeBag)
```

> 代码的简单说明：
> - orEmpty：可以将 String? 类型的 ControlProperty（ControlProperty 说明是被观察者） 转成 String，省得我们再去解包。（见下图）
> - share(replay: 1) ：我们用 isCodeValid 来控制验证码提示语是否隐藏以及登录按钮是否可用。shareReplay 就是让他们共享这一个源，而不是为他们单独创建新的源。这样可以减少不必要的开支。
> - DisposeBag：作用是 Rx 在视图控制器或者其持有者将要销毁的时候，自动释法掉绑定在它上面的资源。它是通过类似“订阅处置机制”方式实现（类似于 NotificationCenter 的 removeObserver）。

从下图的源码中我们可以看到 UITextField 的 rx.text 属性类型便是 ControlProperty<String?>

![textField.rx.text](https://upload-images.jianshu.io/upload_images/1253108-91a308ae7127f33c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


**6. TableView**

传统方式实现
```
import Foundation

// 联系人列表数据源
struct ContactsViewModel {
let data = [
Contacts("HarrySun1", phoneNumber: "1"),
Contacts("HarrySun2", phoneNumber: "12"),
Contacts("HarrySun3", phoneNumber: "123"),
Contacts("HarrySun4", phoneNumber: "1234"),
Contacts("HarrySun5", phoneNumber: "12345")
]
}



/*
接着我们设置 UITableView 的委托，并让视图控制器实现 UITableViewDataSource 和 UITableViewDelegate 协议及相关的协议方法。
这个大家肯定都写过无数遍了，也没什么好讲的
*/
import UIKit
import RxSwift

class ViewController: UIViewController {

//tableView对象
@IBOutlet weak var tableView: UITableView!

// 联系人列表数据源
let contactsViewModel = ContactsViewModel()

override func viewDidLoad() {
super.viewDidLoad()

//设置代理
tableView.dataSource = self
tableView.delegate = self
}
}

extension ViewController: UITableViewDataSource {
//返回单元格数量
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
return contactsViewModel.data.count
}

//返回对应的单元格
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
-> UITableViewCell {
let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
let contacts = contactsViewModel.data[indexPath.row]
cell.textLabel?.text = "\(contacts.name) : \(contacts.phoneNumber)"
return cell
}
}

extension ViewController: UITableViewDelegate {
//单元格点击
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
let contacts = contactsViewModel.data[indexPath.row]
print("你选中的联系人信息【\(contacts)】")
}
}
```


用 RxSwift 实现
```
// 对 viewModel 修改
/* 
这里我们将 data 属性变成一个可观察序列对象（Observable Squence），而对象当中的内容和我们之前在数组当中所包含的内容是完全一样的。
简单说就是“序列”可以对这些数值进行“订阅（Subscribe）”，有点类似于“通知（NotificationCenter）”
*/ 

import RxSwift

// 联系人列表数据源
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



// 对视图控制器代码修改
/*
这里我们不再需要实现数据源和委托协议了。而是写一些响应式代码，让它们将数据和 UITableView 建立绑定关系。
*/
import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

let tableView = UITableView()
// 联系人列表数据源
let contactsViewModel = ContactsViewModel()

let disposeBag = DisposeBag()

override func viewDidLoad() {
super.viewDidLoad()

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
```

> 代码的简单说明：
> - rx.items(cellIdentifier:）:这是 Rx 基于 cellForRowAt 数据源方法的一个封装。传统方式中我们还要有个 numberOfRowsInSection 方法，使用 Rx 后就不再需要了（Rx 已经帮我们完成了相关工作）。
> - rx.modelSelected： 这是 Rx 基于 UITableView 委托回调方法 didSelectRowAt 的一个封装。


更多例子参见 RxSwift 中文文档：[为什么要使用 RxSwift ？](https://beeth0ven.github.io/RxSwift-Chinese-Documentation/content/why_rxswift.html#target-action)


上面看了几个 RxSwift 的例子，也感受到了函数响应式编程 清晰简洁、易读、易维护的代码，下面我们看下 RxSwift 的最佳搭档：MVVM

## MVVM

##### 原先常用的架构：MVC

![苹果默认推荐的设计模式 MVC](https://upload-images.jianshu.io/upload_images/1253108-e1926d607d38e7b7.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- Model：数据层。负责读写数据，保存 App 状态等
<!--- View：界面显示层。负责和用户交互，向用户显示页面，反馈用户行为等-->
- Controller：业务逻辑层。负责业务逻辑、事件响应、数据加工等工作


缺点：
- ViewController 既扮演了 View 的角色，又扮演了 ViewController 的角色
- 而 Model 在 VIewController 中又可以直接与 View 进行交互
- 当 App 交互复杂的时候，就会发现 ViewController 将变得十分臃肿，大量代码被添加到控制器中，使得控制器负担过重。



##### MVVM

![微软 MVVM](https://upload-images.jianshu.io/upload_images/1253108-a2a46b7f5cc8df98.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

优点：
- 可以对 ViewController 进行瘦身
- 实现逻辑视图的复用。比如一个 ViewModel 可以绑定到不同的 View 上，让多个 View 重用相同的视图逻辑。
- 而且使用 MVVM 可以大大降低代码的耦合性，方便进行单元测试以及维护，也方便多人协作开发（比如一个人负责逻辑实现，一个人负责 UI 实现）。

缺点：
- 相较于 MVC，使用 MVVM 会轻微的增加代码量，但是总体上减少了代码的复杂性。
- 还有就是有一定的学习成本（如何数据绑定等）。
<!--- Debug 麻烦。-->






## RxSwift 和 MVVM 结合使用
##### 例1. 上面 tableView 的实现


##### 例2. 两个网络请求返回数据后跳转
```


// endAction 和 payAction 是两个网络请求，把两个接口请求是否完成压缩为一个信号再做操作
Observable.merge(viewModel.endAction.elements, viewModel.payAction.elements)
.observeOn(MainScheduler.instance) // 保证在主线程
.subscribe(onNext: { [weak self] model in
// doSomething
})
.disposed(by: disposeBag)
```


> #### 代码简单说明
##### merge
将多个 Observables 合并成一个

![merge](https://upload-images.jianshu.io/upload_images/1253108-282239f477acf072.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


##### observeOn
指定 Observable 在那个 Scheduler 发出通知


##### Action
Action 被定义为一个类 Action<Input, Element>，Input 是输入的元素，Element 是 Action 处理完之后返回的元素。

一般绑定到 button 上：button.rx.action = action

action.execute()：执行 Action

action.elements：请求成功，可以拿到 Action 返回的 Element

action.executing：请求是否在执行，可以用来展示或者隐藏 HUD



>#### *Action 详细的内容可以看下列代码*

**使用 Action 写一个网络请求**

1.在 viewModel 中写一个请求数据的 Action

```
lazy var shareAction = Action<Void, (URL?, String, String)> {        //  Action<input，output> {  }
guard let orderno = self.endModel?.orderno, let location = LocationService.shared.lastLocation else {
return Observable.empty()
}

// 网络请求
return ShareRequest(orderid: orderno, location: location)
.rx
.start(usingCache:  true)
.mapModel(ShareModel.self)
.catchErrorJustReturn(self.defaultShareModel)        //  请求接口失败后取默认的model
.map {          //  map：遍历并做相应处理
(URL(string: $0.shareUrl), $0.comment, "  " + $0.hashtag + "  ")
}
}
```



2. 在 viewController 中调用一次 action.execute()


```
viewModel.shareAction.execute(())
```

3. action中的请求成功，返回数据之后的操作
```
viewModel.shareAction.elements
.observeOn(MainScheduler.instance)
.subscribe(onNext: { [weak self] tuple in
guard let `self` = self else { return }

// 处理请求完成后的操作
})
.disposed(by: disposeBag)
```

4. 请求中的操作
请求开始时显示 HUD，请求结束后隐藏 HUD
distinctUntilChanged：值修改的时候才会走此方法
```
viewModel.shareAction.executing
.distinctUntilChanged()          // 数据发生改变才会走
.observeOn(MainScheduler.instance)
.subscribe(onNext: { [weak self] executing in
if executing {
ProgressHUD.showLoadingHUD(in: self?.view)
} else {
ProgressHUD.hideLoadingHUD(in: self?.view)
}
})
.disposed(by: disposeBag)
```



