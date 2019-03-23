import UIKit
import RxSwift
import RxCocoa

class PostsViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let viewModel: PostsViewModelType
    
    private let tableView: UITableView = {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.estimatedRowHeight = 44
        view.rowHeight = UITableView.automaticDimension
        view.separatorInset = .zero
        view.tableFooterView = UIView()
        view.register(UITableViewCell.self, forCellReuseIdentifier: "postCell.id")
        return view
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .whiteLarge)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.color = UIColor.darkGray
        view.hidesWhenStopped = true
        return view
    }()
    
    init(viewModel: PostsViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        self.setupUI()
        self.connectModule()
    }
    
    func setupUI() {
        
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.activityIndicator)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.widthAnchor.constraint(equalTo: view.widthAnchor),
            tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            ])
    }
    
    func connectModule() {
        let moduleLoadedInput = Driver.just(PostsDisplayInput.moduleLoaded)
        
        let outputs = self.viewModel.connect(moduleLoadedInput)
        
        let items = outputs
            .distinctUntilChanged()
            .map { (display) -> [PostDisplayItem] in
                switch display {
                case .display(let items):
                    return items.posts
                default: return []
                }
        }
        
        outputs.map { $0.isLoading }
            .drive(self.activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        items.drive(self.tableView.rx.items(cellIdentifier: "postCell.id")) { row, item, cell in
            cell.textLabel?.text = item.title
        }.disposed(by: disposeBag)
    }
    
}
