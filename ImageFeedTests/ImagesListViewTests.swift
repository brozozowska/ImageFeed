//
//  ImagesListViewTests.swift
//  ImageFeedTests
//
//  Created by Сергей Розов on 03.08.2025.
//

@testable import ImageFeed
import XCTest

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol?
    
    var viewDidLoadCalled = false
    var photosCountStub = 0
    var photoStub: Photo?
    
    var didSelectImageCalled = false
    var didSelectImageIndex: Int?
    
    var willDisplayCellCalled = false
    var willDisplayCellIndex: Int?
    
    var toggleLikeCalled = false
    var toggleLikeIndex: Int?
    
    var photosCount: Int {
        photosCountStub
    }
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func photo(at index: Int) -> Photo {
        photoStub ?? Photo(id: "", size: .zero, createdAt: nil, welcomeDescription: nil, thumbImageURL: "", largeImageURL: "", isLiked: false)
    }
    
    func formattedDate(at index: Int) -> String {
        return "date"
    }
    
    func heightForImage(at index: Int, tableViewWidth: CGFloat) -> CGFloat {
        return 0
    }
    
    func didSelectImage(at index: Int) {
        didSelectImageCalled = true
        didSelectImageIndex = index
        
        if let photo = photoStub,
           let url = URL(string: photo.largeImageURL) {
            let indexPath = IndexPath(row: index, section: 0)
            view?.performSegueToSingleImage(at: indexPath, url: url)
        }
    }
    
    func willDisplayCell(at index: Int) {
        willDisplayCellCalled = true
        willDisplayCellIndex = index
    }
    
    func toggleLike(at index: Int) {
        toggleLikeCalled = true
        toggleLikeIndex = index
    }
}

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var insertRowsCalled = false
    var insertedIndexPaths: [IndexPath]?
    
    var reloadRowsCalled = false
    var reloadedIndexPaths: [IndexPath]?
    
    var performSegueCalled = false
    var performSegueIndexPath: IndexPath?
    var performSegueURL: URL?
    
    func insertRows(at indexPaths: [IndexPath]) {
        insertRowsCalled = true
        insertedIndexPaths = indexPaths
    }
    
    func reloadRows(at indexPaths: [IndexPath]) {
        reloadRowsCalled = true
        reloadedIndexPaths = indexPaths
    }
    
    func performSegueToSingleImage(at indexPath: IndexPath, url: URL) {
        performSegueCalled = true
        performSegueIndexPath = indexPath
        performSegueURL = url
    }
}

final class ImagesListServiceMock: ImagesListServiceProtocol {
    var photosStub: [Photo] = []
    var changeLikeCalled = false
    var changeLikePhotoID: String?
    var changeLikeIsLike: Bool?
    var changeLikeCompletionResult: Result<Void, Error>?

    var photos: [Photo] {
        photosStub
    }

    func fetchPhotosNextPage() { }

    func changeLike(photoID: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        changeLikeCalled = true
        changeLikePhotoID = photoID
        changeLikeIsLike = isLike

        if let result = changeLikeCompletionResult {
            completion(result)
        }
    }
}

class FakeTableView: UITableView {
    var fakeIndexPath: IndexPath?

    override func indexPath(for cell: UITableViewCell) -> IndexPath? {
        return fakeIndexPath
    }
}

final class ImagesListViewControllerTests: XCTestCase {

    func testViewControllerCallsViewDidLoad() {
        // given
        let presenterSpy = ImagesListPresenterSpy()

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "ImagesListViewController") { coder in
            ImagesListViewController(coder: coder, presenter: presenterSpy)!
        }
        
        // when
        _ = viewController.view

