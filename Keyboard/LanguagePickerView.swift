import UIKit

final class LanguagePickerView: UIView {

    var onSelect: ((Language) -> Void)?
    var onClose:  (() -> Void)?

    private var filtered: [Language] = [Languages.autoDetect] + Languages.all
    private let tableView   = UITableView(frame: .zero, style: .plain)
    private let searchField = UITextField()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        backgroundColor = UIColor { t in
            t.userInterfaceStyle == .dark
                ? UIColor(red: 0.14, green: 0.14, blue: 0.15, alpha: 1)
                : UIColor(red: 0.96, green: 0.96, blue: 0.98, alpha: 1)
        }

        let header = UIView()
        header.translatesAutoresizingMaskIntoConstraints = false
        addSubview(header)

        let titleLabel = UILabel()
        titleLabel.text      = "Translate to"
        titleLabel.font      = .systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = .secondaryLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(titleLabel)

        let closeBtn = UIButton(type: .system)
        closeBtn.setTitle("X", for: .normal)
        closeBtn.addTarget(self, action: #selector(close), for: .touchUpInside)
        closeBtn.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(closeBtn)

        searchField.placeholder = "Search languages..."
        searchField.borderStyle = .roundedRect
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.addTarget(self, action: #selector(searchChanged), for: .editingChanged)
        addSubview(searchField)

        tableView.dataSource = self
        tableView.delegate   = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.backgroundColor = .clear
        addSubview(tableView)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            header.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            header.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            header.heightAnchor.constraint(equalToConstant: 28),
            titleLabel.leadingAnchor.constraint(equalTo: header.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            closeBtn.trailingAnchor.constraint(equalTo: header.trailingAnchor),
            closeBtn.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            searchField.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 8),
            searchField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            searchField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            tableView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    @objc private func close() { onClose?() }

    @objc private func searchChanged() {
        let q = searchField.text ?? ""
        let all = [Languages.autoDetect] + Languages.all
        filtered = q.isEmpty ? all
            : all.filter { $0.name.lowercased().contains(q.lowercased()) }
        tableView.reloadData()
    }
}

extension LanguagePickerView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tv: UITableView, numberOfRowsInSection s: Int) -> Int { filtered.count }
    func tableView(_ tv: UITableView, cellForRowAt ip: IndexPath) -> UITableViewCell {
        let cell = tv.dequeueReusableCell(withIdentifier: "cell", for: ip)
        cell.textLabel?.text = filtered[ip.row].name
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.backgroundColor = .clear
        return cell
    }
    func tableView(_ tv: UITableView, didSelectRowAt ip: IndexPath) {
        tv.deselectRow(at: ip, animated: false)
        onSelect?(filtered[ip.row])
    }
}
