import UIKit

public class OTPTextField: UITextField {
    public var onPaste: ((String) -> Void)?

    public override func paste(_ sender: Any?) {
        let pasteboardString = UIPasteboard.general.string

        if let string = pasteboardString {
            onPaste?(string)
        } else {
            super.paste(sender)
        }
    }
}

public class OTPView: UIView {

    public var fieldBackgroundColor: UIColor = .gray
    public var numberOfFields: Int = 5

    public var textColor: UIColor = .black
    public var font: UIFont = .systemFont(ofSize: 14)
    public var keyboardType: UIKeyboardType = .numberPad
    public var keyboardAppearance: UIKeyboardAppearance = .default
    public var shouldSecureText: Bool = false

    public var fieldBorderColor: UIColor = .black
    public var fieldBorderWidth: CGFloat = 0
    public var fieldCornerRadius: CGFloat = 0

    private var textFieldArray = [OTPTextField]()

    public var onOTPChange: ((Bool) -> Void)?
    public var shouldHideOTP: ((Bool) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        configureFields()
    }

    private func setupViews() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10

        for _ in 0..<numberOfFields {
            let textField = OTPTextField()
            textField.onPaste = handlePaste
            textFieldArray.append(textField)
            stackView.addArrangedSubview(textField)
        }

        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)])
    }

    private func configureFields() {
        for textField in textFieldArray {
            textField.backgroundColor = fieldBackgroundColor
            textField.textColor = textColor
            textField.font = font
            textField.keyboardType = keyboardType
            textField.keyboardAppearance = keyboardAppearance
            textField.isSecureTextEntry = shouldSecureText
            textField.layer.borderColor = fieldBorderColor.cgColor
            textField.layer.borderWidth = fieldBorderWidth
            textField.layer.cornerRadius = fieldCornerRadius
            textField.textAlignment = .center
            textField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        }
    }

    @objc private func textFieldChanged(textField: OTPTextField) {
        guard let text = textField.text else { return }
        let index = textFieldArray.firstIndex(of: textField) ?? 0

        // This will handle the move to the next field when the current one is filled
        if text.count >= 1 {
            if index < numberOfFields - 1 {
                textFieldArray[index + 1].becomeFirstResponder()
            } else {
                textField.resignFirstResponder()
            }
        } else if text.isEmpty && index != 0 {
            textFieldArray[index - 1].becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            shouldHideOTP?(true)
        }

        // Trim to only one character
        textField.text = String(text.prefix(1))

        let otp = textFieldArray.map { $0.text ?? "" }.joined()
        onOTPChange?(otp.count == numberOfFields)
    }

    private func handlePaste(_ pastedString: String) {
        // Clear fields
        textFieldArray.forEach { $0.text = "" }

        let characters = Array(pastedString)

        // Paste only if the length of the pasted string equals the number of fields
        if characters.count == numberOfFields {
            for i in 0..<numberOfFields {
                textFieldArray[i].text = String(characters[i])
            }
        }
    }

    public func clearOTP() {
        textFieldArray.forEach { $0.text = "" }
        textFieldArray.first?.becomeFirstResponder()
    }

    public func getOTP() -> String {
        return textFieldArray.map { $0.text ?? "" }.joined()
    }
}
