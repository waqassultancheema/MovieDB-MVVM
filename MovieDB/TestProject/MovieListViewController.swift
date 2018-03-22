//
//  ViewController.swift
//  TestProject
//
//  Created by Muhammad Waqas  on 3/06/18.
//  Copyright © 2018 Emaar . All rights reserved.
//

import UIKit
import SDWebImage
import RMPZoomTransitionAnimator

class MovieListViewController: UIViewController {

    // MARK: - Propertiesa

    @IBOutlet weak var collectionView: UICollectionView!

    var movieListViewModel: MovieListViewModel?
 
    fileprivate let segueId = "goToFilter"
    
    private var page = 1
    private var gotData = false
    private var isFilterApplied = false
    private var minYear: String = "0"
    private var maxYear: String = "0"

    private var mURL: String {
        if isFilterApplied == true {
            let url = String(format: Constant.MOVIE_FILTER_URL.path + "&primary_release_date.gte=%@&primary_release_date.lte=%@&page=\(page)", minYear,maxYear)
            return url
        } else {
            let url = String(format: Constant.MOVIE_URL.path + "&page=\(page)")
            return url
        }
    }
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       configureController()
       
    }
    
    func configureController() {
        handleMoviesServicesResponse()
        getStoresForPage(page: page)
        collectionView.delegate = movieListViewModel
        collectionView.dataSource = movieListViewModel
        handleMoveViewModelResponse()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueId {
            if let filterVC = segue.destination as? FiltersViewController {
                filterVC.filterVM = FilterViewModel()
                filterVC.delegate = self
            }
        }
    }
}

extension MovieListViewController {
    
    // MARK: - Network

    func getStoresForPage(page: Int) {
        self.gotData = false
        HUD.show(view: view)
        movieListViewModel?.initFetch(url: mURL)
    }
    
    func handleMoviesServicesResponse() {
        movieListViewModel?.movieSuccess = { [weak self] () in
            HUD.hide(view: self?.view)
            self?.gotData = true
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
        movieListViewModel?.movieError = { [weak self] (error) in
            guard error != nil else {
                return
            }
            self?.showAlertInViewController(titleStr: Constant.Alert.title, messageStr: (error?.localizedDescription)! , okButtonTitle: Constant.Alert.ok)
        }
        
        
    }
    
    
    
}

extension MovieListViewController {
    
    func handleMoveViewModelResponse() {
        movieListViewModel?.didSelectCell =  {(viewContoller) -> () in
            if let viewCt = viewContoller {
                self.present(viewCt, animated: true, completion: {
                    
                })
            }
        }
    }
}

extension MovieListViewController:  UIScrollViewDelegate {
    
    // MARK: - UICollectionViewDataSource
    
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.size.height {
            if self.gotData == true {
                page = page + 1
                Logger.log(message: "PAGE: \(page)")
                getStoresForPage(page: page)
            }
        }
    }
}

extension MovieListViewController: FilterViewDelegate {
    
    func applyFilter(minYear: Int, maxYear: Int) {
         page = 1
         isFilterApplied = true
         self.movieListViewModel?.resetMovies()
         self.minYear = String(minYear)
         self.maxYear = String(maxYear)
         getStoresForPage(page: page)
    }
    func resetFilter() {
         page = 1
         isFilterApplied = false
         self.movieListViewModel?.resetMovies()
         getStoresForPage(page: page)
    }

}



