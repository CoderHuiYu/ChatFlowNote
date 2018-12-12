// Copyright © 2017 Tellus, Inc. All rights reserved.

extension ZLLabel {
    convenience init(text: String, font: UIFont? = nil, containerInsets: UIEdgeInsets = .zero) {
        self.init()
        self.text = text
        self.containerInsets = containerInsets
        if let font = font { self.font = font }
    }

    convenience init(text: String? = nil, size: ZLFontSize, weight: ZLFontWeight = .regular, color: UIColor? = .zillyDarkText(), alignment: NSTextAlignment = .left, lines: Int = 1) {
        self.init()
        self.text = text
        font = UIFont.zillyFont(size: size, weight: weight)
        textColor = color
        textAlignment = alignment
        numberOfLines = lines
    }
    
    open override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: containerInsets))
    }
}
