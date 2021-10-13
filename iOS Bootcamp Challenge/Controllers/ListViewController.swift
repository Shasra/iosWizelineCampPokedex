//
//  ListViewController.swift
//  iOS Bootcamp Challenge
//
//  Created by Jorge Benavides on 26/09/21.
//

import UIKit

class ListViewController: UICollectionViewController, UISearchBarDelegate, UINavigationBarDelegate {

    private var pokemons: [Pokemon] = []
    private var resultPokemons: [Pokemon] = []
    
    // User Default Key for last search
    static var userLastSearch: String {
        return "UserLastSearch"
    }
    
    private var lastPokemonsSearched = UserDefaults.standard.string(forKey: userLastSearch)

    // TODO: Use UserDefaults to pre-load the latest search at start

    private var latestSearch: String?

    lazy private var searchController: SearchBar = {
        let searchController = SearchBar("Search a pokemon", delegate: nil)
        latestSearch = lastPokemonsSearched
        searchController.text = latestSearch
        searchController.searchBar.delegate = self
        searchController.showsCancelButton = !searchController.isSearchBarEmpty
        return searchController
    }()

    private var isFirstLauch: Bool = true

    // TODO: Add a loading indicator when the app first launches and has no pokemons

    private var shouldShowLoader: Bool = true
    let activityView = UIActivityIndicatorView(style: .large)
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.view.addSubview(activityView)
        activityView.hidesWhenStopped = true
        activityView.center = self.view.center
        activityView.startAnimating()
        activityView.tintColor = .black

        DispatchQueue.main.async {
         UIView.animate(withDuration: 1, delay: 1, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
             self.collectionView?.reloadData()
             self.collectionView?.alpha = 1
             self.activityView.stopAnimating()
         }, completion: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setup()
        setupUI()
    }

    // MARK: Setup

    private func setup() {
        title = "Pokédex"

        // Customize navigation bar.
        guard let navbar = self.navigationController?.navigationBar else { return }

        navbar.tintColor = .black
        navbar.titleTextAttributes = [.foregroundColor: UIColor.black]
        navbar.prefersLargeTitles = true
        navbar.delegate = self

        // Set up the searchController parameters.
        navigationItem.searchController = searchController
        definesPresentationContext = true

        refresh()
    }

    private func setupUI() {

        // Set up the collection view.
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        collectionView.indicatorStyle = .white
        collectionView.delegate = self

        // Set up the refresh control as part of the collection view when it's pulled to refresh.
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        collectionView.sendSubviewToBack(refreshControl)
    }

    // MARK: - UISearchViewController

    private func filterContentForSearchText(_ searchText: String) {
        // filter with a simple contains searched text
        resultPokemons = pokemons
            .filter {
                searchText.isEmpty || $0.name.lowercased().contains(searchText.lowercased())
            }
            .sorted {
                $0.id < $1.id
            }

        collectionView.reloadData()
    }

    // MARK: SearchBar
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filterContentForSearchText(searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        UserDefaults.standard.set(searchBar.text, forKey: ListViewController.userLastSearch)
    }
    
    // MARK: - UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return resultPokemons.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PokeCell.identifier, for: indexPath) as? PokeCell
        else { preconditionFailure("Failed to load collection view cell") }
        cell.pokemon = resultPokemons[indexPath.item]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goDetailViewControllerSegue", sender: indexPath)
    }

    // MARK: - Navigation

    // TODO: Handle navigation to detail view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goDetailViewControllerSegue"  {
            if let navController = segue.destination as? DetailViewController {
                guard let indexPath = sender as? IndexPath  else { return }
                    navController.pokemon = self.resultPokemons[indexPath.row]
            }
        }
    }

    // MARK: - UI Hooks

    @objc func refresh() {
        shouldShowLoader = true

        var pokemons: [Pokemon] = []

        // TODO: Wait for all requests to finish before updating the collection view
        
        PokeAPI.shared.get(url: "pokemon?limit=30", type: PokemonList.self, onCompletion:  { (list: PokemonList?, _) in
            guard let list = list else { return }
            list.results.forEach { result in
                PokeAPI.shared.get(url: "/pokemon/\(result.id)/", type: Pokemon.self, onCompletion: { (pokemon: Pokemon?, _) in
                    guard let pokemon = pokemon else { return }
                    pokemons.append(pokemon)
                    self.pokemons = pokemons
                    if (self.pokemons.count == list.results.count) {
                        self.didRefresh()
                    }
                })
            }
        })
    }

    private func didRefresh() {
        shouldShowLoader = false

        guard
            let collectionView = collectionView,
            let refreshControl = collectionView.refreshControl
        else { return }

        refreshControl.endRefreshing()

        filterContentForSearchText("")
    }

}
