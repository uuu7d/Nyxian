//
//  ContentView.swift
//  LindDE
//
//  Created by lindsey on 05.05.25.
//

import Foundation
import UIKit

class ContentViewController: UITableViewController, UIDocumentPickerDelegate, UIAdaptivePresentationControllerDelegate {
    var projects: [AppProject] = []
    var path: String
    
    var lastProjectWasSelected: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "LDELastProjectSelectedEven")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "LDELastProjectSelectedEven")
        }
    }
    var lastProjectSelected: String {
        get {
            return UserDefaults.standard.string(forKey: "LDELastProjectSelected") ?? "0"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "LDELastProjectSelected")
        }
    }
    var cellSelected: Int = 0
    
    init(path: String) {
        RevertUI()
        
        Bootstrap.shared.bootstrap()
        LDELogger.setup()
        CertBlob.startSigner()
        
        self.path = path
        
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Projects"
        
        let createItem: UIAction = UIAction(title: "Create", image: UIImage(systemName: "plus.circle.fill")) { _ in
            let alert = UIAlertController(title: "Create Project",
                                          message: "",
                                          preferredStyle: .alert)
            
            alert.addTextField { textField in
                textField.placeholder = "Name"
            }
            
            alert.addTextField { textField in
                textField.placeholder = "Bundle Identifier"
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            let createAction = UIAlertAction(title: "Create", style: .default) { _ in
                let name = alert.textFields?[0].text ?? ""
                let bundleid = alert.textFields?[1].text ?? ""
                
                self.projects.append(AppProject.createAppProject(
                    atPath: self.path,
                    executable: name,
                    bundleid: bundleid
                ))
                
                let newIndexPath = IndexPath(row: self.projects.count - 1, section: 0)
                self.tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            
            alert.addAction(cancelAction)
            alert.addAction(createAction)
            
            self.present(alert, animated: true)
        }
        
        let importItem: UIAction = UIAction(title: "Import", image: UIImage(systemName: "square.and.arrow.down.fill")) { _ in
            let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.zip], asCopy: true)
            documentPicker.delegate = self
            documentPicker.modalPresentationStyle = .pageSheet
            self.present(documentPicker, animated: true)
        }

        let injectItem: UIAction = UIAction(title: "IPA Injector", image: UIImage(systemName: "terminal")) { _ in
            let terminalVC = TerminalViewController()
            self.navigationController?.pushViewController(terminalVC, animated: true)
        }
        
        let menu = UIMenu(children: [createItem, importItem, injectItem])
        let barbutton = UIBarButtonItem()
        barbutton.menu = menu
        barbutton.image = UIImage(systemName: "plus")
        self.navigationItem.setRightBarButton(barbutton, animated: false)
    
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.tableView.rowHeight = 70
        
        self.projects = AppProject.listProjects(ofPath: self.path)
        self.tableView.reloadData()
        
        if lastProjectWasSelected {
            let selectedProject = AppProject(path: "\(self.path)/\(lastProjectSelected)")
            let fileVC = FileListViewController(project: selectedProject, path: selectedProject.getPath())
            self.navigationController?.pushViewController(fileVC, animated: false)
            return
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.lastProjectWasSelected = false
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.projects[indexPath.row].reload()
        return self.projects[indexPath.row].projectTableCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedProject = projects[indexPath.row]
        let fileVC = FileListViewController(project: selectedProject, path: selectedProject.getPath())
        self.navigationController?.pushViewController(fileVC, animated: true)
        
        self.cellSelected = indexPath.row
        lastProjectSelected = selectedProject.getUUID()
        lastProjectWasSelected = true
    }
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let export = UIAction(title: "Export", image: UIImage(systemName: "square.and.arrow.up.fill")) { _ in
                DispatchQueue.global().async {
                    let project = self.projects[indexPath.row]
                    try? FileManager.default.zipItem(at: project.getPath().URLGet(), to: URL(fileURLWithPath: "\(NSTemporaryDirectory())/\(project.projectConfig.displayname).zip"))
                    share(url: URL(fileURLWithPath: "\(NSTemporaryDirectory())/\(project.projectConfig.displayname).zip"), remove: true)
                }
            }
            
            let remove = UIAction(title: "Remove", image: UIImage(systemName: "trash.fill"), attributes: .destructive) { _ in
                let project = self.projects[indexPath.row]
                self.presentConfirmationAlert(title: "Warning", message: "Are you sure you want to remove \"\(project.projectConfig.displayname)\"?", confirmTitle: "Remove", confirmStyle: .destructive) {
                    AppProject.removeProject(project: project)
                    self.projects = AppProject.listProjects(ofPath: self.path)
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }
            
            let settings = UIAction(title: "Settings", image: UIImage(systemName: "gear")) { _ in
                let settingsVC = UINavigationController(rootViewController: ProjectSettingsViewController(style: .insetGrouped, project: self.projects[indexPath.row]))
                settingsVC.modalPresentationStyle = .pageSheet
                settingsVC.presentationController?.delegate = self
                self.present(settingsVC, animated: true)
            }
            
            return UIMenu(children: [export, remove, settings])
        }
    }

    // ✅ تم التعديل هنا لإظهار التيرمنال بعد اختيار ملف .ipa
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        do {
            guard let selectedURL = urls.first else { return }
            
            let extractFirst = URL(fileURLWithPath: "\(NSTemporaryDirectory())Proj")
            try FileManager.default.createDirectory(at: extractFirst, withIntermediateDirectories: true)
            try FileManager.default.unzipItem(at: selectedURL, to: extractFirst)
            let items = try FileManager.default.contentsOfDirectory(atPath: extractFirst.path)
            let projectPath = "\(Bootstrap.shared.bootstrapPath("/Projects"))/\(UUID().uuidString)"
            try FileManager.default.moveItem(atPath: extractFirst.appendingPathComponent(items.first ?? "").path, toPath: projectPath)
            try FileManager.default.removeItem(at: extractFirst)

                        // ⚡️ تفعيل التيرمنال وعرض ما يحدث للمستخدم خطوة بخطوة
            let terminalVC = TerminalViewController()
            self.navigationController?.pushViewController(terminalVC, animated: true)
            
            terminalVC.log("🧩 جارٍ تحليل بنية ملف IPA...")
            
            // 1. ابحث عن مجلد Payload
            let payloadPath = "\(projectPath)/Payload"
            let payloadContents = try FileManager.default.contentsOfDirectory(atPath: payloadPath)
            
            guard let appBundleName = payloadContents.first(where: { $0.hasSuffix(".app") }) else {
                terminalVC.log("❌ لم يتم العثور على ملف .app داخل Payload.")
                return
            }
            
            let appPath = "\(payloadPath)/\(appBundleName)"
            terminalVC.log("📦 تم العثور على تطبيق: \(appBundleName)")
            
            // 2. البحث عن الملف التنفيذي (عادةً يحمل نفس اسم التطبيق)
            let appBinary = appBundleName.replacingOccurrences(of: ".app", with: "")
            let executablePath = "\(appPath)/\(appBinary)"
            
            if FileManager.default.fileExists(atPath: executablePath) {
                terminalVC.log("✅ تم تحديد المسار التنفيذي: \(executablePath)")
            } else {
                terminalVC.log("⚠️ تعذر العثور على الملف التنفيذي مباشرة.")
            }
            
            // 3. البحث عن مكتبات تستخدم @rpath
            terminalVC.log("🔍 البحث عن مكتبات داخل التطبيق...")
            
            let files = try FileManager.default.contentsOfDirectory(atPath: appPath)
            let dylibs = files.filter { $0.hasSuffix(".dylib") }
            
            for dylib in dylibs {
                terminalVC.log("🧬 مكتبة مكتشفة: \(dylib)")
            }
            
            // 4. إعلام المستخدم أن المشروع جاهز للحقن
            terminalVC.log("🚀 يمكنك الآن اختيار نقطة الحقن أو تحميل مكتبة خارجية.")
                        
            self.projects.append(AppProject(path: projectPath))
            let newIndexPath = IndexPath(row: self.projects.count - 1, section: 0)
            self.tableView.insertRows(at: [newIndexPath], with: .automatic)

            // افتح التيرمنال التفاعلي وعرض الخطوات
            let terminalVC = TerminalViewController()
            self.navigationController?.pushViewController(terminalVC, animated: true)

            terminalVC.log("🎉 تم استيراد مشروع جديد بنجاح!")
            terminalVC.log("📦 اسم الملف: \(selectedURL.lastPathComponent)")
            terminalVC.log("🗂️ المسار المؤقت: \(extractFirst.path)")
            terminalVC.log("📁 نقل المشروع إلى: \(projectPath)")
            terminalVC.log("🔍 بدء تحليل ملفات المشروع...")
            terminalVC.log("💡 يمكنك الآن بدء عملية الحقن أو التعديل!")

        } catch {
            NotificationServer.NotifyUser(level: .error, notification: error.localizedDescription)
        }
    }
}