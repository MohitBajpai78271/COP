//
//  AuthService.swift
//  ConstableOnPatrol
//
//  Created by Mac on 15/07/24.
//

import UIKit
import Alamofire

class AuthService{
    
    static let shared = AuthService()
    let baseURL = "http://93.127.172.217:4000"
    
    public let userDefaults = UserDefaults.standard
     public let signedInKey = "isSignedIn"
     
     public init() {}
     
     var isSignedIn: Bool {
         get {
             return userDefaults.bool(forKey: signedInKey)
         }
         set {
             userDefaults.set(newValue, forKey: signedInKey)
         }
     }
    
    func getOTP(phoneNumber: String,completion: @escaping(OTPResponse?, Error?)->Void){
        let urlString = "http://93.127.172.217:4000/api/send-otp"
        
        let parameters: [String: Any] = ["phoneNumber": phoneNumber]
        
        AF.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseDecodable(of: OTPResponse.self) { response in
                if let data = response.data {
                    print("Raw Response Data: \(String(data: data, encoding: .utf8) ?? "No Data")")
                    do {
                        let otpResponse = try JSONDecoder().decode(OTPResponse.self, from: data)
                        completion(otpResponse, nil)
                    } catch let decodeError {
                        print("Decoding Error: \(decodeError)")
                        completion(nil, decodeError)
                    }
                } else {
                    print("No data in response")
                    completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data in response"]))
                }
            }
    }
    func callGetOTP(context: UIViewController, phoneNumber: String) {
        getOTP(phoneNumber: phoneNumber) { otpResponse, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                // showSnackBar(context, 'Failed to generate OTP')
                // You can implement the showSnackBar function in Swift to display the error message
                return
            }
        }
    }
    
    func verifyOTP(phoneNumber: String, otp: String, completion: @escaping (VerifyOTPResponse?, Error?) -> Void) {
        let url = "\(baseURL)/api/verify-otp"
        let parameters: [String: Any] = ["phoneNumber": phoneNumber, "otp": otp]
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseDecodable(of: VerifyOTPResponse.self) { response in
                switch response.result {
                case .success(let verifyOTPResponse):
                    completion(verifyOTPResponse, nil)
                case .failure(let error):
                    completion(nil, error)
                }
            }
    }
    func existingUser(phoneNumber: String, otp: String, completion: @escaping (OTPResponse?, Error?) -> Void) {
        let url = URL(string: "\(baseURL)/api/verify-otp-signIn")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: String] = ["phoneNumber": phoneNumber, "otp": otp]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data in response"]))
                return
            }
            
            do {
                let otpResponse = try JSONDecoder().decode(OTPResponse.self, from: data)
                completion(otpResponse, nil)
            } catch {
                completion(nil, error)
            }
        }
        
        task.resume()
    }
    
    
    func logOut(phoneNumber: String, context: UIViewController) {
        let alertController = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) {  _ in
            // Logout implementation
            guard let url = URL(string: "http://93.127.172.217:4000/api/logout") else {
                print("Invalid URL")
                return
            }
            
            var request = URLRequest(url: url, cachePolicy:.useProtocolCachePolicy)
            request.httpMethod = "POST"
            request.httpBody = try? JSONEncoder().encode(["phoneNumber": phoneNumber])
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if error != nil {
                    DispatchQueue.main.async {
                        self.showSnackBar(context: context, message: "Failed to logOut successfully")
                    }
                    return
                }
                
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    DispatchQueue.main.async {
                        self.showSnackBar(context: context, message: "Failed to logOut successfully")
                    }
                    return
                }
                
                // Remove signin number from data
                UserDefaults.standard.removeObject(forKey: "x-auth-token")
                
                // Go back to signIn page
                DispatchQueue.main.async {
                    let signInVC = SignInViwController() // Replace with your actual SignInViewController class
                    context.navigationController?.setViewControllers([signInVC], animated: true)
                    self.showSnackBar(context: context, message: "User logged Out Successfully")
                }
            }.resume()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel,handler: nil)
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        context.present(alertController, animated: true, completion: nil)
    }
        func showSnackBar(context: UIViewController, message: String) {
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alertController.view.backgroundColor = .black
            alertController.view.alpha = 0.5
            alertController.view.layer.cornerRadius = 15
            
            context.present(alertController, animated: true) {
                DispatchQueue.main.asyncAfter(deadline:.now() + 2) {
                    alertController.dismiss(animated: true, completion: nil)
                }
            }
        }
    
    func createUser(context: UIViewController, userName: String, phoneNumber: String, dateOfBirth: String, gender: String, address: String) {
        let url = URL(string: "http://93.127.172.217:4000/user-token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")

        let user: [String: Any] = [
            "userRole": "",
            "id": "",
            "token": "",
            "userName": userName,
            "phoneNumber": phoneNumber,
            "gender": gender,
            "address": address,
            "dateOfBirth": dateOfBirth
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: user, options: [])
        } catch {
            showSnackBar(context: context, message: "Failed to create user request body")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    self.showSnackBar(context: context, message: "Failed to create user successfully")
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        if let token = json["token"] as? String {
                            UserDefaults.standard.setValue(token, forKey: "x-auth-token")
                            DispatchQueue.main.async {
                                self.showSnackBar(context: context, message: "User created successfully")
                                // Handle user role and navigation here
                            }
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.showSnackBar(context: context, message: "Failed to parse create user response")
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.showSnackBar(context: context, message: "Failed to create user successfully")
                }
            }
        }

        task.resume()
    }
    
    func getUserData(context: UIViewController) {
        guard let token = UserDefaults.standard.string(forKey: "x-auth-token") else {
            showSnackBar(context: context, message: "No token found")
            return
        }

        let url = URL(string: "http://93.127.172.217:4000/user-tokenIsValid")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "x-auth-token")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    self.showSnackBar(context: context, message: "Failed to fetch user data")
                }
                return
            }

            do {
                if let response = try JSONSerialization.jsonObject(with: data, options: []) as? Bool, response == true {
                    let userDataURL = URL(string: "http://your_base_url/user-data")!
                    var userDataRequest = URLRequest(url: userDataURL)
                    userDataRequest.httpMethod = "GET"
                    userDataRequest.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
                    userDataRequest.setValue(token, forHTTPHeaderField: "x-auth-token")

                    let userDataTask = URLSession.shared.dataTask(with: userDataRequest) { data, response, error in
                        guard let data = data, error == nil else {
                            DispatchQueue.main.async {
                                self.showSnackBar(context: context, message: "Failed to fetch user data")
                            }
                            return
                        }

                        do {
                            // Parse user data and update the user provider here
                            let userProvider = try JSONDecoder().decode(UserProvider.self, from: data)
                            DispatchQueue.main.async {
                                // Update UI with user data
                                self.showSnackBar(context: context, message: "User data fetched successfully")
                            }
                        } catch {
                            DispatchQueue.main.async {
                                self.showSnackBar(context: context, message: "Failed to parse user data")
                            }
                        }
                    }

                    userDataTask.resume()
                } else {
                    DispatchQueue.main.async {
                        self.showSnackBar(context: context, message: "Invalid token")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.showSnackBar(context: context, message: "Failed to parse token validation response")
                }
            }
        }

        task.resume()
    }
    
    func updateUser(context: UIViewController, phoneNumber: String, userName: String, address: String, dateOfBirth: String) {
        guard let token = UserDefaults.standard.string(forKey: "x-auth-token") else {
            showSnackBar(context: context, message: "No token found")
            return
        }

        let url = URL(string: "http://93.127.172.217:4000/update-userdata")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "x-auth-token")

        let updateData: [String: Any] = [
            "phoneNumber": phoneNumber,
            "userName": userName,
            "address": address,
            "dateOfBirth": dateOfBirth
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: updateData, options: [])
        } catch {
            showSnackBar(context: context, message: "Failed to create update request body")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    self.showSnackBar(context: context, message: "Failed to update user data")
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    // Fetch the updated user data
                    self.getUserData(context: context)
                    self.showSnackBar(context: context, message: "Profile updated successfully")
                }
            } else {
                DispatchQueue.main.async {
                    self.showSnackBar(context: context, message: "Failed to update user data")
                }
            }
        }

        task.resume()
    }


    }
extension Dictionary {
    func toJsonData() -> Data? {
        return try? JSONSerialization.data(withJSONObject: self, options: [])
    }
}