        // then
        XCTAssertTrue(presenterSpy.viewDidLoadCalled)
    }
    
    func testPresenterInsertsRowsWhenPhotosAdded() {
        // given
        let serviceMock = ImagesListServiceMock()
        serviceMock.photosStub = []

        let presenter = ImagesListPresenter(service: serviceMock)
        let viewSpy = ImagesListViewControllerSpy()
        presenter.view = viewSpy

        presenter.viewDidLoad()
        let oldCount = presenter.photosCount

        let newPhoto = Photo(
            id: "1",
            size: CGSize(width: 100, height: 100),
            createdAt: Date(),
            welcomeDescription: nil,
            thumbImageURL: "",
            largeImageURL: "",
            isLiked: false
        )

        // when
        serviceMock.photosStub = [newPhoto]
        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: serviceMock)

        // then
        XCTAssertTrue(viewSpy.insertRowsCalled)
        XCTAssertEqual(viewSpy.insertedIndexPaths?.count, 1)
        XCTAssertEqual(viewSpy.insertedIndexPaths?.first?.row, oldCount)
    }
    
    func testImageListCellDidTapLikeCallsToggleLikeOnPresenter() {
        // given
        let presenterSpy = ImagesListPresenterSpy()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "ImagesListViewController") { coder in
            ImagesListViewController(coder: coder, presenter: presenterSpy)!
        }
        _ = viewController.view
        
        let tableView = FakeTableView()
        let cell = ImagesListCell()
        let fakeIndexPath = IndexPath(row: 2, section: 0)
        tableView.fakeIndexPath = fakeIndexPath

        viewController.tableView = tableView
        cell.delegate = viewController

        // when
        viewController.imageListCellDidTapLike(cell)

        // then
        XCTAssertTrue(presenterSpy.toggleLikeCalled)
        XCTAssertEqual(presenterSpy.toggleLikeIndex, fakeIndexPath.row)
    }
    
    func testDidSelectRowCallsDidSelectImageOnPresenter() {
        // given
        let presenterSpy = ImagesListPresenterSpy()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "ImagesListViewController") { coder in
            ImagesListViewController(coder: coder, presenter: presenterSpy)!
        }
        _ = viewController.view
        
        let indexPath = IndexPath(row: 0, section: 0)

        // when
        viewController.tableView(viewController.tableView, didSelectRowAt: indexPath)

        // then
        XCTAssertTrue(presenterSpy.didSelectImageCalled)
        XCTAssertEqual(presenterSpy.didSelectImageIndex, indexPath.row)
    }
    
    func testWillDisplayCellCallsPresenter() {
        // given
        let presenterSpy = ImagesListPresenterSpy()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "ImagesListViewController") { coder in
            ImagesListViewController(coder: coder, presenter: presenterSpy)!
        }
        _ = viewController.view
        
        let indexPath = IndexPath(row: 0, section: 0)

        // when
        viewController.tableView(viewController.tableView, willDisplay: UITableViewCell(), forRowAt: indexPath)

        // then
        XCTAssertTrue(presenterSpy.willDisplayCellCalled)
        XCTAssertEqual(presenterSpy.willDisplayCellIndex, indexPath.row)
    }
    
    func testPresenterCallsPerformSegueToSingleImageOnView() {
        // given
        let presenterSpy = ImagesListPresenterSpy()
        let viewSpy = ImagesListViewControllerSpy()
        presenterSpy.view = viewSpy
        
        let indexPath = IndexPath(row: 0, section: 0)
        let expectedURL = URL(string: "https://example.com/image.jpg")!
        
        let photo = Photo(
            id: "1",
            size: CGSize(width: 100, height: 100),
            createdAt: Date(),
            welcomeDescription: nil,
            thumbImageURL: "",
            largeImageURL: expectedURL.absoluteString,
            isLiked: false
        )
        
        presenterSpy.photoStub = photo

        // when
        presenterSpy.didSelectImage(at: indexPath.row)

        // then
        XCTAssertTrue(viewSpy.performSegueCalled)
        XCTAssertEqual(viewSpy.performSegueIndexPath, indexPath)
        XCTAssertEqual(viewSpy.performSegueURL, expectedURL)
    }
}
