//
//  ThirdViewController.swift
//  VideoSharing1
//
//  Created by 1 on 11.04.17.
//  Copyright © 2017 1. All rights reserved.
//
import UIKit

class ThirdViewController: VideosTableViewController {
    
    @IBOutlet weak var logoutBarButton: UIBarButtonItem?
    @IBOutlet weak var flexibleSpaceBarButtonItem: UIBarButtonItem?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.toolbar.isHidden = false
        toolbarItems = [flexibleSpaceBarButtonItem!, logoutBarButton!, flexibleSpaceBarButtonItem!]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if videos.count == 0 {
            self.refreshVideos(self.refreshControl!)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedVideo = videos[(indexPath as NSIndexPath).row]
        performSegue(withIdentifier: VideoSegue, sender: nil)
    }
    
    //MARK: Actions
    
    @IBAction func refreshVideos(_ sender: UIRefreshControl) {
        
        APIManager.getVideoFeedForCurrentUser(limit: 99, completionHandler: { (error, videos) in
            DispatchQueue.main.async(execute: {
                sender.endRefreshing()
            })
            if let videoList = videos {
                self.videos = videoList.sorted { $0.dateAdded! > $1.dateAdded! }
                self.tableView.reloadData()
            }
        })
    }
    
    @IBAction func logoutUser(_ sender: AnyObject) {
        APIManager.logoutUser { error in
            if error == nil {
                DispatchQueue.main.async {
                    _ = self.navigationController?.popViewController(animated: true)
                }
            } else {
                let alert = UIAlertController.init(title: "Network error", message: "Try again please", preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: nil))
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}
