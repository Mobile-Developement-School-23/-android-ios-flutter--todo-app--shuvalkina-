import UIKit
// swiftlint:disable all
protocol EditionDelegate {
    func itemToEdit(item: TodoItem)
    func displayEditItem (item: TodoItem)
    func cachedItem()//item: TodoItem)
}
class ItemsNavigationController: UIViewController, DismissionDelegate{
    func count() -> Int {
        return fileCache.todoItems.count
    }
    func add(newItem: TodoItem) {
        fileCache.addItem(newItem: newItem)
    }
    func save(_ fileType: String, _ fileName: String) {
        fileCache.saveData(fileType, fileName)
    }
    var itemTrasfer: TodoItem?
    var displayDelegate: EditionDelegate?
    var fileCache = FileCache()
    @IBAction func showButtonPressed(_ sender: UIButton) {
        if sender.isSelected {
            showButton.setTitle("Показать", for: .normal)
            for index in 0..<fileCache.todoItems.count {
                if fileCache.todoItems[index].done {
                    continue
                } else {
                    self.itemsTableView.beginUpdates()
                    self.itemsTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                    self.itemsTableView.endUpdates()
                }
            }
        } else {
            showButton.setTitle("Скрыть", for: .normal)
            itemsTableView.reloadData()
        }
    }
    @IBOutlet weak var doneLabel: UILabel!
    @IBOutlet weak var showButton: UIButton!
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet var itemsTableView: UITableView!
    override func viewDidLoad() {
        do {
            try fileCache.loadData("json", "todoItemsData")
        } catch {
            print("ошибка делегирования загрузки в делах")
        }
        var dones = 0
        for todos in fileCache.todoItems {
            if todos.done {
                dones += 1
            }
        }
        doneLabel.text = "Выполнено: "+String(dones)
        navigationController?.navigationBar.layoutMargins = UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 0)
        itemsTableView.delegate = self
        itemsTableView.dataSource = self
        itemsTableView.register(UINib(nibName: "ItemCell", bundle: nil), forCellReuseIdentifier: "ReusableItem")
        itemsTableView.rowHeight = 56.0
        itemsTableView.reloadData()
        super.viewDidLoad()

    }

    private let image = #imageLiteral(resourceName: "Add button")
    private var floatingButton: UIButton?
    private static let buttonHeight: CGFloat = 55.0
    private static let buttonWidth: CGFloat = 55.0
    private let roundValue = ItemsNavigationController.buttonHeight/2
    private let trailingValue: CGFloat = 170.0
    private let leadingValue: CGFloat = 40.0
    private let shadowRadius: CGFloat = 16.0
    private let shadowOpacity: Float = 0.2
    private let shadowOffset = CGSize(width: 0.0, height: 20.0)
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        createFloatingButton()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        guard floatingButton?.superview != nil else {  return }
        DispatchQueue.main.async {
            self.floatingButton?.removeFromSuperview()
            self.floatingButton = nil
        }
        super.viewWillDisappear(animated)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as? ItemViewController
        destination?.callbackClosure = { [weak self] in
            self?.itemsTableView.reloadData()
        }
        destination?.delegateee = self
        if itemTrasfer != nil {
            destination?.itemToEdit(item: itemTrasfer!)
            //            destination?.defaultScreen() // you can pass value to destination view controller
        }
    }
    private func createFloatingButton() {
        floatingButton = UIButton(type: .custom)
        floatingButton?.translatesAutoresizingMaskIntoConstraints = false
        floatingButton?.backgroundColor = .white
        floatingButton?.setImage(image, for: .normal)
        floatingButton?.addTarget(self, action: #selector(doThisWhenButtonIsTapped(_:)), for: .touchUpInside)
        constrainFloatingButtonToWindow()
        makeFloatingButtonRound()
        addShadowToFloatingButton()
    }
    @IBAction private func doThisWhenButtonIsTapped(_ sender: Any) {
                self.performSegue(withIdentifier: "itemViewSegue", sender: self)
    }
    private func constrainFloatingButtonToWindow() {
        DispatchQueue.main.async {
            guard let keyWindow = UIApplication.shared.keyWindow,
                  let floatingButton = self.floatingButton else { return }
            keyWindow.addSubview(floatingButton)
            keyWindow.trailingAnchor.constraint(equalTo: floatingButton.trailingAnchor,
                                                constant: self.trailingValue).isActive = true
            keyWindow.bottomAnchor.constraint(equalTo: floatingButton.bottomAnchor,
                                              constant: self.leadingValue).isActive = true
            floatingButton.widthAnchor.constraint(equalToConstant:
                                                    ItemsNavigationController.buttonWidth).isActive = true
            floatingButton.heightAnchor.constraint(equalToConstant:
                                                    ItemsNavigationController.buttonHeight).isActive = true
        }
    }
    private func makeFloatingButtonRound() {
        floatingButton?.layer.cornerRadius = roundValue
    }
    private func addShadowToFloatingButton() {
        floatingButton?.layer.shadowColor = UIColor.black.cgColor
        floatingButton?.layer.shadowOffset = shadowOffset
        floatingButton?.layer.masksToBounds = false
        floatingButton?.layer.shadowRadius = shadowRadius
        floatingButton?.layer.shadowOpacity = shadowOpacity
    }
}
    extension ItemsNavigationController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileCache.todoItems.count
    }
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            // swiftlint:disable:next force_cast
            let item = fileCache.todoItems[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableItem", for: indexPath) as! ItemCell
            cell.itemText.setTitle(item.text, for: .normal)
//            cell.cellDelegate = self
            if item.deadline == nil {
                cell.dataDisplay.isHidden = true
            } else {
                var date = Int(item.deadline!)
                date = date - date/1000 * 1000
                let month = DateFormatter().monthSymbols[date/100]
                let dateString = String(date - date/100*100)+" "+month
                cell.dataDisplay.setTitle(dateString, for: .normal)
            }
            if item.priority.rawValue == "важная" {
                cell.dealineImage.setImage(#imageLiteral(resourceName: "High Priority"), for: .normal)
            } else {
                cell.dealineImage.setImage(#imageLiteral(resourceName: "Common Priority"), for: .normal)
            }
            if item.done {
                cell.dealineImage.setImage(#imageLiteral(resourceName: "Done"), for: .normal)
                cell.dataDisplay.isHidden = true
                cell.itemText.setTitleColor(.lightGray, for: .normal)
                let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: item.text, attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
                attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
                cell.itemText.setAttributedTitle(attributeString, for: .normal)
            }
            let index = indexPath.row
                cell.editAction = { sender in
                    self.itemTrasfer = item
                    self.performSegue(withIdentifier: "itemViewSegue", sender: self)
                   }
                cell.doneAction = { sender in
                    print(index)
                    let item = self.fileCache.todoItems[index]
                    let newItem = TodoItem(id: item.id ,text: item.text, priority: item.priority, deadline: item.deadline, done: true, whenCreated: item.whenCreated, whenEdited: item.whenEdited)
        self.fileCache.addItem(newItem: newItem)
        self.fileCache.saveData("json", "todoItemsData")
                    self.itemsTableView.reloadRows(at: [indexPath], with: .automatic)
                   }
            return cell
        }
//        func editItem(_ item: TodoItem) {
//            if let destination = storyboard?.instantiateViewController (identifier: "ItemView") as?
//            ItemViewController {
//                print(item)
//                destination.itemToEdit(item: item)
////                destination.placeholderText.isHidden = true
////                destination.priorityBar.selectedSegmentIndex = 1
////                if item.priority.rawValue == "важная" {
////                    destination.priorityBar.selectedSegmentIndex = 2
////                } else {
////                    if item.priority.rawValue == "неважная" {
////                        destination.priorityBar.selectedSegmentIndex = 0
////                    }
////                }
////                if item.deadline != nil {
////                    let date = Int(item.deadline!)
////                    let year = date/1000
////                    let month = (date - year*1000)/100
////                    let day = date - year*1000 - month*10
////                    let monthString = DateFormatter().monthSymbols[month]
////                    let dateString = String(day)+" "+monthString+" "+String(day)
////                    let datePicker = destination.dateForPicker(date)
////                    destination.deadlineButton.isHidden = false
////                    destination.deadlineButton.setTitle(dateString, for: .normal)
////                    destination.deadlineLabel.isHidden = true
////                    destination.deadlineLabel2.isHidden = false
////                    destination.deadlineSwitch.isOn = true
////                    destination.deadlineSelecor.setDate(datePicker, animated: true)
//
////                self.performSegue(withIdentifier: "itemViewSegue", sender: self)
//
//                    self.navigationController?.pushViewController(destination,animated: true)
//            }
//
//        }
        
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let delete = UIContextualAction(style: .destructive, title: nil ) { _, _, completion in
            print("delete\(indexPath.row + 1)")
            let id = self.fileCache.todoItems[indexPath.row].id
            self.fileCache.deleteItem(id: id)
            self.fileCache.saveData("json", "todoItemsData")
            self.itemsTableView.beginUpdates()
            self.itemsTableView.deleteRows(at: [indexPath], with: .fade)
            self.itemsTableView.endUpdates()
            completion(true)
        }
        delete.image = UIImage(systemName: "trash")
        delete.backgroundColor = .systemRed
        let swipe = UISwipeActionsConfiguration(actions: [delete])
        return swipe
    }
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            let done = UIContextualAction(style: .normal, title: nil ) { _, _, completion in
                print("done checked\(indexPath.row + 1)")
                let item = self.fileCache.todoItems[indexPath.row]
                var newItem = TodoItem(id: item.id ,text: item.text, priority: item.priority, deadline: item.deadline, done: true, whenCreated: item.whenCreated, whenEdited: item.whenEdited)
                self.fileCache.addItem(newItem: newItem)
                self.fileCache.saveData("json", "todoItemsData")
                self.itemsTableView.reloadRows(at: [indexPath], with: .automatic)
//                self.itemsTableView.reloadData()
                completion(true)
            }
            done.image = UIImage(systemName: "checkmark.circle.fill")
            done.backgroundColor = .systemGreen
            let swipe = UISwipeActionsConfiguration(actions: [done])
            return swipe
        }
}

