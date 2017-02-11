//
//  NetworkManager.swift
//  PennLabsInterview
//
//  Created by Josh Doman on 2/10/17.
//  Copyright © 2017 Josh Doman. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

class NetworkManager {
    
//    static func getData(term: String, callback: @escaping (_ data: NSData?) -> () ) {
//        
//        //self.parsedData = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
//        
//        //let data = ""
//        //callback(data)
//        
//        let defaultSession = URLSession(configuration: URLSessionConfiguration.default)
//        
//        var dataTask: URLSessionDataTask?
//        
//        if dataTask != nil {
//            dataTask?.cancel()
//        }
//        
//        let expectedCharSet = NSCharacterSet.urlQueryAllowed
//        let searchTerm = term.addingPercentEncoding(withAllowedCharacters: expectedCharSet)
//        
//        let url = NSURL(string: "https://itunes.apple.com/search?media=music&entity=song&term=\(searchTerm)")
//        
//        dataTask = defaultSession.dataTask(with: url! as URL) {
//            data, response, error in
//            
//            //check for error
//            if let error = error {
//                print(error.localizedDescription)
//                
//                callback(nil)
//                
//            } else if let httpResponse = response as? HTTPURLResponse {
//                if httpResponse.statusCode == 200 {
//                    
//                    callback(data! as NSData?)
//                }
//            }
//            
//        }
//        
//        dataTask?.resume()
//    }
    
    static func getRequest(term: String, callbackString: @escaping (_ json: NSString?) -> (), callback: @escaping (_ json: NSDictionary?) -> ()) {
        let url = URL(string: "https://api.pennlabs.org/buildings/search?q=\(term)")
        
        let request = NSMutableURLRequest(url: url!)
        
        request.httpMethod = "GET"
        do {
            //let params = ["item":item, "location":location,"username":username]
            
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            
            //request.httpBody = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.prettyPrinted)
            
            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
                //
                if let error = error {
                    print(error.localizedDescription)
                } else if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                    }
                }
                
                let resultNSString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!
                if resultNSString != "null" {
                    if let json = try! JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                        //NetworkManager.getAllLocations(dict: json as! [String : AnyObject])
                        callbackString(resultNSString)
                        callback(json)
                    }
                } else {
                    print("handle Null")
                    callback(nil)
                }
                
            })
            task.resume()
        }
    }
    
    static func getAllLocations(json: [String: AnyObject]) -> [Place] {
        print(json)
        var places = [Place]()
        do {
            
            // Get the results array
            if let array: AnyObject = json["result_data"] {
                for songDictonary in array as! [AnyObject] {
                    if let songDictonary = songDictonary as? [String: AnyObject], let latitude = songDictonary["latitude"] as? String, let longitude = songDictonary["longitude"] as? String, let name = songDictonary["title"] as? String {
                        // Parse the search result
                        if let lat = Double(latitude), let long = Double(longitude) {
                            let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
                            let place = Place(location: location, name: name)
                            places.append(place)
                        }

                    } else {
                        print("Not a dictionary")
                    }
                }
            } else {
                print("Results key not found in dictionary")
            }
            
        } catch let error as NSError {
            print("Error parsing results: \(error.localizedDescription)")
        }
        
        
        return places
    }

}
