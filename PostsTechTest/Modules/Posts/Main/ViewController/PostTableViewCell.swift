import UIKit

class PostTableViewCell: UITableViewCell {
    
    static let identifier: String = "postCell.id"
    
    private let postTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(postTitle)
        
        NSLayoutConstraint.activate([
            postTitle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            postTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            postTitle.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
            postTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15)
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(item: PostDisplayItem) {
        self.postTitle.text = item.title
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.postTitle.text = ""
    }
}
