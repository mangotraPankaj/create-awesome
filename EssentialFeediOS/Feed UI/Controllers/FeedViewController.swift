//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Pankaj Mangotra on 13/09/21.
//

import Foundation
import UIKit

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    var refreshController: FeedRefreshViewController?
    var tableModel = [FeedImageCellController]() {
        didSet { tableView.reloadData() }
    }

    private var tasks = [IndexPath: FeedImageDataLoaderTask]()

    override public func viewDidLoad() {
        super.viewDidLoad()

        refreshControl = refreshController?.view

        tableView.prefetchDataSource = self
        refreshController?.refresh()
    }

    override public func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return tableModel.count
    }

    override public func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellController(forRowAt: indexPath).view()
    }

    override public func tableView(_: UITableView, didEndDisplaying _: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelCellControllerLoad(forRowAt: indexPath)
    }

    public func tableView(_: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preload()
        }
    }

    public func tableView(_: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellControllerLoad)
    }

    private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
        return tableModel[indexPath.row]
    }

    private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath).cancelLoad()
    }
}
