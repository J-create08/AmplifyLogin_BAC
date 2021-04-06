//
//  BACLogin_JCRBApp.swift
//  BACLogin_JCRB
//
//  Created by Juan Carlos  Rojas on 1/4/21.
//

import SwiftUI
import Amplify
import AmplifyPlugins

@main
struct BACLogin_JCRBApp: App {
    init () {
        configureAmplify()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    private func configureAmplify(){
            do {
                Amplify.Logging.logLevel = .verbose
                try Amplify.add(plugin: AWSCognitoAuthPlugin())
                try Amplify.configure()
                
                print("Amplify configured with auth plugin")
            } catch {
                print("An error occurred setting up Amplify: \(error)")
            }
        }
}
