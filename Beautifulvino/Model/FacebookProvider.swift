//
//  FacebookProvider.swift
//  Beautifulvino
//
//  Created by Antonio Laudazi on 02/02/18.
//  Copyright © 2018 Maria Tourbanova. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider
import FacebookCore

class FacebookProvider: NSObject, AWSIdentityProviderManager {
    
    
    func logins() -> AWSTask<NSDictionary> {
        if let token = AccessToken.current?.authenticationToken {
            return AWSTask(result: [AWSIdentityProviderFacebook:token])
        }else{
        }
        return AWSTask(error:NSError(domain: "Facebook Login", code: -1 , userInfo: ["Facebook" : "No current Facebook access token"]))
    }
} 
