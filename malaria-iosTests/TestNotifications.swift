import XCTest
@testable import malaria_ios

class TestNotifications: XCTestCase {
    var m: MedicineManager!
    
    let d1 = NSDate.from(2015, month: 5, day: 8) //monday
    let currentPill = Medicine.Pill.Malarone //dailyPill
    let weeklyPill = Medicine.Pill.Mefloquine //weekly
    
    var mdDaily: Medicine!
    var mdWeekly: Medicine!
    
    var currentContext: NSManagedObjectContext!
    var mdDailyregistriesManager: RegistriesManager!
    var mdWeeklyregistriesManager: RegistriesManager!
    
    var mdDailyNotifManager: MedicineNotificationsManager!
    var mdWeeklyNotifManager: MedicineNotificationsManager!
    
    
    override func setUp() {
        super.setUp()
        
        currentContext = CoreDataHelper.sharedInstance.createBackgroundContext()
        m = MedicineManager(context: currentContext)
        
        m.registerNewMedicine(currentPill.name(), interval: currentPill.interval())
        m.setCurrentPill(currentPill.name())
        m.getCurrentMedicine()!.notificationManager.scheduleNotification(d1)
        
        m.registerNewMedicine(weeklyPill.name(), interval: weeklyPill.interval())
        
        mdDaily = m.getCurrentMedicine()!
        mdWeekly = m.getMedicine(weeklyPill.name())!
        
        mdDailyregistriesManager = mdDaily.registriesManager
        mdWeeklyregistriesManager = mdWeekly.registriesManager
        
        mdDailyNotifManager = mdDaily.notificationManager
        mdWeeklyNotifManager = mdWeekly.notificationManager
        
        XCTAssertTrue(mdDailyregistriesManager.addRegistry(d1, tookMedicine: true).registryAdded)
    }
    
    override func tearDown() {
        super.tearDown()
        m.clearCoreData()
    }
    
    func testReshedule() {
        //reshedule notification
        mdDailyNotifManager.reshedule()
        XCTAssertTrue(mdDaily.notificationTime!.sameDayAs(d1 + 1.day))
        
        //since mdWeekly is not currentPill, this should return nil
        XCTAssertNil(mdWeekly.notificationTime)
        
        //setCurrentPill, current trigger time is not defined yet
        m.setCurrentPill(weeklyPill.name())
        XCTAssertNil(mdWeekly.notificationTime)
        
        //define currentTime
        mdWeeklyNotifManager.scheduleNotification(d1)
        XCTAssertTrue(mdWeekly.notificationTime!.sameDayAs(d1))
        
        //add new entry and reshedule
        XCTAssertTrue(mdWeeklyregistriesManager.addRegistry(d1, tookMedicine: true).registryAdded)
        mdWeeklyNotifManager.reshedule()
        XCTAssertTrue(mdWeekly.notificationTime!.sameDayAs(d1 + 7.day))
    }
  
    // Checks if notifications are created and correctly archived into NSUserDefaults.
    
    func testCreateNotification() {
      
      // Set two notifications
      mdDailyNotifManager.scheduleNotification(NSDate())
      mdWeeklyNotifManager.scheduleNotification(NSDate())
      
      // Check if they were saved in the user defaults
      let localNotificationArrayData = UserSettingsManager.UserSetting.SaveLocalNotifications.getLocalNotifications()
      
      guard let data = localNotificationArrayData else {
        return
      }
      
      let scheduledNotifications = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [UILocalNotification]
      
      guard let notifications = scheduledNotifications else {
        return
      }

      XCTAssert(notifications.count == 1)
    }
  
}
