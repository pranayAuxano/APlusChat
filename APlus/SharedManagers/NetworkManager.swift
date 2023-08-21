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
                //try data?.write(to: fileLocation)
                try data?.write(to: fileLocation, options: Data.WritingOptions.atomic)
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
    
    func uploadImage(url: String = SocketChatManager.sharedInstance.UPLOAD_FILE,
                     dictiParam: [String: Any],
                     image: Any,
                     type: String,
                     contentType: String,
                     COMPLETION completion: @escaping ((String) -> Void),
                     errorCompletion: @escaping ((String) -> Void)) {
        
        let boundary = UUID().uuidString
        let session = URLSession.shared
        var urlRequest = URLRequest(url: URL(string: url)!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var data = Data()
        for (key, value) in dictiParam {
            
            if key == "image" {
                if type == "image" {
                    let img: UIImage = image as! UIImage
                    data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
                    data.append("Content-Disposition: form-data; name=\"\("selectFile")\"; filename=\"\(value as! String)\"\r\n".data(using: .utf8)!)
                    data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
                    data.append(img.pngData()!)
                } else if type == "video" {
                    let video = image as! Data
                    data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
                    data.append("Content-Disposition: form-data; name=\"\("selectFile")\"; filename=\"\(value as! String)\"\r\n".data(using: .utf8)!)
                    data.append("Content-Type: \(contentType)\r\n\r\n".data(using: .utf8)!)
                    //data.append(img.pngData()!)
                    data.append(video)
                } else if type == "document" {
                    let url = image as! URL
                    do {
                        let myData = try Data(contentsOf: url)
                        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
                        data.append("Content-Disposition: form-data; name=\"\("selectFile")\"; filename=\"\(value as! String)\"\r\n".data(using: .utf8)!)
                        data.append("Content-Type: \(contentType)\r\n\r\n".data(using: .utf8)!)
                        data.append(myData)
                    } catch let err {
                        print(err)
                        return
                    }
                } else if type == "audio" {
                    let audio = image as! Data
                    data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
                    data.append("Content-Disposition: form-data; name=\"\("selectFile")\"; filename=\"\(value as! String)\"\r\n".data(using: .utf8)!)
                    data.append("Content-Type: \(contentType)\r\n\r\n".data(using: .utf8)!)
                    //data.append(img.pngData()!)
                    //data.append(audio)
                    data.append(image as! Data)
                }
            } else {
                data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
                data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
                data.append("\(value)".data(using: .utf8)!)
            }
        }
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        print(data)
        
        session.uploadTask(with: urlRequest, from: data, completionHandler: { responseData, response, error in
            DispatchQueue.main.async {
                if (error != nil) {
                    print("Get error whiile send data -> \(error?.localizedDescription)")
                    return
                }
                do {
                    let dictData = try JSONSerialization.jsonObject(with: responseData!, options: .allowFragments) as? NSDictionary
                    let status = dictData!["success"] as! Int
                    if status == 1 {
                        print(dictData)
                        completion(dictData!["file"] as! String)
                    } else {
                        let errors = dictData!["errors"] as? [[String: Any]]
                        errorCompletion(errors![0]["msg"] as! String)
                    }
                } catch {
                    errorCompletion(error.localizedDescription)
                }
            }
        }).resume()
    }
    
    func createGroup(url: String = SocketChatManager.sharedInstance.CREATE_GROUP, param: [String : Any], COMPLETION completion: @escaping ((String) -> Void), errorCompletion: @escaping ((String) -> Void)) {
        //let data = file.pngData()!.bytes
        //let params = ["file": file, "fileName": fileName, "contentType" : contentType] as Dictionary<String, Any>
        
        let url1 = URL(string: url)
        let config = URLSessionConfiguration.default // Session Configuration
        let session = URLSession(configuration: config) // Load configuration into Session

        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        
        request.timeoutInterval = 60
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")

        request.cachePolicy = .reloadIgnoringCacheData
        
        if param != nil {
            let theJSONData = try? JSONSerialization.data(withJSONObject: param, options: JSONSerialization.WritingOptions.init(rawValue: 0))
            let JsonString = String.init(data: theJSONData!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
            
            print("json : \(JsonString!)")
            request.httpBody = JsonString!.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue), allowLossyConversion:true)
        }
        
        print(URLRequest(url: url1!))
        let task = session.dataTask(with: request, completionHandler:{
            (data, response, error) in
            if error == nil {
                guard let data = data else { return }
                do {
                    let jsonDecoder = JSONDecoder()
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                    print(jsonResponse)
                    let dataReceived: CreateGroupRes = try jsonDecoder.decode(CreateGroupRes.self, from: data)
                    completion(dataReceived.groupId ?? "")
                } catch let jsonErr {
                    print(jsonErr)
                    completion("Error")
                }
            } else {
                completion("Error")
            }
        })
        task.resume()
    }
    
    func convertImageToBase64String (img: UIImage) -> String {
        return img.jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""
    }
    
    func convertBase64StringToImage (imageBase64String:String) -> UIImage {
        let imageData = Data(base64Encoded: imageBase64String)
        let image = UIImage(data: imageData!)
        return image!
    }
}
