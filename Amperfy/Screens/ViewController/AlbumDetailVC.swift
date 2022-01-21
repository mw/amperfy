import UIKit

class AlbumDetailVC: SingleFetchedResultsTableViewController<SongMO> {

    var album: Album!
    private var fetchedResultsController: AlbumSongsFetchedResultsController!
    private var detailOperationsView: AlbumDetailTableHeader?

    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate.userStatistics.visited(.albumDetail)
        fetchedResultsController = AlbumSongsFetchedResultsController(forAlbum: album, managedObjectContext: appDelegate.persistentStorage.context, isGroupedInAlphabeticSections: false)
        singleFetchedResultsController = fetchedResultsController
        
        configureSearchController(placeholder: "Search in \"Album\"", scopeButtonTitles: ["All", "Cached"])
        tableView.register(nibName: AlbumSongTableCell.typeName)
        tableView.rowHeight = AlbumSongTableCell.albumSongRowHeight
        
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: AlbumDetailTableHeader.frameHeight + LibraryElementDetailTableHeaderView.frameHeight))
        if let albumDetailTableHeaderView = ViewBuilder<AlbumDetailTableHeader>.createFromNib(withinFixedFrame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: AlbumDetailTableHeader.frameHeight)) {
            albumDetailTableHeaderView.prepare(toWorkOnAlbum: album, rootView: self)
            tableView.tableHeaderView?.addSubview(albumDetailTableHeaderView)
            detailOperationsView = albumDetailTableHeaderView
        }
        if let libraryElementDetailTableHeaderView = ViewBuilder<LibraryElementDetailTableHeaderView>.createFromNib(withinFixedFrame: CGRect(x: 0, y: AlbumDetailTableHeader.frameHeight, width: view.bounds.size.width, height: LibraryElementDetailTableHeaderView.frameHeight)) {
            libraryElementDetailTableHeaderView.prepare(playableContainer: album, with: appDelegate.player)
            tableView.tableHeaderView?.addSubview(libraryElementDetailTableHeaderView)
        }
        
        swipeCallback = { (indexPath, completionHandler) in
            let song = self.fetchedResultsController.getWrappedEntity(at: indexPath)
            completionHandler([song])
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchDetails(of: album) {
            self.detailOperationsView?.refresh()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AlbumSongTableCell = dequeueCell(for: tableView, at: indexPath)
        let song = fetchedResultsController.getWrappedEntity(at: indexPath)
        cell.display(song: song, rootView: self)
        return cell
    }
    
    override func updateSearchResults(for searchController: UISearchController) {
        fetchedResultsController.search(searchText: searchController.searchBar.text ?? "", onlyCachedSongs: searchController.searchBar.selectedScopeButtonIndex == 1 )
        tableView.reloadData()
    }
    
}
