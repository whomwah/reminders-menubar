import EventKit
import ServiceManagement

private struct PreferencesKeys {
    static let calendarIdentifiersFilter = "calendarIdentifiersFilter"
    static let calendarIdentifierForSaving = "calendarIdentifierForSaving"
    static let showUncompletedOnly = "showUncompletedOnly"
    static let backgroundIsTransparent = "backgroundIsTransparent"
    static let showUpcomingReminders = "showUpcomingReminders"
    static let upcomingRemindersInterval = "upcomingRemindersInterval"
    static let showMenuBarTodayCount = "showMenuBarTodayCount"
    static let preferredLanguage = "preferredLanguage"
}

class UserPreferences: ObservableObject {
    static let instance = UserPreferences()
    
    private init() {
        // This prevents others from using the default '()' initializer for this class.
    }
    
    private static let defaults = UserDefaults.standard
    
    @Published var calendarIdentifiersFilter: [String] = {
        guard let identifiers = defaults.stringArray(forKey: PreferencesKeys.calendarIdentifiersFilter) else {
            return []
        }
        
        return identifiers
    }() {
        didSet {
            UserPreferences.defaults.set(calendarIdentifiersFilter, forKey: PreferencesKeys.calendarIdentifiersFilter)
        }
    }
    
    @Published var calendarForSaving: EKCalendar = {
        guard let identifier = defaults.string(forKey: PreferencesKeys.calendarIdentifierForSaving),
              let calendar = RemindersService.instance.getCalendar(withIdentifier: identifier) else {
            // TODO: Find a way to load this property only when the authorization status is authorized
            guard RemindersService.instance.authorizationStatus() == .authorized else {
                return EKCalendar()
            }
            let defaultCalendar = RemindersService.instance.getDefaultCalendar()
            return defaultCalendar
        }
        
        return calendar
    }() {
        didSet {
            let identifier = calendarForSaving.calendarIdentifier
            UserPreferences.defaults.set(identifier, forKey: PreferencesKeys.calendarIdentifierForSaving)
        }
    }
    
    @Published var showUncompletedOnly: Bool = {
        guard defaults.object(forKey: PreferencesKeys.showUncompletedOnly) != nil else {
            return true
        }
        
        return defaults.bool(forKey: PreferencesKeys.showUncompletedOnly)
    }() {
        didSet {
            UserPreferences.defaults.set(showUncompletedOnly, forKey: PreferencesKeys.showUncompletedOnly)
        }
    }
    
    @Published var upcomingRemindersInterval: ReminderInterval = {
        guard let intervalData = defaults.data(forKey: PreferencesKeys.upcomingRemindersInterval),
              let interval = try? JSONDecoder().decode(ReminderInterval.self, from: intervalData) else {
            return .today
        }
        return interval
    }() {
        didSet {
            let intervalData = try? JSONEncoder().encode(upcomingRemindersInterval)
            UserPreferences.defaults.set(intervalData, forKey: PreferencesKeys.upcomingRemindersInterval)
        }
    }
    
    @Published var showUpcomingReminders: Bool = {
        guard defaults.object(forKey: PreferencesKeys.showUpcomingReminders) != nil else {
            return true
        }
        return UserDefaults.standard.bool(forKey: PreferencesKeys.showUpcomingReminders)
    }() {
        didSet {
            UserPreferences.defaults.set(showUpcomingReminders, forKey: PreferencesKeys.showUpcomingReminders)
        }
    }
    
    var launchAtLoginIsEnabled: Bool {
        get {
            let allJobs = SMCopyAllJobDictionaries(kSMDomainUserLaunchd).takeRetainedValue() as? [[String: AnyObject]]
            let launcherJob = allJobs?.first { $0["Label"] as? String == AppConstants.launcherBundleId }
            return launcherJob?["OnDemand"] as? Bool ?? false
        }
        
        set {
            SMLoginItemSetEnabled(AppConstants.launcherBundleId as CFString, newValue)
        }
    }
    
    @Published var backgroundIsTransparent: Bool = {
        guard UserDefaults.standard.object(forKey: PreferencesKeys.backgroundIsTransparent) != nil else {
            return true
        }
        return UserDefaults.standard.bool(forKey: PreferencesKeys.backgroundIsTransparent)
    }() {
        didSet {
            UserPreferences.defaults.set(backgroundIsTransparent, forKey: PreferencesKeys.backgroundIsTransparent)
        }
    }
    
    @Published var showMenuBarTodayCount: Bool = {
        guard UserDefaults.standard.object(forKey: PreferencesKeys.showMenuBarTodayCount) != nil else {
            return true
        }
        return UserDefaults.standard.bool(forKey: PreferencesKeys.showMenuBarTodayCount)
    }() {
        didSet {
            UserPreferences.defaults.set(showMenuBarTodayCount, forKey: PreferencesKeys.showMenuBarTodayCount)
        }
    }
    
    @Published var preferredLanguage: String? = {
        return UserDefaults.standard.string(forKey: PreferencesKeys.preferredLanguage)
    }() {
        didSet {
            UserPreferences.defaults.set(preferredLanguage, forKey: PreferencesKeys.preferredLanguage)
        }
    }
}
