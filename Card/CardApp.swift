import SwiftUI
import FirebaseCore
import FirebaseMessaging
import AdjustSdk
import AppTrackingTransparency
import AdSupport

@main
struct CardApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var cardMenuModel: CardMenuViewModel {
        CardMenuViewModel(adjustHandler: appDelegate.adjustHandler)
    }

    var body: some Scene {
        WindowGroup {
            CardMenuView()
                .environmentObject(cardMenuModel)
                .onAppear {
                    UserDefaultsManager().firstLaunch()
                    requestTrackingPermission { granted in
                        
                        let config = ADJConfig(appToken: "ao2v06it4ruo", environment: ADJEnvironmentSandbox)
                        config?.delegate = appDelegate.adjustHandler
                        Adjust.initSdk(config)
                        
                        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in
                            DispatchQueue.main.async {
                                UIApplication.shared.registerForRemoteNotifications()
                            }
                        }
                        
                        if granted {
                            Task {
                                UserDefaultsManager.isFirstLaunch = false
                                
                            }
                        }
                    }
                }
        }
    }

    func requestTrackingPermission(completion: @escaping (Bool) -> Void) {
        if #available(iOS 14, *) {
            let status = ATTrackingManager.trackingAuthorizationStatus
            switch status {
            case .notDetermined:
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    ATTrackingManager.requestTrackingAuthorization { status in
                        print("ATT callback called, status: \(status.rawValue)")
                        DispatchQueue.main.async {
                            appDelegate.handleTrackingAuthorizationStatus(status)
                            completion(status == .authorized)
                        }
                    }
                }
            case .authorized:
                appDelegate.handleTrackingAuthorizationStatus(status)
                completion(true)
            default:
                appDelegate.handleTrackingAuthorizationStatus(status)
                completion(false)
            }
        } else {
            completion(true)
        }
    }
}


class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate  {
    static var orientationLock = UIInterfaceOrientationMask.all
    let adjustHandler = AdjustHandler()

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .banner])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        UNUserNotificationCenter.current().delegate = self
        
        Messaging.messaging().delegate = self
        Messaging.messaging().isAutoInitEnabled = true
    
        
        return true
    }
    
  
    
    func handleTrackingAuthorizationStatus(_ status: ATTrackingManager.AuthorizationStatus) {
        switch status {
        case .authorized:
            let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
            UserDefaults.standard.set(idfa, forKey: "idfa")
            NotificationCenter.default.post(name: NSNotification.Name("idfaReceivedPublisher"), object: nil)
        case .denied, .restricted, .notDetermined:
            UserDefaults.standard.removeObject(forKey: "idfa")
        @unknown default:
            break
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Ошибка получения FCM токена: \(error.localizedDescription)")
            } else if let token = token {
                print("Обновлённый FCM токен: \(token)")
            }
        }
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken)) 8989")
        
        if let fcmToken {
            UserDefaults.standard.set(fcmToken, forKey: "fcmToken")
        } else {
            UserDefaults.standard.set("null", forKey: "fcmToken")
        }
        NotificationCenter.default.post(Notification(name: NSNotification.Name("tokenReceivedPublisher"), object: nil))
    }
}


struct OrientationLockModifier: ViewModifier {
    let orientation: UIInterfaceOrientationMask

    func body(content: Content) -> some View {
        content
            .onAppear {
                AppDelegate.orientationLock = orientation
                UIDevice.current.setValue(UIInterfaceOrientation.unknown.rawValue, forKey: "orientation")
                if orientation.contains(.portrait) {
                    UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                } else if orientation.contains(.landscapeLeft) {
                    UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
                }
            }
            .onDisappear {
                AppDelegate.orientationLock = .landscape
                UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
            }
    }
}

extension View {
    func orientationLock(_ orientation: UIInterfaceOrientationMask) -> some View {
        self.modifier(OrientationLockModifier(orientation: orientation))
    }
}
