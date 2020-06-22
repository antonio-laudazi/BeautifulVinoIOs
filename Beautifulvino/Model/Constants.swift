//
//  Constants.swift
//  Beautifulvino
//
//  Created by Antonio Laudazi on 26/10/17.
//  Copyright © 2017 Maria Tourbanova. All rights reserved.
//

import Foundation
import AWSCognitoIdentityProvider

let CognitoIdentityUserPoolRegion: AWSRegionType = .EUCentral1
let CognitoIdentityUserPoolId = "eu-central-1_KzlMv3BwL"
let CognitoIdentityUserPoolAppClientId = "1310co5imocvhr9j07nuadfk0u"
let CognitoIdentityUserPoolAppClientSecret = "j76iq03qka1e9st175dfi00kfe66po9hfov7dt72vgcp5fo713h"
let CognitoIdentityPoolId = "eu-central-1:37e7c364-4fe4-4e52-9022-1e78feda7843"

let AWSCognitoUserPoolsSignInProviderKey = "UserPool"
let dataSetName = "pippo"
let htmlTextStyle="<style>body{font-family: 'Inter UI'; font-size:16px; color:#6A6464;  line-height: 170%;}</style>"//letter-spacing: 2px;
let htmlTextStyleFeedPost="<style>body{font-family: 'Inter UI'; font-size:14px; color:#ffffff;}</style>"//letter-spacing: 2px;

/*facebook app:
 ID APP: 435127290214918
 Chiave Segreta: 894ddb50f9ee37daaf4908af439127e9*/


enum Tipo: Int {
    case registrazione=1, accesso
}

enum RequestTypeList: Int {
    case refresh = 1, more
}

enum RequestType: Int {
    case request_get_eventi = 1, request_get_province, request_get_feed, request_login, request_get_evento, request_change_stato_evento, request_change_stato_utente, request_get_azienda, request_get_vino, request_change_stato_vino, request_get_utente, request_get_aziende_evento, request_save_utente, request_get_punti
}

class Height {
    
    static let headerView = 46.0
    static let hiddenTitleView = 54.0
    static let vinoTableViewCell = 125.0
    static let eventoTableViewCell = 390.0
    static let badgeTableViewCell = 132.0
    static let tableSectionHeaderAzienda = 79.0
    static let tableSectionFooterVino = 68.0
    static let utenteTableViewCell = 70.0
    static let feedAziendaTableViewCell = 404.0
    static let feedPubblicitaTableViewCell = 303.0
    static let feedAzioneTableViewCell = 374.0
    static let feedPostTableViewCell = 474.0
}

