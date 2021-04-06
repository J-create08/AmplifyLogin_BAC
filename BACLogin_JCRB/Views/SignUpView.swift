//
//  SignUpView.swift
//  BACLogin_JCRB
//
//  Created by Juan Carlos  Rojas on 1/4/21.
//

import SwiftUI
import Amplify
import SCLAlertView

struct SignUpView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var email = ""
    var body: some View {
        VStack (spacing: 40) {
            Text("Crear cuenta").foregroundColor(.blue).bold().font(.title)
            Group {
                VStack (alignment: .center, spacing: 15){
                    TextField("Username", text: $username)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 2))
                    TextField("Email", text: $email)
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
            
            Button(action: signUp){
                HStack(alignment: .center){
                    Spacer()
                    Text("Sign Up").foregroundColor(.white)
                    Spacer()
                }
            }.padding().background(Color.orange).frame(width: 350, height: 50, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        }
    }
    func signUp() {
           let userAttributes = [AuthUserAttribute(.email, value: email)]
           let options = AuthSignUpRequest.Options(userAttributes: userAttributes)
           
           Amplify.Auth.signUp(
               username: username,
               password: password,
               options: options
           ) { result in
               switch result {
               case .success(let signUpResult):
                   
                   switch signUpResult.nextStep {
                   case .confirmUser(let details, let info):
                       print(details ?? "no details", info ?? "no additional info")
                       
                       DispatchQueue.main.async {
                        
                           let alert = SCLAlertView(
                           )
                           let txt = alert.addTextField("Enter confirm number")
                           alert.addButton("Confirm") {
                               confirmSignUp(emailCode: txt.text!)
                               print("Facilitar Codigo")
                           }
                           alert.showEdit("SMS", subTitle: "Enter the code received in your email", closeButtonTitle: "Cancel")
                       }
                       
                   case .done:
                       print("Sign up complete")
                   }
                   
               case .failure(let error):
                   print(error)
                   DispatchQueue.main.async {
                       SCLAlertView().showError("Error", subTitle: error.errorDescription) // Error
                   }

               }
           }
       }
       func confirmSignUp(emailCode: String) {
           Amplify.Auth.confirmSignUp(for: username, confirmationCode: emailCode) { result in
               
               switch result {
               
               case .success(let confirmSignUpResult):
                   
                   switch confirmSignUpResult.nextStep {
                   case .confirmUser(let details, let info):
                       print(details ?? "no details", info ?? "no additional info")
                       
                       
                   case .done:
                       print("\(username) confirmed their email")
                       username = ""
                       password = ""
                       email = ""
                       DispatchQueue.main.async {
                           SCLAlertView().showInfo("Success", subTitle: "Email Confirmed") // Info
                       }
                   
                   }
                   
               case .failure(let error):
                   print(error)
                   DispatchQueue.main.async {
                       SCLAlertView().showError("Error", subTitle: error.errorDescription) // Error
                   }
                   
               }
               
           }
       }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
