//
//  ViewController.swift
//  ChatFlow
//
//  Created by Patrick Pijnappel on 30/11/18.
//  Copyright © 2018 Patrick Pijnappel. All rights reserved.
//

import UIKit

final class ZLSampleChatFlowVC : ZLChatFlowVC {

    // MARK: Settings
    override class var navigationViewStyle: NavigationViewStyle { return .adventure }

    override func viewDidLoad() {
        super.viewDidLoad()
        let progressView = self.progressView as! ZLAdventureProgressView
        let title = NSLocalizedString("Add a Home", comment: "")
        progressView.title = title
        self.transition(to: createSingleOrMultiUnitQuestionState())
    }

    // MARK: States
    private func createSingleOrMultiUnitQuestionState() -> State {
        let unitMessage = NSLocalizedString("Nice place! Does your property have multiple units?", comment: "")
        let events: [Event] = [
            .textMessage(sender: .other(name: nil, icon: #imageLiteral(resourceName: "avatar-zilly-ama-blue")), text: unitMessage)
        ]
        let yesAction = { [unowned self] in
            self.transition(to: self.createNumberOfUnitsQuestionState())
        }
        let yesButton = ZLProminentButton(title: NSLocalizedString("Yes", comment: ""), action: yesAction, style: .stroked)
        let noAction = { [unowned self] in
            self.transition(to: self.createSingleUnitState())
        }
        let noButton = ZLProminentButton(title: NSLocalizedString("No, One Unit", comment: ""), action: noAction)
        let accessory = ZLOnboardingAccessoryView()
        accessory.setButtons([ yesButton, noButton ])
        return State(events: events, progress: 0.33, accessory: accessory)
    }

    private func createSingleUnitState() -> State {
        let unitMessage = NSLocalizedString("Okay! Just one unit then.", comment: "")
        let events: [Event] = [
            .textMessage(sender: .user, text: NSLocalizedString("No, just one unit.", comment: "")),
            .textMessage(sender: .other(name: nil, icon: #imageLiteral(resourceName: "avatar-zilly-ama-blue")), text: unitMessage)
        ]
        let action = { [unowned self] in
            self.transition(to: self.createFinishedState())
        }
        let continueButton = ZLProminentButton(title: NSLocalizedString("Continue", comment: ""), action: action)
        let accessory = ZLOnboardingAccessoryView()
        accessory.setButtons([ continueButton ])
        return State(events: events, progress: 0.66, accessory: accessory)
    }

    private func createNumberOfUnitsQuestionState() -> State {
        let numberOfUnitsEditor = ZLNumberEditor.numberOfUnitsEditor()
        let numberOfUnitsEditorView = ZLChatNumberEditorView(title: NSLocalizedString("Units", comment: ""), editor: numberOfUnitsEditor)
        let events: [Event] = [
            .textMessage(sender: .user, text: NSLocalizedString("Yes", comment: "")),
            .textMessage(sender: .other(name: nil, icon: #imageLiteral(resourceName: "avatar-zilly-ama-blue")), text: NSLocalizedString("How many units do you have?", comment: "")),
            .customMessage(sender: .none, view: numberOfUnitsEditorView)
        ]
        let action = { [unowned self] in
            self.transition(to: self.createFinishedState())
        }
        let continueButton = ZLProminentButton(title: NSLocalizedString("Continue", comment: ""), action: action)
        continueButton.isUserInteractionEnabled = false
        numberOfUnitsEditor.valueEditedHandler = { continueButton.isUserInteractionEnabled = $0 != 0 }
        let accessory = ZLOnboardingAccessoryView()
        accessory.setButtons([ continueButton ])
        return State(events: events, progress: 0.66, accessory: accessory) { numberOfUnitsEditorView.textField.becomeFirstResponder() }
    }

    private func createFinishedState() -> State {
        let events: [Event] = [
            .textMessage(sender: .other(name: nil, icon: #imageLiteral(resourceName: "avatar-zilly-ama-blue")), text: NSLocalizedString("The demo has finished :)", comment: "")),
        ]
        let action = { [unowned self] in
            self.dismiss(animated: true, completion: nil)
        }
        let continueButton = ZLProminentButton(title: NSLocalizedString("Finish", comment: ""), action: action)
        let accessory = ZLOnboardingAccessoryView()
        accessory.setButtons([ continueButton ])
        return State(events: events, progress: 1, accessory: accessory)
    }

    // MARK: Actions
    override func handleBackButtonPressed() {
        popOrDismissSelf()
    }

    // MARK: Convenience
    func popOrDismissSelf(animated: Bool = true) {
        if let navigationController = navigationController, let index = navigationController.viewControllers.index(of: self), index > 0 {
            navigationController.popToViewController(navigationController.viewControllers[index-1], animated: animated)
        } else {
            presentingViewController?.dismiss(animated: animated, completion: nil)
        }
    }
}

