//
//  IDZTabViewBar.swift
//  IDZTabView
//  Modified by iOS Developer Zone to remove navigation bar emulation.
//  --- Original Copyright Message ---
//  Created by Ian McDowell on 2/2/18.
//  Copyright © 2018 Ian McDowell. All rights reserved.
//

import UIKit

private let barHeight: CGFloat = 48
private let tabHeight: CGFloat = 33

protocol TabViewBarDataSource: class {
    var title: String? { get }
    var viewControllers: [UIViewController] { get }
    var visibleViewController: UIViewController? { get }
    var hidesSingleTab: Bool { get }
}

protocol TabViewBarDelegate: class {
    func activateTab(_ tab: UIViewController)
	func detachTab(_ tab: UIViewController)
    func closeTab(_ tab: UIViewController)
    func insertTab(_ tab: UIViewController, atIndex index: Int)
	func wantsCloseButton(for tab: UIViewController) -> Bool
	var allowsDraggingLastTab: Bool { get }
    var dragInProgress: Bool { get set }
}

/// This is a modified version of TabViewBar.
/// It does not include navigation bar emulation.
class TabViewBar: UIView {

    /// Object that provides tabs & a title to the bar.
    weak var barDataSource: TabViewBarDataSource?

    /// Object that reacts to tabs being moved, activated, or closed by the user.
    weak var barDelegate: TabViewBarDelegate?

    var theme: TabViewTheme {
        didSet { self.applyTheme(theme) }
    }

	lazy var minimumBarItemWidth: CGFloat? =
		{
			return UIDevice.current.userInterfaceIdiom == .phone ? 24.0 : 30.0
		}()

    /// The bar has a visual effect view with a blur effect determined by the current theme.
    /// This tries to match UINavigationBar's blur effect as best as it can.
    private let visualEffectView: UIVisualEffectView

    /// Collection view containing the tabs from the data source
    private let tabCollectionView: TabViewTabCollectionView

    /// View below the tabCollectionView that is a 1px separator
    private let separator: UIView

    /// Constraint that places the top of the tabCollectionView.
    /// Constant is adjusted when the view should be hidden, which causes the bar to resize.
    private var tabTopConstraint: NSLayoutConstraint?

    /// Create a new tab view bar with the given theme.
    init(theme: TabViewTheme) {
        self.theme = theme

        // Start with no effect, this is set in applyTheme
        self.visualEffectView = UIVisualEffectView(effect: nil)
        self.tabCollectionView = TabViewTabCollectionView(theme: theme)
        self.separator = UIView()

        super.init(frame: .zero)

        tabCollectionView.bar = self

        addSubview(visualEffectView)
        visualEffectView.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        // Lay out tab collection view
        tabCollectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tabCollectionView)
        let tabTopConstraint = tabCollectionView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor)
        self.tabTopConstraint = tabTopConstraint
        NSLayoutConstraint.activate([
            tabCollectionView.heightAnchor.constraint(equalToConstant: tabHeight),
            tabTopConstraint,
            tabCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tabCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tabCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        // Add separator below tab collection view
        separator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separator)
        NSLayoutConstraint.activate([
            separator.heightAnchor.constraint(equalToConstant: 0.5).withPriority(.defaultHigh),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        applyTheme(theme)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func applyTheme(_ theme: TabViewTheme) {
        self.backgroundColor = theme.barTintColor.withAlphaComponent(0.7)
        self.visualEffectView.effect = UIBlurEffect.init(style: theme.barBlurStyle)
        self.separator.backgroundColor = theme.separatorColor
        self.tabCollectionView.theme = theme
    }

    /// Add a new tab at the given index. Animates.
    func addTab(atIndex index: Int) {
        tabCollectionView.performBatchUpdates({
            tabCollectionView.insertItems(at: [IndexPath.init(item: index, section: 0)])
        }, completion: nil)
        self.hideTabsIfNeeded()
    }

    /// Remove the view for the tab at the given index. Animates.
    func removeTab(atIndex index: Int) {
        tabCollectionView.performBatchUpdates({
            tabCollectionView.deleteItems(at: [IndexPath.init(item: index, section: 0)])
        }, completion: nil)
        self.hideTabsIfNeeded()
    }

    /// Deselects other selected tabs, then selects the given tab and scrolls to it. Animates.
    func selectTab(atIndex index: Int) {
        if let indexPaths = tabCollectionView.indexPathsForSelectedItems {
            for indexPath in indexPaths where indexPath.item != index {
                tabCollectionView.deselectItem(at: indexPath, animated: true)
            }
        }
        tabCollectionView.selectItem(at: IndexPath.init(item: index, section: 0), animated: true, scrollPosition: .centeredHorizontally)
    }

    /// If there are less than the required number of tabs to keep the bar visible, hide it.
    /// Otherwise, un-hide it.
    func hideTabsIfNeeded() {
        // To hide, the bar is moved up by its height, then set to isHidden.
        let minimum = (barDataSource?.hidesSingleTab ?? true) ? 1 : 0
        let shouldHide = tabCollectionView.numberOfItems(inSection: 0) <= minimum
        if shouldHide && !tabCollectionView.isHidden {
            tabCollectionView.isHidden = true
            tabTopConstraint?.constant = -tabHeight
        } else if !shouldHide && tabCollectionView.isHidden {
            tabCollectionView.isHidden = false
            tabTopConstraint?.constant = 0
        }
    }

    /// Update all visible tabs' titles.
    func updateTitles() {
        tabCollectionView.updateVisibleTabs()
    }

    /// Force a reload of all visible data. Maintains current tab if possible.
    func refresh() {
        tabCollectionView.reloadData()
        updateTitles()
        hideTabsIfNeeded()

        if let visibleVC = barDataSource?.visibleViewController, let index = barDataSource?.viewControllers.index(of: visibleVC) {
            self.selectTab(atIndex: index)
        }
    }
}
