//
//  ContentView.swift
//  BACLogin_JCRB
//
//  Created by Juan Carlos  Rojas on 1/4/21.
//

import SwiftUI
import Amplify
import SCLAlertView
import Foundation

class ContentViewModel: ObservableObject {
    @Published var logged = false
    
    func isLogged()->Bool{
        return logged
    }
}

struct ContentView: View {
    @State private var username = ""
    @State private var password = ""
    @StateObject var contentVM = ContentViewModel()
    @State private var isActive = true
    @State private var timeRemaining = 30
    @State private var token = ""
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView{
            if contentVM.isLogged() {
                VStack{
                    Text("\(timeRemaining)")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            Capsule()
                                .fill(Color.red)
                                .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                        )
                    Text("Tu token es: " + token)
                        .toolbar {
                                            Button("LogOut") {
                                                self.logOut()
                                            }
                                        }
                }
                
            } else {
                VStack (spacing: 20) {
                    Text("¡Bienvenido!").foregroundColor(.blue).bold().font(.title)
                    Group {
                        VStack (alignment: .center, spacing: 15){
                            TextField("Username", text: $username)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 2))
                            SecureField("Password", text: $password)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 2))
                        }.padding().frame(width: 350, height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    }.font(Font.system(size: 20))
                    .foregroundColor(.black)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(.leading)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    
                    Button(action: signIn){
                        HStack(alignment: .center){
                            Spacer()
                            Text("Sign In").foregroundColor(.white)
                            Spacer()
                        }
                    }.padding().background(Color.orange).frame(width: 350, height: 50, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    HStack {
                        Text("New?")
                        NavigationLink(destination: SignUpView()) {
                            Text("Create an account").font(.system(size:18, weight: .medium ))
                                .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                        }
                    }
                }.onAppear { self.fetchCurrentAuthSession() }
                .environmentObject(self.contentVM)
                
            }
            
        }
        .onReceive(timer) { time in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.logOut()
            }
        }
    }
    
    func random6DigitString() -> String {
        let min: UInt32 = 100_000
        let max: UInt32 = 999_999
        let i = min + arc4random_uniform(max - min + 1)
        return String(i)
    }
    
    func signIn() {
            Amplify.Auth.signIn(username: username, password: password) { result in
                switch result {
                
                case .success:
                    print("\(username) signed in")
                    token = random6DigitString()
                    timeRemaining = 30
                    DispatchQueue.main.async {
                        self.contentVM.logged = true
                        print("Login In")
                    }
                    
                case .failure(let error):
                    print(error)
                    DispatchQueue.main.async {
                        SCLAlertView().showError("Error", subTitle: error.errorDescription) // Error
                    }
                }
            }
                
            }
    func fetchCurrentAuthSession() {
            Amplify.Auth.fetchAuthSession { result in
                switch result {
                case .success(let session):
                    print("Is user signed in - \(session.isSignedIn)")
                    
                    if session.isSignedIn {
                        self.contentVM.logged = true
                    }
                    
                case .failure(let error):
                    print("Fetch session failed with error \(error)")
                }
            }
        }
        
        func logOut(){
                Amplify.Auth.signOut() { result in
                    switch result {
                    case .success:
                        print("Successfully signed out")
                        self.contentVM.logged = false
                    case .failure(let error):
                        print("Sign out failed with error \(error)")
                        self.contentVM.logged = true
                    }
                }
            }
    
}
    


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
