//
//  ViewController.swift
//  PennLabsInterview
//
//  Created by Josh Doman on 2/10/17.
//  Copyright © 2017 Josh Doman. All rights reserved.
//

import UIKit

class JSONController: UIViewController {
    
    lazy var getJSON: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("GetJson", for: .normal)
        button.addTarget(self, action: #selector(handleGetJSON), for: .touchUpInside)
        button.backgroundColor = .white
        button.layer.cornerRadius = 30
        return button
    }()
    
    lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Next", for: .normal)
        button.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        button.backgroundColor = .white
        button.layer.cornerRadius = 30
        return button
    }()
    
    let textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = .lightGray
        textField.placeholder = "Search here..."
        return textField
    }()
    
    let label: UITextView = {
        let text = UITextView()
        text.textColor = .lightGray
        text.autocorrectionType = UITextAutocorrectionType.no
        text.font = UIFont(name: "Helvetica", size: 10)
        text.text = "hello"
        text.backgroundColor = .clear
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(textField)
        view.addSubview(getJSON)
        view.addSubview(label)
        view.addSubview(nextButton)
        
        _ = textField.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 16, leftConstant: 16, bottomConstant: 0, rightConstant: 100, widthConstant: 0, heightConstant: 50)
        
        _ = getJSON.anchor(textField.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 50)
        getJSON.widthAnchor.constraint(equalToConstant: 100).isActive = true
        getJSON.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        _ = label.anchor(getJSON.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 16, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        _ = nextButton.anchor(textField.topAnchor, left: textField.rightAnchor, bottom: textField.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 8, bottomConstant: 0, rightConstant: 8, widthConstant: 0, heightConstant: 0)
    }
    
    func handleGetJSON() {
        if let text = textField.text, textField.text != "" {
            
            NetworkManager.getRequest(term: text, callbackString: { (jsonString) in
                if let nsstring = jsonString {
                    DispatchQueue.main.async {
                        print(nsstring)
                        self.label.text = nsstring as String
                    }
                }
            }, callback: { _ in })
        }
        
        textField.resignFirstResponder()
    }
    
    func handleNext() {
        let nc = UINavigationController(rootViewController: MapController())
        nc.modalTransitionStyle = .crossDissolve
        present(nc, animated: true, completion: nil)
    }
}

