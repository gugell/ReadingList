import Foundation
import UIKit
import MessageUI

final class About: UITableViewController {

    let thisVersionChangeList = ChangeListProvider().thisVersionChangeList()

    override func viewDidLoad() {
        super.viewDidLoad()
        monitorThemeSetting()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if #available(iOS 13.0, *) { } else {
            cell.defaultInitialise(withTheme: GeneralSettings.theme)
        }
        if thisVersionChangeList == nil {
            cell.isHidden = true
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        guard let footer = view as? UITableViewHeaderFooterView else { assertionFailure("Unexpected footer view type"); return }
        guard let textLabel = footer.textLabel else { assertionFailure("Missing text label"); return }
        textLabel.textAlignment = .center
        textLabel.font = .systemFont(ofSize: 11.0)
        textLabel.text = "v\(BuildInfo.thisBuild.version) (\(BuildInfo.thisBuild.buildNumber))"
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 0 else { return }
        switch indexPath.row {
        case 0: presentThemedSafariViewController(URL(string: "https://www.readinglist.app")!)
        case 1: share(indexPath)
        case 2: contact(indexPath)
        case 3: presentThemedSafariViewController(URL(string: "https://github.com/AndrewBennet/readinglist")!)
        case 5:
            if let thisVersionChangeList = thisVersionChangeList {
                present(thisVersionChangeList, animated: true)
            }
        default: return
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    private func share(_ indexPath: IndexPath) {
        let appStoreUrl = URL(string: "https://\(Settings.appStoreAddress)")!
        let activityViewController = UIActivityViewController(activityItems: [appStoreUrl], applicationActivities: nil)
        activityViewController.popoverPresentationController?.setSourceCell(atIndexPath: indexPath, inTable: tableView)
        present(activityViewController, animated: true)
    }

    private func contact(_ indexPath: IndexPath) {
        let canSendEmail = MFMailComposeViewController.canSendMail()

        let controller = UIAlertController(title: "Send Feedback?", message: """
            If you have any questions or suggestions, please email me\
            \(canSendEmail ? "." : " at \(Settings.feedbackEmailAddress).") \
            I'll do my best to respond.
            """, preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: "OK", style: canSendEmail ? .default : .cancel) { _ in
            if canSendEmail {
                self.presentContactMailComposeWindow()
            }
        })
        if canSendEmail {
            controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        }
        controller.popoverPresentationController?.setSourceCell(atIndexPath: indexPath, inTable: tableView, arrowDirections: [.up, .down])

        present(controller, animated: true)
    }

    private func presentContactMailComposeWindow() {
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        mailComposer.setToRecipients(["Reading List Developer <\(Settings.feedbackEmailAddress)>"])
        mailComposer.setSubject("Reading List Feedback")
        let messageBody = """
        Your Message Here:




        Extra Info:
        App Version: \(BuildInfo.thisBuild.fullDescription)
        iOS Version: \(UIDevice.current.systemVersion)
        Device: \(UIDevice.current.modelName)
        """
        mailComposer.setMessageBody(messageBody, isHTML: false)
        present(mailComposer, animated: true)
    }
}

extension About: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true)
    }
}
