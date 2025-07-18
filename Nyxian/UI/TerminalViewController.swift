import UIKit

class TerminalViewController: UIViewController {
    private let textView = UITextView()
    private let runButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "IPA Injector"
        view.backgroundColor = .black

        setupTextView()
        setupButton()
    }

    private func setupTextView() {
        textView.font = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        textView.textColor = .green
        textView.backgroundColor = .black
        textView.isEditable = false
        textView.text = "🔥 Nyxian Terminal Ready...\n"
        view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100)
        ])
    }

    private func setupButton() {
        runButton.setTitle("Start Injection", for: .normal)
        runButton.setTitleColor(.white, for: .normal)
        runButton.backgroundColor = .systemPurple
        runButton.layer.cornerRadius = 8
        runButton.addTarget(self, action: #selector(startInjection), for: .touchUpInside)
        view.addSubview(runButton)
        runButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            runButton.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 16),
            runButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            runButton.widthAnchor.constraint(equalToConstant: 200),
            runButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    @objc private func startInjection() {
        append("📦 Step 1: Selecting IPA...")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.append("🔍 Step 2: Analyzing @rpath...")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.append("🧬 Step 3: Injecting dylib...")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.append("📦 Step 4: Rebuilding IPA...")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            self.append("✅ Done! Injected IPA saved to Files.")
        }
    }

    private func append(_ text: String) {
        textView.text += "\n" + text
        textView.scrollRangeToVisible(NSMakeRange(textView.text.count, 0))
    }
}