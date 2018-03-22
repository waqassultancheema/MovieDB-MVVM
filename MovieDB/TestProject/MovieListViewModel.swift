//
//  MovieListViewModel.swift
//  TestProject
//
//  Created by Muhammad Waqas Bhati on 3/18/18.
//  Copyright © 2018 Emaar . All rights reserved.
//

import Foundation
import UIKit

class MovieListViewModel : NSObject {
    
    //MARK: Instance
    private var dataAccessManager: MovieAPI?
    var movieSuccess: (() -> ())?
    var movieError: ((NetworkError?) -> ())?
    
    var didSelectCell: ((MovieDetailViewController?) -> ())?
       fileprivate let movieCellId = "MovieCellId"
    fileprivate let placeHolderIcon = "placeholder.png"
    fileprivate let movieDetailControllerID = "MovieDetailViewController"
    private var cellViewModels: [MovieViewModel] = [MovieViewModel]() {
        didSet {
            self.movieSuccess?()
        }
    }
    private var error: NetworkError? {
        didSet {
            self.movieError?(error)
        }
    }
    
    //MARK: Initializers
    
    init(cellVM: [MovieViewModel]) {
        self.cellViewModels = cellVM
    }
    required init( apiService: MovieAPI?) {
        self.dataAccessManager = apiService
    }
    
    //MARK: Helper Methds
    
    func getTotalMovies() -> Int {
        return cellViewModels.count
    }
    func resetMovies() {
        return cellViewModels.removeAll()
    }
    func getCellViewModel( at indexPath: IndexPath ) -> MovieViewModel {
        return cellViewModels[indexPath.row]
    }
    func initFetch(url: String) {
        dataAccessManager?.getMoviesList(url: url, completion: { [weak self] (movieContainer, error) in
            self?.processFetchedData(movieContainer: (movieContainer as? MovieContainer)!, error: error)
        })
        
    }
    private func processFetchedData( movieContainer: MovieContainer , error: NetworkError?) {
        guard error == nil else {
            self.error = error!
            return
        }
        var vms = [MovieViewModel]()
        for movie in movieContainer.results {
            vms.append(MovieViewModel(id: movie.id, imageURL: movie.poster_path, title: movie.title))
        }
        let total = self.cellViewModels + vms
        self.cellViewModels = total
    }
    

}


extension MovieListViewModel :  UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.getTotalMovies()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: movieCellId, for: indexPath) as! MovieCollectionViewCell
        let movieVM = self.getCellViewModel(at: indexPath)
        cell.titleLabel.text = movieVM.title
        let url = movieVM.imageURL
        cell.posterImgView.sd_setImage(with: URL(string: Constant.makeImagePath(url: url)), placeholderImage: UIImage(named: placeHolderIcon))
        
        return cell
        
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
                let movieVM = self.getCellViewModel(at: indexPath)
                    let cell = collectionView.cellForItem(at: indexPath) as! MovieCollectionViewCell
                    let storboard  = UIStoryboard.init(name: "Main", bundle: nil)
                    if let controller = storboard.instantiateViewController(withIdentifier: movieDetailControllerID) as? MovieDetailViewController {
                        controller.movieDetailViewModel = MovieDetailViewModel(movieID: movieVM.id, movieImage: cell.posterImgView.image ?? UIImage(), apiService: MovieDetailAPI())
                        self.didSelectCell!(controller)
                    }
        
    }
    
}

struct MovieViewModel {
    var id: Int
    var imageURL: String
    var title: String
}
