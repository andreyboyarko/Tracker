import UIKit

final class OnboardingPageController: UIViewController {
    // MARK: - UI
    private var pageVC: UIPageViewController!
    private var pages: [UIViewController] = []
    private let pageControl = UIPageControl()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupPages()
        setupPageVC()
        setupPageControl()
    }

    // MARK: - Setup
    private func setupPages() {
        let first = OnboardingViewController(
            title: L10n.onboardingTitle1,
            image: Asset.onboarding1.image
        )
        let second = OnboardingViewController(
            title: L10n.onboardingTitle2,
            image: Asset.onboarding2.image
        )
        pages = [first, second]
    }
    
    private func setupPageVC() {
        let vc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        vc.dataSource = self
        vc.delegate   = self
        vc.setViewControllers([pages[0]], direction: .forward, animated: false)

        addChild(vc)
        view.addSubview(vc.view)
        vc.didMove(toParent: self)

        vc.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vc.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            vc.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            vc.view.topAnchor.constraint(equalTo: view.topAnchor),
            vc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        pageVC = vc
    }

    private func setupPageControl() {
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .label
        pageControl.pageIndicatorTintColor = UIColor.label.withAlphaComponent(0.3)

        view.addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            // отступ как в макете (можешь подправить при необходимости)
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -134)
        ])
    }
}

// MARK: - UIPageViewControllerDataSource
extension OnboardingPageController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let idx = pages.firstIndex(of: viewController) else { return nil }
        let prev = idx - 1
        return prev >= 0 ? pages[prev] : nil
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let idx = pages.firstIndex(of: viewController) else { return nil }
        let next = idx + 1
        return next < pages.count ? pages[next] : nil
    }
}

// MARK: - UIPageViewControllerDelegate
extension OnboardingPageController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        guard completed,
              let current = pageViewController.viewControllers?.first,
              let idx = pages.firstIndex(of: current) else { return }
        pageControl.currentPage = idx
    }
}
