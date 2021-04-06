//
//  FeedViewController.swift
//  SNReels
//
//  Created by Sanjeeb on 05/04/21.
//

import UIKit

class FeedViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private let viewModel = FeedViewModel()
    private var data = [Feed]()
    private let cellId = "FeedTableViewCell"
    @objc dynamic var currentIndex = 0
    private var oldAndNewIndices = (0,0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.setAudioMode()
        data = viewModel.getFeed()
        setupView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let cell = tableView.visibleCells.first as? FeedTableViewCell {
            cell.play()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let cell = tableView.visibleCells.first as? FeedTableViewCell {
            cell.pause()
        }
    }
    func setupView(){
        // Table View
       
        tableView.backgroundColor = .white
        tableView.tableFooterView = UIView()
        tableView.isPagingEnabled = true
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        
        tableView.register(UINib(nibName: "FeedTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.prefetchDataSource = self
    }

}
extension FeedViewController:  UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! FeedTableViewCell
        cell.setup(feed: data[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? FeedTableViewCell {
            oldAndNewIndices.1 = indexPath.row
            currentIndex = indexPath.row
            cell.pause()
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Pause the video if the cell is ended displaying
        if let cell = cell as? FeedTableViewCell {
            cell.pause()
        }
    }
}
// MARK: - ScrollView Extension
extension FeedViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let cell = self.tableView.cellForRow(at: IndexPath(row: self.currentIndex, section: 0)) as? FeedTableViewCell
        cell?.replay()
    }
    
}
