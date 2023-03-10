//
//  NetworkManager.swift
//  agsChat
//
//  Created by MAcBook on 10/06/22.
//

import UIKit
import Network

class NetworkManager: NSObject {

    static let sharedInstance = NetworkManager()
    private override init() {}
    
    //rewuest-body: {"id":"6271005aa0b24b24eb781674","secretKey":"U2FsdGVkX18AsTXTniJJwZ9KaiRWQki0Gike3TN+QyXws0hyLIdcRN4abTk84a7r"}
    
    let monitor = NWPathMonitor()
    private var status: NWPath.Status = .requiresConnection
    var isReachable: Bool { status == .satisfied }
    var isReachableOnCellular: Bool = true
    
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.status = path.status
            self?.isReachableOnCellular = path.isExpensive
            
            if path.status == .satisfied {
                print("We're connected!")
                // post connected notification
            } else {
                print("No connection.")
                // post disconnected notification
            }
            print(path.isExpensive)
        }
        
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> Cancellable {
        
//        if let cachedImage = image(url: URL(string: grupImage)) {
//            DispatchQueue.main.async {
//                completion(item, cachedImage)
//            }
//            return
//        }
        
        let dataTask = URLSession.shared.dataTask(with: url) { data, response, err in
            if err == nil {
                completion(data, response, err)
            }
        }
        dataTask.resume()
        return dataTask
    }
    
    func download(url : URL, fileLocation : URL, obj : ChatVC, completion : @escaping (_ result : String) -> Void) {
        
        let downloadTask = URLSession.shared.dataTask(with: url) { data, response, error in
            //let saveFile = documentUrl.appendingPathComponent(fileLocation)
            //try FileManager.default.moveItem(at: fileUrl, to: savedFile)
            //data?.write(to: saveFile, options: .noFileProtection)
            do {
                try data?.write(to: fileLocation)
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "File Download", message: "File downloaded successfully.", preferredStyle: .alert)
                    let OKAction = UIAlertAction(title: "OK", style: .default) { action in
                    }
                    alertController.addAction(OKAction)
                    obj.present(alertController, animated: true, completion: nil)
                }
                completion("downloaded")
            } catch let error {
                print(error.localizedDescription)
            }
        }
        downloadTask.resume()
    }
    
    /*func uploadImage(fileName : String, image: [UInt8], contentType: String, completion: @escaping ((String) -> Void)) {
        self.uploadMedia(url: "http://3.139.188.226:5000/user/public/upload-file", fileName: fileName, image: image, contentType: contentType) { url in
            completion(url)
        }
    }       /// */
    
    func uploadMedia(url: String = "http://3.139.188.226:5000/user/public/upload-file", fileName: String,image file: [UInt8], contentType: String, COMPLETION completion: @escaping ((String) -> Void)) {
        //let data = file.pngData()!.bytes
        let params = ["file": file, "fileName": fileName, "contentType" : contentType] as Dictionary<String, Any>

        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                print(json)
                let status = json["success"] as! Int
                if status == 1 {
                    completion(json["file"] as! String)
                }
                completion("")
            } catch let error {
                print(error.localizedDescription)
                completion("")
            }
        })

        task.resume()
    }   //  */
    
    func convertImageToBase64String (img: UIImage) -> String {
        return img.jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""
    }
    
    func convertBase64StringToImage (imageBase64String:String) -> UIImage {
        let imageData = Data(base64Encoded: imageBase64String)
        let image = UIImage(data: imageData!)
        return image!
    }
}



