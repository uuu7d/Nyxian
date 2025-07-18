import UIKit

class TerminalViewController: UIViewController {

    private let textView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.backgroundColor = .black
        tv.textColor = .green
        tv.font = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.text = "[+] Waiting for events...\n"
        return tv
    }()

    private let clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("🧹 Clear", for: .normal)
        button.tintColor = .white
        button.backgroundColor = .darkGray
        button.layer.cornerRadius = 6
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI()
        clearButton.addTarget(self, action: #selector(clearLog), for: .touchUpInside)
    }

    private func setupUI() {
        view.addSubview(textView)
        view.addSubview(clearButton)

        NSLayoutConstraint.activate([
            clearButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            clearButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            clearButton.heightAnchor.constraint(equalToConstant: 30),

            textView.topAnchor.constraint(equalTo: clearButton.bottomAnchor, constant: 8),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    @objc private func clearLog() {
        textView.text = ""
    }

    public func log(_ message: String) {
        DispatchQueue.main.async {
            let timestamp = self.getCurrentTimestamp()
            let fullMessage = "[\(timestamp)] \(message)\n"
            self.textView.text += fullMessage
            let range = NSMakeRange(self.textView.text.count - 1, 0)
            self.textView.scrollRangeToVisible(range)
        }
    }

    private func getCurrentTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: Date())
    }
}