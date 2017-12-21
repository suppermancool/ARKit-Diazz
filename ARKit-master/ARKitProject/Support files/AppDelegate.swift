import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?
    
    func registerSettingsBundle(){
        guard let settingsBundle = Bundle.main.path(forResource: "Settings", ofType: "bundle") else {
            print("Could not load settings bundle")
            return
        }
        
        guard let settings = NSDictionary(contentsOfFile:(settingsBundle as NSString).appendingPathComponent("Root.plist")) else {
            print("Could not extract Root.plist")
            return
        }
        let preferences = settings["PreferenceSpecifiers"] as! [[String: Any]]
        var defaultsToRegister = [String: Any](minimumCapacity: preferences.count);
        
        for prefSpec in preferences {
            if let key = prefSpec["Key"] as? String {
                let value = prefSpec["DefaultValue"]
                defaultsToRegister[key] = value
                print("Writing as default \(value) to key \(key)")
            }
        }
        
        UserDefaults.standard.register(defaults: defaultsToRegister)
        UserDefaults.standard.synchronize()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        registerSettingsBundle()
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        CoreDataManager.shared.saveContext()
    }
    
}
