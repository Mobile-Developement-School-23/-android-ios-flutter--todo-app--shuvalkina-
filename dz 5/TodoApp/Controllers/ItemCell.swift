import UIKit

class ItemCell: UITableViewCell {
    var doneAction: ((Any) -> Void)?
    var editAction: ((Any) -> Void)?
    @IBOutlet weak var dataDisplay: UIButton!
    @IBOutlet weak var dealineImage: UIButton!
    @IBOutlet weak var itemText: UIButton!
    @IBOutlet weak var openTask: UIButton!
    @IBAction func donePressed(_ sender: UIButton) {
        self.doneAction?(sender)
    }
    @IBAction func openTaskPressed(_ sender: UIButton) {
        self.editAction?(sender)
    }
    @IBAction func itemTextPressed(_ sender: UIButton) {
        self.editAction?(sender)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
//        buttonnn.layer.cornerRadius = butonnI.frame.size.height / 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
