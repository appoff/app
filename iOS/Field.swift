import SwiftUI
import MapKit

final class Field: UIView, UIViewRepresentable, UIKeyInput, UITextFieldDelegate, MKLocalSearchCompleterDelegate, ObservableObject {
    @Published private(set) var results = [MKLocalSearchCompletion]()
    private weak var field: UITextField!
    private var editable = true
    private let completer = MKLocalSearchCompleter()
    private let input = UIInputView(frame: .init(x: 0, y: 0, width: 0, height: 52), inputViewStyle: .keyboard)
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        completer.delegate = self
        
        let background = UIView()
        background.backgroundColor = .init(named: "Input")
        background.translatesAutoresizingMaskIntoConstraints = false
        background.isUserInteractionEnabled = false
        background.layer.cornerRadius = 12
        background.layer.borderColor = UIColor.label.withAlphaComponent(0.05).cgColor
        background.layer.borderWidth = 1
        background.layer.cornerCurve = .continuous
        input.addSubview(background)
        
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.keyboardType = .default
        field.textContentType = .location
        field.clearButtonMode = .always
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.spellCheckingType = .yes
        field.tintColor = .label
        field.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize + 3, weight: .regular)
        field.allowsEditingTextAttributes = false
        field.returnKeyType = .search
        field.delegate = self
        input.addSubview(field)
        self.field = field
        
        background.leftAnchor.constraint(equalTo: input.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        background.rightAnchor.constraint(equalTo: input.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        background.centerYAnchor.constraint(equalTo: field.centerYAnchor).isActive = true
        background.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        field.centerYAnchor.constraint(equalTo: input.centerYAnchor, constant: 3).isActive = true
        field.leftAnchor.constraint(equalTo: background.leftAnchor, constant: 12).isActive = true
        field.rightAnchor.constraint(equalTo: background.rightAnchor, constant: -6).isActive = true
    }
    
    func completerDidUpdateResults(_: MKLocalSearchCompleter) {
        results = completer.results
    }
    
    func textFieldDidChangeSelection(_: UITextField) {
        completer.cancel()
        if !field.text!.isEmpty {
            completer.queryFragment = ""
            completer.queryFragment = field.text!
        }
    }
    
    var hasText: Bool {
        get { field.text?.isEmpty == false }
        set { }
    }
    
    override var inputAccessoryView: UIView? {
        input
    }
    
    override var canBecomeFirstResponder: Bool {
        editable
    }
    
    func textFieldShouldEndEditing(_: UITextField) -> Bool {
        editable = false
        completer.cancel()
        return true
    }
    
    func insertText(_: String) { }
    func deleteBackward() { }
    
    func makeUIView(context: Context) -> Field {
        self
    }
    
    func updateUIView(_: Field, context: Context) { }
    
    @discardableResult override func becomeFirstResponder() -> Bool {
        DispatchQueue.main.async { [weak self] in
            self?.field.becomeFirstResponder()
        }
        return super.becomeFirstResponder()
    }
}
