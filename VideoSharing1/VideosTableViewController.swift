//
//  VideosTableViewController.swift
//  VideoSharing1
//
//  Created by 1 on 12.04.17.
//  Copyright © 2017 1. All rights reserved.
//


import UIKit
import AVKit
import AVFoundation

let VideoSegue = "Play"

class VideosTableViewController: UITableViewController {
    
    var videos = [Video]()
    weak var selectedVideo: Video?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up tableView
        tableView.register(UINib(nibName: String(describing: VideoCell.self), bundle: Bundle.main), forCellReuseIdentifier: String(describing: VideoCell.self))
        tableView.contentInset.top = UIApplication.shared.statusBarFrame.height
        tableView.tableFooterView = UIView()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == VideoSegue {
            let playerViewController = segue.destination as! AVPlayerViewController
            let playerItem = AVPlayerItem(url: URL(string: selectedVideo!.videoURL!)!)
            playerViewController.player = AVPlayer(playerItem: playerItem)
            playerViewController.player?.play()
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    //MARK: UITableViewDelegate and UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: VideoCell.self)) as! VideoCell
        let video = videos[(indexPath as NSIndexPath).row]
        cell.nameLabel.text = video.title
        cell.likesLabel.text = "\(video.likesCount) likes"
        if let thumbnailData = video.thumbnail {
            cell.videoPreview.image = UIImage(data: thumbnailData as Data)
        } else {
            cell.videoPreview.image = nil
            APIManager.getThumbnailForVideo(video, completionHandler: {
                DispatchQueue.main.async {
                    self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.left)
                }
            })
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let video = videos[(indexPath as NSIndexPath).row]
        let previewHeightToWidthRatio = CGFloat(video.height / video.width)
        let previewHeight = tableView.bounds.width * previewHeightToWidthRatio
        return kCellHeight + previewHeight
    }
    
    func upadateTableView(videoList: [Video]) {
        var indexPaths = [IndexPath]()
        
        //temp workaround when willDisplay cell called twice
        if (self.videos.last?.title == videoList.last?.title) {
            return
        }
        
        let fromCount = self.videos.count
        self.videos += videoList
        let toCount = self.videos.count
        
        for i in fromCount...toCount-1 {
            indexPaths.append(IndexPath.init(row: i, section: 0))
        }
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: indexPaths, with: .none)
            self.tableView.endUpdates()
        }
    }
}

