//
//  NewSettingsVC.swift
//  ShakeItPhoto
//
//  Created by Cricket on 10/24/22.
//

import UIKit


class SettingsTableViewCell: UITableViewCell {
    static let reuseIdentifier: String = String(describing: SettingsTableViewCell.self)
    
    deinit {
        NSObject.printUtil(["CELL:SettingsTableViewCell":"deinitialized"])
    }
}

class SettingsViewFooter: UITableViewHeaderFooterView {
    static let reuseIdentifier: String = String(describing: SettingsViewFooter.self)
    
    enum Constants: CGFloat {
        case kFooterHeight = 200
    }

    private var imageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "MadeinPolaroid.png"))
        iv.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier ?? Self.reuseIdentifier)
        contentView.addSubview(imageView)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        contentView.addSubview(imageView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}


class NewSettingsVC: UIViewController {
    let tableView: UITableView = {
        var table: UITableView = UITableView()
        return table
    }()
//    var footerView: UITableViewHeaderFooterView? = {
//       return SettingsViewFooter()
//    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        setupTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("###---> \(UserDefaults.standard.dictionaryRepresentation())")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("###---> \(UserDefaults.standard.dictionaryRepresentation())")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


private extension NewSettingsVC {
    @objc func onSwitch(_ sender: AnyObject) {
        if let aSwitch = sender as? UISwitch {
            let defaults = UserDefaults.standard
            let isOn = aSwitch.isOn
            switch (aSwitch.tag) {
                case 0:
                    defaults.set(isOn, forKey: kShakeItPhotoPolaroidBorderKey)
                    break;
                case 1:
                    defaults.set(isOn, forKey: kShakeItPhotoFasterShakingKey)
                    break;
                case 2:
                    defaults.set(isOn, forKey: kBananaCameraSaveOriginalKey)
                    break;
                default:
                    break;
            }
        }
    }
    
    func setupTableView() {
        if let view = self.view {
            tableView.delegate = self
            tableView.dataSource = self
            
            tableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: SettingsTableViewCell.reuseIdentifier)
            tableView.register(SettingsViewFooter.self, forHeaderFooterViewReuseIdentifier: SettingsViewFooter.reuseIdentifier)
            
            view.addSubview(tableView)
            
            tableView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                tableView.topAnchor.constraint(equalTo: view.topAnchor),
                tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
    }
}


// MARK: - UITableViewDelegate
extension NewSettingsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SettingsViewFooter")
        return footer
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return SettingsViewFooter.Constants.kFooterHeight.rawValue
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.row) {
            case 3:
                UIApplication.shared.open(NSURL.init(string: kBananaCameraMoreAppsURL)! as URL)
                break;
            default:
                break;
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


// MARK: - UITableViewDataSource
extension NewSettingsVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableViewCell.reuseIdentifier, for: indexPath) as? SettingsTableViewCell {
            
            switch (indexPath.row) {
            case 0...2:
                cell.accessoryView = UISwitch()
                cell.selectionStyle = .none
                break;
            default:
                cell.accessoryType = .disclosureIndicator
                cell.selectionStyle = .default
                break;
            }
            
            if(indexPath.row <= 2) {
                
                let defaults = UserDefaults.standard
                if let aSwitch: UISwitch = cell.accessoryView as? UISwitch {
                    aSwitch.tag = indexPath.row;
                    
                    aSwitch.addTarget(self, action: #selector(onSwitch(_:)), for: .valueChanged)
                    
                    switch (indexPath.row) {
                    case 0:
                        aSwitch.isOn = defaults.bool(forKey: kShakeItPhotoPolaroidBorderKey)
                        break;
                    case 1:
                        aSwitch.isOn = defaults.bool(forKey: kShakeItPhotoFasterShakingKey)
                        break;
                    case 2:
                        aSwitch.isOn = defaults.bool(forKey: kBananaCameraSaveOriginalKey)
                        break;
                    default:
                        break;
                    }
                }
            }
            
            switch (indexPath.row) {
            case 0:
                cell.textLabel?.text = "Polaroid Frame Photos"
                //                cell.textLabel?.font = UIFont.italicSystemFont(ofSize: 8)
                cell.textLabel?.adjustsFontForContentSizeCategory = true
                break;
            case 1:
                cell.textLabel?.text = "Fast Processing";
                break;
            case 2:
                cell.textLabel?.text = "Keep Original";
                break;
            case 3:
                cell.textLabel?.text = "More Apps";
                break;
            default:
                break;
            }
            
            return cell
        } else {
            return UITableViewCell()
        }
    }    
}


#if canImport(SwiftUI)
import SwiftUI
struct NewSettingsVCViewRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let vc = NewSettingsVC()
        return vc.view
    }
    
    func updateUIView(_ view: UIView, context: Context) {
        
    }
}

@available(iOS 13.0, *)
struct NewSettingsVC_Preview: PreviewProvider {
    static var previews: some View {
        return NewSettingsVCViewRepresentable()
    }
}
#endif
