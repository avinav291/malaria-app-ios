import Foundation
import UIKit

class StateCell: UITableViewCell{
    @IBOutlet weak var statIcon: UIImageView!
    @IBOutlet weak var statLbl: UILabel!
    @IBOutlet weak var statValueLbl: UILabel!
}

protocol Stat{
    var title : String { get }
    var image : UIImage { get }
    var attributeValue : String { get }
}

class Adherence : Stat{
    var title : String { return "Adherence to medicine" }
    var image : UIImage { return UIImage(named: "Adherence")! }
    var attributeValue : String {
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = NSNumberFormatterStyle.PercentStyle
        numberFormatter.maximumFractionDigits = 0
        numberFormatter.multiplier = 1
        
        return numberFormatter.stringFromNumber(CachedStatistics.sharedInstance.todaysAdherence)!
    }
}

class PillStreak : Stat{
    var title : String { return "Doses in a Row" }
    var image : UIImage { return UIImage(named: "DosesInRow")! }
    var attributeValue : String { return "\(CachedStatistics.sharedInstance.todaysPillStreak)"}
}

class MedicineLastTaken : Stat{
    var title : String { return "Medicine Last Take" }
    var image : UIImage { return UIImage(named: "MedicineLastTaken")! }
    var attributeValue : String {
        if let last = CachedStatistics.sharedInstance.lastMedicine {
            return last.formatWith("d/M")
        }
        return  "-/-"
    }
}