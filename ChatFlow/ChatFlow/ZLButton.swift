// Copyright © 2017 Tellus, Inc. All rights reserved.

extension ZLButton {
    var title: String? {
        get { return title(for: .normal) }
        set { setTitle(newValue, for: .normal) }
    }
}
