
import UIKit

final class CategoryCreateViewController: UIViewController {
    private let containerView = UIView()
    private let textField = UITextField()
    private let button = TrackerButton(title: "Готово")
    
    private var isEnabled = false {
        didSet {
            button.isEnabled = isEnabled
        }
    }
    
    var createCategoryTapped: ((String) -> Void)?
    
    override func viewDidLoad() {
        view.backgroundColor = .ybBlack
        navigationItem.title = "Новая категория"
        
        containerView.backgroundColor = .background
        containerView.layer.cornerRadius = 16
        containerView.layer.masksToBounds = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        textField.delegate = self
        textField.returnKeyType = .done
        textField.placeholder = "Введите название категории"
        textField.addTarget(self, action: #selector(limitLength), for: .editingChanged)
        textField.textColor = .color
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
        button.isEnabled = false
        
        containerView.addSubview(textField)
        
        view.addSubview(containerView)
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            containerView.heightAnchor.constraint(equalToConstant: 75),
            
            textField.topAnchor.constraint(equalTo: containerView.topAnchor),
            textField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            textField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
    }
    
    @objc private func limitLength(_ textField: UITextField) {
        if let text = textField.text {
            
            enableButton(count: text.count)
            
            let isExceeded = text.count > 32
            
            if isExceeded { textField.text = String(text.prefix(32)) }
        }
    }
    
    @objc private func createTapped() {
        if let text = textField.text {
            createCategoryTapped?(text)
        }
        
        dismiss(animated: true)
    }
    
    private func enableButton(count: Int) {
        let isEmpty = count == 0
        
        if button.isEnabled && isEmpty {
            button.isEnabled = false
        } else if !button.isEnabled && !isEmpty {
            button.isEnabled = true
        }
    }
}

extension CategoryCreateViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
       textField.resignFirstResponder()
       return true
   }
}
