//
//  CustomToolBarViewController.swift
//  RZRichTextView_Example
//
//  Created by rztime on 2021/10/27.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import RZRichTextView

/// 对键盘上的按钮进行增删改
class CustomToolBarViewController: UIViewController {
    enum CustomToolBar : Int {
        case custom1 = 100
        case custom2 = 101
        case custom3 = 102
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        // MARK: 自定义的话，可以先在options里配置好
        /// 自定义一个option，也可以用shared
        let options = RZRichTextViewOptions.init()
        // 斜体 粗斜体，一般字体不支持中文，所以需要找一个支持中文斜体的字体
        options.obliqueFont = UIFont.init(name: "XinYuGongHeXieSong-L-Light", size: 17) ?? .italicSystemFont(ofSize: 17) // 斜体
        options.boldObliqueFont = .init(name: "XinYuGongHeXieSong-B-Bold", size: 17) ?? .boldSystemFont(ofSize: 17)  // 粗斜体
        
        /// 插入了一个图片或视频，这里是附件属性
        options.didInsetAttachment = { attahcment in
//            attahcment.image
//            attahcment.asset
            // 这是图片上的蒙层，可以添加一些进度控件、删除控件等等
            attahcment.rzrt.maskView.backgroundColor = UIColor.init(red: 1, green: 0, blue: 0, alpha: 0.3)
            // 也可以根据需要绑定上传
        }
        /// 移除了附件
        options.didRemovedAttachment = { attachments in
            print("移除了\(attachments.description)")
        }
        // MARK:  自定义工具条
        var toolbarItem : [RZToolBarItem] = options.toolbarItems
        /// 自定义 工具条
        let custom1 = RZToolBarItem.init(type: CustomToolBar.custom1.rawValue, image: .custom1_no, selectedImage: .custom1, selected: false, items: [0])
        let custom2 = RZToolBarItem.init(type: CustomToolBar.custom2.rawValue, image: .custom2_no, selectedImage: .custom2, selected: false, items: [0])
        let custom3 = RZToolBarItem.init(type: CustomToolBar.custom3.rawValue, image: .custom3_no, selectedImage: .custom3, selected: false, items: [0])
        
        // 增删改，即对toolbarItem数组进行数据处理 通过图片1 图片2，可以直接实现正常显示
        // 增
        toolbarItem.insert(custom1, at: 0)
        toolbarItem.insert(custom2, at: 1)
        toolbarItem.insert(custom3, at: 2)
        options.toolbarItems = toolbarItem
        /// 自定义工具条上的cell
        options.willRegisterAccessoryViewCell = { collectionView in
            collectionView.register(CustomCell.self, forCellWithReuseIdentifier: "CustomCell")
        }
        /// 实现工具条cell的样式UI
        options.accessoryViewCellFor = { (collectionView, item, indexPath) -> UICollectionViewCell? in
            switch item.type {
            case CustomToolBar.custom1.rawValue:
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath) as? CustomCell {
                    cell.imageView.image = item.displayImage()
                    cell.textLabel.text = "\(CustomToolBar.custom1)"
                    return cell
                }
            case CustomToolBar.custom2.rawValue:
                print("自行处理时，return cell 否则return nil")
                return nil
            case CustomToolBar.custom3.rawValue:
                print("自行处理时，return cell 否则return nil")
                return nil
            default: break
            }
            return nil
        }
        /// 自定义实现点击事件
        options.didSelectedToolbarItem = { (item, index) -> Bool in
            switch item.type {
            case CustomToolBar.custom1.rawValue:
                print("点击了cell时，若需自己实现，return false: \(CustomToolBar.custom1)")
                return false
            case CustomToolBar.custom2.rawValue:
                print("点击了cell时，若需自己实现，return false: \(CustomToolBar.custom2)")
                return false
            case CustomToolBar.custom3.rawValue:
                print("点击了cell时，若需自己实现，return false: \(CustomToolBar.custom3)")
                return false
            default: break
            }
            return true
        }
        
        let textView = RZRichTextView.init(frame: .init(x: 10, y: 100, width: 300, height: 300), options: options)
        self.view.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(100)
            make.height.equalTo(300)
        }
        textView.backgroundColor = .lightGray
        
        textView.delegate = self
    }
}
extension CustomToolBarViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        
    }
}
