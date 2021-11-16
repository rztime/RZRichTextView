//
//  ViewController.swift
//  RZRichTextView
//
//  Created by rztime on 10/15/2021.
//  Copyright (c) 2021 rztime. All rights reserved.
//

import UIKit
import RZRichTextView
import SnapKit

class ViewController: UIViewController {
    let tableView = UITableView.init(frame: .zero, style: .plain)
    
    let items: [(String, UIViewController.Type)] = [
        ("正常使用", TextViewContrller.self),
        ("自定义(增删改)工具条", CustomToolBarViewController.self),
        ("有序无序文本", OrderdTextViewController.self),
        ("插入附件", AddAttachmentViewController.self),
        ("深度自定义", CustomerTextView.self),
        
    ]
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        self.title = "富文本"
        self.view.backgroundColor = .white
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tableView.delegate = self
        tableView.dataSource = self
        
        // 全局配置
        let option = RZRichTextViewOptions.shared
        
        // 打开相册
        option.openPhotoLibrary = { complete in
            let vc = TZImagePickerController.init(maxImagesCount: 1, delegate: nil)
            vc?.allowPickingImage = true
            vc?.allowPickingVideo = true
            vc?.allowTakeVideo = false
            vc?.allowTakePicture = false
            vc?.allowCrop = false
            vc?.didFinishPickingPhotosHandle = { (photos, assets, _) in
                if let image = photos?.first {
                    let asset = assets?.first as? PHAsset
                    complete(image, asset)
                }
            }
            vc?.didFinishPickingVideoHandle = { (image, asset) in
                if let image = image {
                    complete(image, asset)
                }
            }
            RZRichTextViewUtils.rz_currentViewController()?.present(vc!, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell.init(style: .value1, reuseIdentifier: "cell")
        }
        cell?.textLabel?.text = "\(items[indexPath.row].0)"
        cell?.detailTextLabel?.text = "\(items[indexPath.row].1)"
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let c = items[indexPath.row].1
        if let cls = c.init() as? UIViewController {
            cls.title = items[indexPath.row].0
            self.navigationController?.pushViewController(cls, animated: true)
        }
    }
}
