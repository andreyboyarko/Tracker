//
//
//import UIKit
//
//final class SplashViewController: UIViewController {
//    
//    private let logo: UIImageView = {
//        let logo = UIImageView(image: UIImage(resource: .logo))
//        logo.translatesAutoresizingMaskIntoConstraints = false
//        return logo
//    }()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .systemBackground
//        
//        view.addSubview(logo)
//        NSLayoutConstraint.activate([
//            logo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            logo.centerYAnchor.constraint(equalTo: view.centerYAnchor)
//        ])
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        
//        // Небольшая задержка/анимация, чтобы показать логотип
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            self.navigateToTabBarController()
//        }
//    }
//    
//    private func navigateToTabBarController() {
//        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
//              let window = sceneDelegate.window else {
//            return
//        }
//        
//        let controller = TabBarController() // если у тебя TabBarController кодом
//        // let controller = UIStoryboard(name: "Main", bundle: .main)
//        //     .instantiateViewController(withIdentifier: "TabBarViewController") // если через storyboard
//        
//        window.rootViewController = controller
//        window.makeKeyAndVisible()
//    }
//}
//
