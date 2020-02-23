import UIKit
import RxSwift
import RxCocoa

class PostDetailsViewController: UIViewController {
    private let disposeBag = DisposeBag()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentInset = UIEdgeInsets(top: 15, left: 20, bottom: 15, right: 20)
        return scrollView
    }()
    
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alignment = .fill
        view.axis = .vertical
        view.spacing = 15
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12)
        label.textColor = .darkGray
        label.numberOfLines = 0
        return label
    }()
    
    private let userLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12)
        label.textColor = .gray
        label.numberOfLines = 0
        return label
    }()
    
    private let commentsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 11)
        label.textColor = .gray
        label.numberOfLines = 0
        return label
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .whiteLarge)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.color = UIColor.darkGray
        view.hidesWhenStopped = true
        return view
    }()
    
    let viewModel: PostDetailsViewModelType
    
    init(viewModel: PostDetailsViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        setupUI()
        connectModule()
    }
    
    func setupUI() {
        
        self.view.addSubview(self.scrollView)
        self.scrollView.addSubview(self.stackView)
        self.view.addSubview(self.activityIndicator)
        
        self.stackView.addArrangedSubview(self.titleLabel)
        self.stackView.addArrangedSubview(self.bodyLabel)
        self.stackView.addArrangedSubview(self.userLabel)
        self.stackView.addArrangedSubview(self.commentsLabel)
        
        let scrollViewHorizontalInsets = self.scrollView.contentInset.left + self.scrollView.contentInset.right
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -scrollViewHorizontalInsets)
            
            ])
    }
    
    func connectModule() {
        let moduleLoadedInput = Driver.just(PostDetailsDisplayInput.moduleLoaded)
        
        let outputs = self.viewModel.connect(moduleLoadedInput)
        
        let displayItem = outputs
            .distinctUntilChanged()
            .flatMap { [weak self] (display) -> Driver<PostDetailsDisplayItem> in
                switch display {
                case .display(let displayItem):
                    return .just(displayItem.item)
                case .error(error: let error):
                    self?.showError(error: error, okAction: nil)
                    return .empty()
                default: return .empty()
                }
        }
        
        outputs.map { $0.item?.navigationTitle ?? "" }
            .drive(self.rx.title)
            .disposed(by: disposeBag)
        
        outputs.map { $0.isLoading }
            .drive(self.activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        displayItem.map { $0.title }.drive(self.titleLabel.rx.text).disposed(by: disposeBag)
        displayItem.map { $0.body }.drive(self.bodyLabel.rx.text).disposed(by: disposeBag)
        displayItem.map { $0.author }.drive(self.userLabel.rx.text).disposed(by: disposeBag)
        displayItem.map { $0.totalCommentsTitle }.drive(self.commentsLabel.rx.text).disposed(by: disposeBag)
    }

}
