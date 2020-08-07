//
//  ViewController.swift
//  IBuyOff
//
//  Created by Mohanraj on 30/07/20.
//  Copyright © 2020 ThirdwareSolutions. All rights reserved.
//

import UIKit
import MobileCoreServices
import Alamofire
//import SVProgressHUD

struct ExcelReport: Decodable {
  let fileName: String
  
  enum CodingKeys: String, CodingKey {
    case fileName
    
  }
}
class MasterDataExceluploadViewController: UIViewController {
    
    let uploadUrl = "https://buyoffservice.cfapps.io/BuyOff/PartMstr/ExcelUpload"
    let donwnloadTemplateUrl = "https://buyoffservice.cfapps.io/BuyOff/PartMstr/downloadTemplate"
    let downloadExcelUrl = "https://buyoffservice.cfapps.io/BuyOff/PartMstr/downloadExcel"
    
    var fileString: String = ""
    

    @IBAction func uploadButtonAction(_ sender: Any) {
        self.attachDocument()

    }
    @IBAction func downloadTemplateAction(_ sender: Any) {
        self.downloadTemplate()
    }
    @IBAction func downloadDataAction(_ sender: Any) {
        self.downloadExcelData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
   
    private func attachDocument() {
        let types = [kUTTypePDF, kUTTypeText, kUTTypeRTF, kUTTypeSpreadsheet,kUTTypeData,kUTTypeHTML,kUTTypeJSON,kUTTypeText,kUTTypeBMP]
        let importMenu = UIDocumentPickerViewController(documentTypes: types as [String], in: .import)

        if #available(iOS 11.0, *) {
            importMenu.allowsMultipleSelection = false
        }

        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet

        present(importMenu, animated: true)
    }
    
    func clearAllFile() {
        let fileManager = FileManager.default
        let myDocuments = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            try fileManager.removeItem(at: myDocuments)
        } catch {
            return
        }
    }
    
    func downloadExcelData() {
        //SVProgressHUD.show()
        // Create destination URL
               let documentsUrl:URL =  (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL?)!
               let destinationFileUrl = documentsUrl.appendingPathComponent("excelbuyoff.zip")

               //Create URL to the source file you want to download
               let fileURL = URL(string: downloadExcelUrl)

               let sessionConfig = URLSessionConfiguration.default
               let session = URLSession(configuration: sessionConfig)

               let request = URLRequest(url:fileURL!)

               let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
                   if let tempLocalUrl = tempLocalUrl, error == nil {
                       // Success
                      // SVProgressHUD.dismiss()
                       if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                           print(response as Any)
                           print("Successfully downloaded. Status code: \(statusCode)")
                          
                       }
                       if FileManager.default.fileExists(atPath: tempLocalUrl.path) {
                           self.clearAllFile()
                       }
                       do {
                           try FileManager.default.moveItem(at: tempLocalUrl, to: destinationFileUrl)
                            DispatchQueue.main.async {
                                 self.alertmessage(message: "You have successfully downloaded the download data")
                        }
                       } catch (let writeError) {
                           print("Error creating a file \(destinationFileUrl) : \(writeError)")
                       }
                   } else {
                       print("Error took place while downloading a file. Error description: %@", error?.localizedDescription as Any);
                    //SVProgressHUD.dismiss()
                   }
               }
               task.resume()
    }
    func downloadTemplate() {
        //SVProgressHUD.show()
        // Create destination URL
        let documentsUrl:URL =  (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL?)!
        let destinationFileUrl = documentsUrl.appendingPathComponent("excelbuyoff.zip")

        //Create URL to the source file you want to download
        let fileURL = URL(string: donwnloadTemplateUrl)

        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)

        let request = URLRequest(url:fileURL!)

        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                //SVProgressHUD.dismiss()
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print(response as Any)
                    print("Successfully downloaded. Status code: \(statusCode)")
                }
                if FileManager.default.fileExists(atPath: tempLocalUrl.path) {
                    self.clearAllFile()
                }
                do {
                    try FileManager.default.moveItem(at: tempLocalUrl, to: destinationFileUrl)
                    DispatchQueue.main.async {
                         self.alertmessage(message: "You have successfully downloaded the download template")
                    }
                } catch (let writeError) {
                    print("Error creating a file \(destinationFileUrl) : \(writeError)")
                    //SVProgressHUD.dismiss()
                }
            } else {
                print("Error took place while downloading a file. Error description: %@", error?.localizedDescription as Any);
                //SVProgressHUD.dismiss()
            }
        }
        task.resume()
    }

    func errorlogExcelupload(filename: String)
    {
        // Create destination URL
        let documentsUrl:URL =  (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL?)!
        let destinationFileUrl = documentsUrl.appendingPathComponent(filename)
       
        //Create URL to the source file you want to download
        let fileURL = URL(string:"https://buyoffservice.cfapps.io/BuyOff/PartMstr/logdownload?filename=\(filename)")

        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)

        let request = URLRequest(url:fileURL!)

        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print(response as Any)
                    print("Successfully downloaded. Status code: \(statusCode)")
                }
                if FileManager.default.fileExists(atPath: tempLocalUrl.path) {
                   // self.clearAllFile()
                }
                do {
                    try FileManager.default.moveItem(at: tempLocalUrl, to: destinationFileUrl)

                } catch (let writeError) {
                    print("Error creating a file \(destinationFileUrl) : \(writeError)")
                }
            } else {
                print("Error took place while downloading a file. Error description: %@", error?.localizedDescription as Any);
            }
        }
        task.resume()

    }
    func alertmessage(message: String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

        self.present(alert, animated: true)
    }
    
    
    func documentUpload(url: String, docData: Data?, parameters: [String : Any], fileName: String, token : String!){
        //SVProgressHUD.show()
         let headers: HTTPHeaders = [
             "Content-type": "multipart/form-data",
         ]
        
       AF.upload(multipartFormData: { (multipartFormData) in
             if let data = docData{
                 multipartFormData.append(data, withName: "file", fileName: fileName, mimeType: "application/octet-stream")
             }
             for (key, value) in parameters {
                 multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
              print("PARAMS => \(multipartFormData)")
             }
             
         }, to: url, method: .post, headers: headers)
        .responseDecodable(of: ExcelReport.self) { (response) in
          guard let documetResult = response.value else { return }
            self.fileString = documetResult.fileName
            print("testFile:\(self.fileString)")
            
            self.errorlogExcelupload(filename: self.fileString)
            
        }
            .response { resp in
                    switch resp.result{
                    case .failure(let error):
                    print(error)
                        //SVProgressHUD.dismiss()
                    case.success( _):
                        DispatchQueue.main.async {
                            self.alertmessage(message: "You have successfully uploaded the document")
                            print(resp.value as Any)
                            //SVProgressHUD.dismiss()
                        }
                    print("Response after upload file: (resp.result)")
                    }

         }
     }
}


extension MasterDataExceluploadViewController: UIDocumentPickerDelegate{
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
         // you get from the urls parameter the urls from the files selected
        print("XlsFileupload:\(urls)")
    
        guard let myURL = urls.first else {
                   return
               }
               print("import result : \(myURL)")
               let data = NSData(contentsOf: myURL)
               do{
                   self.documentUpload(url: uploadUrl, docData: try Data(contentsOf: myURL), parameters: ["file": "file" as AnyObject], fileName: myURL.lastPathComponent, token: "")
               }catch{
                   print(error)
               }
        
    }
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

