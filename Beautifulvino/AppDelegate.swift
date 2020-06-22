//
//  AppDelegate.swift
//  Beautifulvino
//
//  Created by Antonio Laudazi on 26/10/17.
//  Copyright © 2017 Maria Tourbanova. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import GoogleSignIn
import AWSCognitoIdentityProvider
import AWSSNS
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate{
    
    var window: UIWindow?
    static let dbManager = DBManager()
    var rememberDeviceCompletionSource: AWSTaskCompletionSource<NSNumber>?
    var loginController:LoginViewController!
    var navigationController: UINavigationController?
    let SNSPlatformApplicationArn = "arn:aws:sns:eu-central-1:801532940274:app/APNS/BeautifulVinoIos"//production
   // let SNSPlatformApplicationArn = "arn:aws:sns:eu-central-1:801532940274:app/APNS_SANDBOX/BeautifulVino"//sviluppo

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
     /*   for family: String in UIFont.familyNames
        {
            print("\(family)")
            for names: String in UIFont.fontNames(forFamilyName: family)
            {
                print("== \(names)")
            }
        }*/
        UIApplication.shared.applicationIconBadgeNumber = 0
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
            let googleInfo = NSDictionary(contentsOfFile: path),
            let clientId = googleInfo["CLIENT_ID"] as? String {
            GIDSignIn.sharedInstance().clientID = clientId
        }
        GIDSignIn.sharedInstance().delegate = self
        
        AWSDDLog.sharedInstance.logLevel = .verbose
        
        let serviceConfiguration = AWSServiceConfiguration(region: CognitoIdentityUserPoolRegion, credentialsProvider: nil)
        let poolConfiguration = AWSCognitoIdentityUserPoolConfiguration(clientId: CognitoIdentityUserPoolAppClientId,
                                                                        clientSecret: CognitoIdentityUserPoolAppClientSecret,
                                                                        poolId: CognitoIdentityUserPoolId)
        AWSCognitoIdentityUserPool.register(with: serviceConfiguration, userPoolConfiguration: poolConfiguration, forKey: AWSCognitoUserPoolsSignInProviderKey)
        
        let pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
        pool.delegate = self
        
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.EUCentral1,
                                                                identityPoolId:CognitoIdentityPoolId)
        let configuration = AWSServiceConfiguration(region:.EUCentral1, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        let notificationTypes: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound]
        let pushNotificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
        application.registerUserNotificationSettings(pushNotificationSettings)
        application.registerForRemoteNotifications()
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString:String=deviceToken.base64EncodedString()
     //   print("deviceTokenString: ", deviceTokenString)
        UserDefaults.standard.set(deviceTokenString, forKey: "deviceToken")
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        let sns = AWSSNS.default()
        let request = AWSSNSCreatePlatformEndpointInput()!
        request.platformApplicationArn = SNSPlatformApplicationArn
        request.token = token
        sns.createPlatformEndpoint(request).continueWith(executor: AWSExecutor.mainThread(), block: { (task: AWSTask!) -> AnyObject! in
            if task.error != nil {
            //    print("Error: \(task.error)")
            } else {
                let createEndpointResponse = task.result as! AWSSNSCreateEndpointResponse
            //    print("endpointArn: \(createEndpointResponse.endpointArn)")
                UserDefaults.standard.set(createEndpointResponse.endpointArn, forKey: "endpointArn")
            }
            
            return nil
        })
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Errore durante la registrazione. Error: %@", error)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
    }
    
    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    public func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool
    {
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: "ToggleAuthUINotification"), object: nil, userInfo: nil)
        } else {
            // Perform any operations on signed in user here.
            // let userId = user.userID                  // For client-side use only!
            //  let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
            // let givenName = user.profile.givenName
            // let familyName = user.profile.familyName
            // let email = user.profile.email
            // [START_EXCLUDE]
            
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: "ToggleAuthUINotification"),
                object: user,
                userInfo: ["statusText": "Signed in user:\n\(fullName ?? "")"])
            // [END_EXCLUDE]
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // [START_EXCLUDE]
        NotificationCenter.default.post(
            name: Notification.Name(rawValue: "ToggleAuthUINotification"),
            object: nil,
            userInfo: ["statusText": "User has disconnected."])
        // [END_EXCLUDE]
    }
    // [END disconnect_handler]
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}


// MARK:- AWSCognitoIdentityInteractiveAuthenticationDelegate protocol delegate

extension AppDelegate: AWSCognitoIdentityInteractiveAuthenticationDelegate {
    //il codice commentato è preso dal esempio di aws
    func startPasswordAuthentication() -> AWSCognitoIdentityPasswordAuthentication {
        //  if (navigationController == nil) {
        navigationController = UIStoryboard (name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "FirstViewController") as? UINavigationController
        //  }
        
        //if (loginController == nil) {
        loginController=UIStoryboard (name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        // }
        
        DispatchQueue.main.async {
            self.navigationController!.popToRootViewController(animated: true)
            if (!self.navigationController!.isViewLoaded
                || self.navigationController!.view.window == nil) {
                UIApplication.shared.keyWindow?.rootViewController = self.navigationController
                
                //   self.window?.rootViewController?.present(self.navigationController!, animated: true, completion: nil)
            }
        }
        
        return self.loginController
    }
    
}

