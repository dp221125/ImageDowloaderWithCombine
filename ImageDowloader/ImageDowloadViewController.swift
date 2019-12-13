//
//  ImageDowloadViewController.swift
//  ImageDowloader
//
//  Created by Seokho on 2019/12/13.
//  Copyright © 2019 Seokho. All rights reserved.
//

import UIKit
import Combine

class ImageDowloadViewController: UIViewController {
    
    private var isCombine = false
    private var downTask: URLSessionDataTask?
    private var combineTask: AnyCancellable?
    
    @IBOutlet weak var combineButton: UIButton!
    @IBOutlet weak var imageView: UIImageView! 
    @IBOutlet weak var indicatorVIew: UIActivityIndicatorView!
    @IBOutlet weak var changeMode: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var clearView: UIView!
    
    @IBAction func stopImageVIew(_ sender: UIButton) {
        self.indicatorVIew.stopAnimating()
        self.clearView.isHidden = false
        self.changeMode.isEnabled = true
        if self.isCombine {
            self.combineTask?.cancel()
        } else {
            self.downTask?.cancel()
            self.downTask = nil
        }
    }
    
    @IBAction func downImage() {
        self.indicatorVIew.startAnimating()
        self.clearView.isHidden = true
        self.changeMode.isEnabled = false
        
        if self.isCombine {
            loadImageWithCombine()
        } else {
            DispatchQueue.global().async {
                self.loadImageWithNormal()
            }
        }
    }
    
    @IBAction func onCombineMode() {
        self.isCombine = !self.isCombine
        self.titleLabel.text = self.isCombine ? "Combine" : "Normal"
        self.combineButton.setTitle(self.isCombine ? "Combine Off" : "Combine On", for: .normal)
    }
    
    @IBAction func imageVIewClear(_ sender: UIButton) {
        self.imageView.image = nil
    }
    
    private func loadImageWithNormal() {
        
        if downTask != nil {
            downTask?.cancel()
            downTask = nil
        }
        
        let url = URL(string:  "https://picsum.photos/1920/1080/?random")
        let downTask = URLSession.shared.dataTask(with: url!) { (data, _, error) in
            if error == nil {
                do {
                    let image = UIImage(data: data!)
                    DispatchQueue.main.async {
                        self.indicatorVIew.stopAnimating()
                        self.imageView.image = image
                        self.changeMode.isEnabled = true
                        self.clearView.isHidden = false
                    }
                }
            } else {
                if error!._code != NSURLErrorCancelled {
                    DispatchQueue.main.async {
                        self.indicatorVIew.stopAnimating()
                        self.imageView.image = UIImage(systemName: "photo")
                        self.changeMode.isEnabled = true
                        self.clearView.isHidden = false
                    }
                }
            }
        }
        self.downTask = downTask
        
        downTask.resume()
    }
    
    
    private func loadImageWithCombine() {
        let url = URL(string: "https://picsum.photos/1920/1080/?random")!
        
        let downTask =  URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .catch { _ in Just(UIImage(systemName: "photo"))}
            .map({ $0 ?? UIImage(systemName: "photo") })
            .receive(on: DispatchQueue.main)
            .sink { image in
                self.indicatorVIew.stopAnimating()
                self.imageView.image = image
                self.changeMode.isEnabled = true
                self.clearView.isHidden = false
        }
        self.combineTask = downTask
    }
    
    
    override func viewDidLayoutSubviews() {
        self.imageView.layer.cornerRadius = 30
        self.indicatorVIew.layer.cornerRadius = 32
    }
    
}


