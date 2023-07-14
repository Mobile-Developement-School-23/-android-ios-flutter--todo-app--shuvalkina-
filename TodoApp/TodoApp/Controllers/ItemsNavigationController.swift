import UIKit

class ItemsNavigationController: UIViewController, DismissionDelegate {
    func add(newItem: TodoItem) {
        fileCache.addItem(newItem: newItem)
    }
    func save(_ fileType: String, _ fileName: String) {
        fileCache.saveData(fileType, fileName)
    }
    func saveCD() {
        fileCache.saveItemsToCoreData()
    }
    func addCD(itemToAdd: TodoItem) {
        fileCache.insertItemToCD(iremToInsert: itemToAdd)
    }
    
    
    var delegate: URLManagerDelegate?
    var itemTrasfer: TodoItem?
    var displayDelegate: EditionDelegate?
    var fileCache = FileCache()
    var doneFlag = true
    var doneCount = 0
    
//    func formDones() -> [TodoItem] {
//        var doneItems = [TodoItem]()
//        for item in fileCache.todoItems {
//            if item.done {
//                doneItems.append(item)
//            }
//        }
//        return doneItems
//    }
    @IBAction func showButtonPressed(_ sender: UIButton) {
        if doneFlag {
            sender.setTitle("Показать", for: .normal)
//            for index in 0..<formDones().count {
//                print("here")
//                if fileCache.todoItems[index].done {
//                    continue
//                } else {
//                    self.itemsTableView.beginUpdates()
//                    self.itemsTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
//                    self.itemsTableView.endUpdates()
//                }
//            }
                doneFlag = false
        } else {
            sender.setTitle("Скрыть", for: .normal)
//            for index in 0..<fileCache.todoItems.count {
//                if fileCache.todoItems[index].done {
//                    continue
//                } else {
//                    self.itemsTableView.beginUpdates()
//                    self.itemsTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
//                    self.itemsTableView.endUpdates()
//                }
//            }
            doneFlag = true
        }
    }
    @IBOutlet weak var doneLabel: UILabel!
    @IBOutlet weak var showButton: UIButton!
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet var itemsTableView: UITableView!
    override func viewDidLoad() {
        do {
//            try fileCache.loadData("json", "todoItemsData")
            try fileCache.loadItemsFromCD()
        } catch {
            print("ошибка загрузки дел")
        }
        navigationController?.navigationBar.layoutMargins = UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 0)
        doneLabel.text = "Выполнено: "+String(doneCount)
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
            itemTrasfer = nil
        } else {
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
        //        if doneFlag {
        //            return formDones().count
        //        } else {
        //            return fileCache.todoItems.count
        //        }
        return fileCache.itemsCD.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable:next force_cast
        //        var item: TodoItem
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableItem", for: indexPath) as! ItemCell
        let itemCD = fileCache.itemsCD[indexPath.row]
        if let item = TodoItem.parseCD(coreData: itemCD) {
            //            if doneFlag {
            //                item = fileCache.todoItems[indexPath.row]
            //            } else {
            //                let todos = formDones()
            //                item = todos[indexPath.row]
            //            }
            cell.itemText.setTitle(item.text, for: .normal)
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
                cell.itemText.setImage(#imageLiteral(resourceName: "Major Priority"), for: .normal)
                cell.dealineImage.setImage(#imageLiteral(resourceName: "High Priority"), for: .normal)
            } else {
                cell.dealineImage.setImage(#imageLiteral(resourceName: "Common Priority"), for: .normal)
                cell.itemText.setImage(nil, for: .normal)
                if item.priority.rawValue == "неважная" {
                    cell.itemText.setImage(#imageLiteral(resourceName: "Minor Priority"), for: .normal)
                }
            }
            if item.done {
                if indexPath.row == 0 {
                    doneCount = 0
                }
                doneCount += 1
                doneLabel.text = "Выполнено: "+String(doneCount)
                cell.itemText.setImage(nil, for: .normal)
                cell.dealineImage.setImage(#imageLiteral(resourceName: "Done"), for: .normal)
                cell.dataDisplay.isHidden = true
                cell.itemText.setTitleColor(.lightGray, for: .normal)
                let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: item.text, attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
                attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
                cell.itemText.setAttributedTitle(attributeString, for: .normal)
            } else {
                cell.itemText.setTitleColor(.black, for: .normal)
                cell.itemText.setAttributedTitle(.none, for: .normal)
            }
            cell.editAction = { sender in
                self.itemTrasfer = item
                self.performSegue(withIdentifier: "itemViewSegue", sender: self)
            }
            cell.doneAction = { sender in
                if item.done {
                    self.makeItemUnDone(indexPath)
                } else {
                    self.makeItemDone(indexPath)
                }
            }
        }
        return cell

    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if fileCache.itemsCD[indexPath.row].done {
            doneCount -= 1
            doneLabel.text = "Выполнено: "+String(doneCount)
        }
        let delete = UIContextualAction(style: .destructive, title: nil ) { _, _, completion in
            //            let id = self.fileCache.todoItems[indexPath.row].id
            let id = self.fileCache.itemsCD[indexPath.row].id
            //            self.fileCache.deleteItem(id: id)
            self.fileCache.deleteItemFromCD(idToDelete: id!)
            //            self.fileCache.saveData("json", "todoItemsData")
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
        //        if fileCache.todoItems[indexPath.row].done {
        if fileCache.itemsCD[indexPath.row].done {
            
            let unDone = UIContextualAction(style: .normal, title: nil ) { _, _, completion in
                self.makeItemUnDone(indexPath)
                completion(true)
            }
            unDone.image = UIImage(systemName: "circle")
            unDone.backgroundColor = .clear
            let swipe = UISwipeActionsConfiguration(actions: [unDone])
            return swipe
        } else {
            let done = UIContextualAction(style: .normal, title: nil ) { _, _, completion in
                self.makeItemDone(indexPath)
                completion(true)
            }
            done.image = UIImage(systemName: "checkmark.circle.fill")
            done.backgroundColor = .systemGreen
            let swipe = UISwipeActionsConfiguration(actions: [done])
            return swipe
        }
    }
    func makeItemUnDone(_ index: (IndexPath)) {
        //            let item = self.fileCache.todoItems[index.row]
        let itemCD = self.fileCache.itemsCD[index.row]
        if let item = TodoItem.parseCD(coreData: itemCD) {
            let newItem = TodoItem(id: item.id ,text: item.text, priority: item.priority, deadline: item.deadline, done: false, whenCreated: item.whenCreated, whenEdited: item.whenEdited)
            //                self.fileCache.addItem(newItem: newItem)
            self.fileCache.insertItemToCD(iremToInsert: newItem)
            //            self.fileCache.saveData("json", "todoItemsData")
//            self.fileCache.saveItemsToCoreData()
            self.itemsTableView.reloadRows(at: [index], with: .automatic)
            doneCount -= 1
            doneLabel.text = "Выполнено: "+String(doneCount)
        }
    }
    func makeItemDone(_ index: (IndexPath)) {
        //            let item = self.fileCache.todoItems[index.row]
        let itemCD = self.fileCache.itemsCD[index.row]
        if let item = TodoItem.parseCD(coreData: itemCD) {
            let newItem = TodoItem(id: item.id ,text: item.text, priority: item.priority, deadline: item.deadline, done: true, whenCreated: item.whenCreated, whenEdited: item.whenEdited)
            //            self.fileCache.addItem(newItem: newItem)
            self.fileCache.insertItemToCD(iremToInsert: newItem)
//            doneCount += 1
//            doneLabel.text = "Выполнено: "+String(doneCount)

//            self.fileCache.saveItemsToCoreData()
            //            self.fileCache.saveData("json", "todoItemsData")
            self.itemsTableView.reloadRows(at: [index], with: .automatic)
        }
        
    }
    
    
    
}
