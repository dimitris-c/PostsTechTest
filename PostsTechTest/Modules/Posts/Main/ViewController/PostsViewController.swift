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
        view.register(PostTableViewCell.self, forCellReuseIdentifier: PostTableViewCell.identifier)
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
        
        let postSelection = tableView.rx
            .modelSelected(PostDisplayItem.self)
            .map { PostsDisplayInput.postSelected(id: $0.id) }
            .asDriver(onErrorDriveWith: .empty())
        
        let displayInputs = Driver.merge(moduleLoadedInput, postSelection)
        let outputs = self.viewModel.connect(displayInputs)
        
        let items = outputs
            .distinctUntilChanged()
            .do(onNext: { [weak self] (display) in
                guard let error = display.error else { return }
                self?.showError(error: error, okAction: nil)
            })
            .map { (display) -> [PostDisplayItem] in
                switch display {
                case .display(let items):
                    return items.posts
                default: return []
                }
        }
        
        outputs.map { $0.item?.navigationTitle ?? "" }
            .drive(self.rx.title)
            .disposed(by: disposeBag)
        
        outputs.map { $0.isLoading }
            .drive(self.activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        items.drive(self.tableView.rx.items(cellIdentifier: PostTableViewCell.identifier, cellType: PostTableViewCell.self)) { row, item, cell in
            cell.configure(item: item)
        }.disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [tableView] (indexPath) in
                tableView.deselectRow(at: indexPath, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
}
