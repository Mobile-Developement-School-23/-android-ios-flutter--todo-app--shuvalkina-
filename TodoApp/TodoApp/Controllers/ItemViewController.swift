import UIKit

class ItemViewController: UIViewController, UITextViewDelegate, EditionDelegate {
    func itemToEdit(item: TodoItem) {
        itemToDisplay = item
    }
    
    public var callbackClosure: (() -> Void)?
    override func viewWillDisappear(_ animated: Bool) {
        callbackClosure?()
    }
    var itemToDisplay : TodoItem?
    var delegateee: DismissionDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        if itemToDisplay != nil {
            displayEditItem(item: itemToDisplay!)
            
        }
            wasTouched = false
            itemText.delegate = self
            itemText.contentInset = UIEdgeInsets(top: 8.0, left: 12.0, bottom: 8.0, right: 12.0)
            deadlineSelecor.addTarget(self, action: #selector(pickerHandler), for: .valueChanged)
            deadlineSelecor.minimumDate = Date()
            let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
            view.addGestureRecognizer(tapGesture)
            tapGesture.cancelsTouchesInView = false
            settingsBottomConstraint.constant = 80
            deadlineLabel2.isHidden = true
        
    }
    func displayEditItem (item: TodoItem) {
        wasTouched = false
        itemText.text = item.text
        placeholderText.isHidden = true
        priorityBar.selectedSegmentIndex = 1
        if item.priority.rawValue == "важная" {
            priorityBar.selectedSegmentIndex = 2
        } else {
            if item.priority.rawValue == "неважная" {
                priorityBar.selectedSegmentIndex = 0
            }
        }
        if item.deadline != nil {
            deadlineButton.isHidden = false
            deadlineLabel.textColor = .clear
            deadlineLabel2.isHidden = false
            let date = Int(item.deadline!)
            let dateString = dateForDisplay(date)
            let datePicker = dateForPicker(date)
            deadlineLabel.textColor = .clear
            deadlineButton.isHidden = false
            deadlineButton.setTitle(dateString, for: .normal)
            deadlineLabel2.isHidden = false
            deadlineSwitch.isOn = true
            deadlineSelecor.setDate(datePicker, animated: true)
        } else {
            deadlineSwitch.isOn = false
            deadlineLabel2.isHidden = true
            deadlineLabel.textColor = .black
        }
    }
    // метод позволяет выбрать дату дедлайна на календаре и после выбора даты убирает календарь
    @objc func pickerHandler (_ picker: UIDatePicker) {
        deadlineButton.setTitle(dateConverter(picker.date), for: .normal)
        deadlineSelecor.isHidden = true
        borderLine.isHidden = true
        settingsBottomConstraint.constant = 440
        settingsBottonConstraint2.constant = 16
    }
    // методы редактирования текста задачи
    func textViewDidBeginEditing(_ textView: UITextView) {
        if itemText.isFirstResponder == true {
            wasTouched = true
            placeholderText.isHidden = true
            saveButton.isEnabled = true
            deleteButton.isEnabled = true
       }
   }
    func textViewDidEndEditing(_ textView: UITextView) {
        if itemText.text.isEmpty {
            wasTouched = false
            placeholderText.isHidden = false
            saveButton.isEnabled = false
            deleteButton.isEnabled = false
        }
    }
    @IBAction func priorityGotChanged(_ sender: Any) {
        wasTouched = true
        if itemText.hasText {
            saveButton.isEnabled = true
            deleteButton.isEnabled = true
        }
    }
    // метод показывает календарь при нажатии на дату под лейблом "Сделать до" и убирает календарь при повторном нажатии
    @IBAction func deadlineButton(_ sender: UIButton) {
        sender.isSelected.toggle()
            if sender.isSelected {
                wasTouched = true
                if itemText.hasText {
                    saveButton.isEnabled = true
                    deleteButton.isEnabled = true
                }
                deadlineSelecor.isHidden = false
                borderLine.isHidden = false
                settingsBottonConstraint2.constant = 0
                settingsBottomConstraint.constant = 80
            } else {
                deadlineSelecor.isHidden = true
                borderLine.isHidden = true
                settingsBottomConstraint.constant = 440
                settingsBottonConstraint2.constant = 16
            }
    }
    @IBOutlet weak var deadlineLabel: UILabel!
    @IBOutlet weak var deadlineButton: UIButton!
    @IBOutlet weak var priorityBar: UISegmentedControl!
    @IBOutlet weak var deadlineSwitch: UISwitch!
    @IBOutlet weak var placeholderText: UILabel!
    @IBOutlet weak var itemText: UITextView!
    @IBOutlet weak var deadlineSelecor: UIDatePicker!
    @IBOutlet weak var borderLine: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deadlineLabel2: UILabel!
    @IBOutlet var settingsBottonConstraint2: NSLayoutConstraint!
    @IBOutlet var settingsBottomConstraint: NSLayoutConstraint!
    var wasTouched = false
    
