import Foundation
import CoreData

public class Medicine: NSManagedObject {

    @NSManaged public var name: String
    @NSManaged public var isCurrent: Bool
    @NSManaged public var registries: NSSet
    @NSManaged public var internalInterval: Int64
    @NSManaged public var notificationTime: NSDate?
}
