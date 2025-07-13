//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Сергей Розов on 18.05.2025.
//

import UIKit

final class ImagesListCell: UITableViewCell {    

    // MARK: - Public Properties
    static let reuseIdentifier = "ImagesListCell"
    
    // MARK: - Constants
    private enum ImagesListCellConstants {
        enum Layout {
            static let cellSize: CGFloat = 200
            static let buttonSize: CGFloat = 44
            static let gradientSize: CGFloat = 30
            static let leadingPadding: CGFloat = 16
            static let trailingPadding: CGFloat = -16
            static let topPadding: CGFloat = 4
            static let bottomPadding: CGFloat = -4
            static let leadingLabelSpacing: CGFloat = 8
            static let bottomLabelSpacing: CGFloat = -8
        }
    }
    
    // MARK: - UI Elements
    let cellImage: UIImageView = {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 16
            return imageView
        }()
    
    let gradientView: UIView = {
            let view = UIView()
            view.clipsToBounds = true
            view.layer.cornerRadius = 16
            return view
        }()
    
    let dateLabel: UILabel = {
            let label = UILabel()
            label.textColor = .white
            label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            return label
        }()
    
    let likeButton: UIButton = {
            let button = UIButton(type: .custom)
            return button
        }()
    
    private let gradientLayer = CAGradientLayer()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        
        addSubviews()
        setupLayout()
        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    private func addSubviews() {
        [cellImage].forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
                contentView.addSubview($0)
            }

            [gradientView, dateLabel, likeButton].forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
                cellImage.addSubview($0)
            }
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            cellImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: ImagesListCellConstants.Layout.topPadding),
            cellImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: ImagesListCellConstants.Layout.bottomPadding),
            cellImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ImagesListCellConstants.Layout.leadingPadding),
            cellImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: ImagesListCellConstants.Layout.trailingPadding),
            cellImage.heightAnchor.constraint(equalToConstant: ImagesListCellConstants.Layout.cellSize),
            
            gradientView.leadingAnchor.constraint(equalTo: cellImage.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: cellImage.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: cellImage.bottomAnchor),
            gradientView.heightAnchor.constraint(equalToConstant: ImagesListCellConstants.Layout.gradientSize),
            
            dateLabel.leadingAnchor.constraint(equalTo: cellImage.leadingAnchor, constant: ImagesListCellConstants.Layout.leadingLabelSpacing),
            dateLabel.bottomAnchor.constraint(equalTo: cellImage.bottomAnchor, constant: ImagesListCellConstants.Layout.bottomLabelSpacing),
            
            likeButton.topAnchor.constraint(equalTo: cellImage.topAnchor),
            likeButton.trailingAnchor.constraint(equalTo: cellImage.trailingAnchor),
            likeButton.widthAnchor.constraint(equalToConstant: ImagesListCellConstants.Layout.buttonSize),
            likeButton.heightAnchor.constraint(equalToConstant: ImagesListCellConstants.Layout.buttonSize)
        ])
    }
    
    private func setupGradient() {
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.5).cgColor
        ]
        gradientView.layer.addSublayer(gradientLayer)
    }
    
    // MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = gradientView.bounds
    }
}
