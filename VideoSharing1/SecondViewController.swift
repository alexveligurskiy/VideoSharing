//
//  SecondViewController.swift
//  VideoSharing1
//
//  Created by 1 on 09.04.17.
//  Copyright © 2017 1. All rights reserved.
//


import UIKit
import AVKit
import AVFoundation

class SecondViewController: VideosTableViewController {
    
        override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if videos.count == 0 {
            self.refreshVideos(self.refreshControl!)
        }
       
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if ((indexPath as NSIndexPath).row + 2) == self.videos.count && self.videos.count > 0 {
            APIManager.getNewVideoList(limit: 10, offset: self.videos.count) { (error, videos) in
                if let videoList = videos {
                    self.upadateTableView(videoList: videoList.sorted { $0.dateAdded! > $1.dateAdded! })
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedVideo = videos[(indexPath as NSIndexPath).row]
        performSegue(withIdentifier: VideoSegue, sender: nil)
    }
    
    
    @IBAction func refreshVideos(_ sender: UIRefreshControl) {
        APIManager.getNewVideoList(limit: 10, offset: 0) { (error,videos) in
            DispatchQueue.main.async(execute: {
                sender.endRefreshing()
            })
            if let videoList = videos {
                self.videos = videoList.sorted { $0.dateAdded! > $1.dateAdded! }
                self.tableView.reloadData()
            }
        }
    }
}


