//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Pankaj Mangotra on 04/10/21.
//

import UIKit

final class FeedImageCellController {
    private var viewModel: FeedImageViewModel<UIImage>

    init(viewModel: FeedImageViewModel<UIImage>) {
        self.viewModel = viewModel
    }

    private func binded(_ cell: FeedImageCell) -> FeedImageCell {
        cell.locationContainer.isHidden = !viewModel.hasLocation
        cell.descriptionLabel.text = viewModel.description
        cell.locationLabel.text = viewModel.location
        cell.descriptionLabel.text = viewModel.description
        cell.onRetry = viewModel.loadImageData

        viewModel.onImageLoad = { [weak cell] image in
            cell?.feedImageView.image = image
        }

        viewModel.onImageLoadingStateChange = { [weak cell] isLoading in
            cell?.feedImageContainer.isShimmering = isLoading
        }

        viewModel.onShouldRetryLoadingStateChange = { [weak cell] shouldRetry in
            cell?.feedImageRetryButton.isHidden = !shouldRetry
        }

        return cell
    }

    func view() -> UITableViewCell {
        let cell = binded(FeedImageCell())
        viewModel.loadImageData()
        return cell
    }

    func preload() {
        viewModel.loadImageData()
    }

    func cancelLoad() {
        viewModel.cancelImageDataLoad()
    }
}