    // метод сохраняет настройки задания на дисплее
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        
        var priority = TodoItem.Priority.common
        switch priorityBar.selectedSegmentIndex {
        case 0:
            priority = .minor
        case 2:
            priority = .major
        default:
               break
           }
        var dateCheck: Int?
        if deadlineSwitch.isOn {
             dateCheck = dateInt(deadlineSelecor.date)
        }
        var newID = UUID().uuidString
        if itemToDisplay != nil {
            newID = itemToDisplay!.id
        }
        let item = TodoItem(
            id: newID,
            text: itemText.text,
            priority: priority,
            deadline: dateCheck,
            done: false,
            whenCreated: dateInt(Date()),
            whenEdited: 0)
        self.delegateee?.addCD(itemToAdd: item)
//        self.delegateee?.saveCD()
//        self.delegateee?.save("json", "todoItemsData")
        self.dismiss(animated: true) {
            
        }
    }
    // методы преобразования формата Date
    func dateInt (_ date: Date ) -> Int {
        let dateComponents = (Calendar.current).dateComponents([.year, .month, .day], from: date)
        let dateInt = Int(dateComponents.year!) * 10000 + Int(dateComponents.month!) * 100 + Int(dateComponents.day!)
        return dateInt
    }
    func dateConverter(_ date: Date) -> String {
        let dateComponents = (Calendar.current).dateComponents([.year, .month, .day], from: date)
        let monthString = DateFormatter().monthSymbols[dateComponents.month! - 1]
        let deadlineString = String(dateComponents.day!) + " " + monthString + " " + String(dateComponents.year!)
        return deadlineString
    }
        func dateForDisplay (_ date: Int) -> String {
            if date == 0 {return ""}
            let year = date/10000
            let month = date/100 - year*100
            let day = date - year*10000 - month*100
            let deadlineString = String(day) + " " + DateFormatter().monthSymbols[month] + " " + String(year)
            return deadlineString
    }
    func dateForPicker(_ date: Int) -> Date {
        let year = date/10000
        let month = date/100 - year*100
        let day = date - year*10000 - month*100
        let deadlineString = String(year) + "-" + String(month) + "-" + String(day)
        let strategy = Date.ParseStrategy(format: "\(year: .defaultDigits)-\(month: .twoDigits)-\(day: .twoDigits)T\(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .zeroBased)):\(minute: .twoDigits):\(second: .twoDigits)\(timeZone: .iso8601(.short))", timeZone: .current)
        let dateSample = deadlineString+"T 19:31:00 +0000"
        let dateFormated = try? Date(dateSample, strategy: strategy)
        return dateFormated ?? Date()
    }
    // метод возвращает к начальным измененные экранные значения
    func defaultScreen() {
        itemText.text = ""
        priorityBar.selectedSegmentIndex = 1
        deadlineSwitch.isOn = false
        placeholderText.isHidden = false
        saveButton.isEnabled = false
        deleteButton.isEnabled = false
        deadlineSelecor.date = Date()
        deadlineLabel2.isHidden = true
        deadlineButton.isHidden = true
        deadlineLabel.textColor = .black
        deadlineSelecor.isHidden = true
        borderLine.isHidden = true
        settingsBottomConstraint.constant = 440
        settingsBottonConstraint2.constant = 16
    }
    // метод добавляет дату - кнопку под лейблом "Сделать до" и скрывает календарь при выключении
    @IBAction func deadlineButtonPressed(_ sender: UISwitch) {
        if itemText.hasText {
            saveButton.isEnabled = true
            deleteButton.isEnabled = true
        }
        if sender.isOn {
            deadlineButton.isHidden = false
            deadlineLabel.textColor = .clear
            deadlineLabel2.isHidden = false
            let defaultDate = dateConverter(Date())
            let day = Int(defaultDate.prefix(2))
            deadlineButton.setTitle(((String((day ?? 0) + 1)+defaultDate.dropFirst(2))), for: .normal)
        } else {
            deadlineSelecor.date = Date()
            deadlineLabel2.isHidden = true
            deadlineButton.isHidden = true
            deadlineLabel.textColor = .black
            deadlineSelecor.isHidden = true
            borderLine.isHidden = true
            settingsBottomConstraint.constant = 440
            settingsBottonConstraint2.constant = 16
        }
    }
    // метод отменяет несохареннные все изменения проведенные пользователем после загруз задания/сохранения
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        if wasTouched {
            if itemToDisplay == nil {
                defaultScreen()
                wasTouched = false
            } else {
                displayEditItem(item: itemToDisplay!)
            }
        } else {
            self.dismiss(animated: true) {
                self.itemToDisplay = nil
            }
        }
    }
    // метод удаляет задание
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
//        self.delegateee?.save("json", "todoItemsData")
        self.delegateee?.saveCD()
        self.dismiss(animated: true) {
            self.itemToDisplay = nil
        }
    }
}
