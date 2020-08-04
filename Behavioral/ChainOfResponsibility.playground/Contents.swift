import UIKit

enum RetriveDataError: Error {
    case NotFound
}

protocol RetriveDataManager{
    associatedtype Item
    
    func retriveData(onComplete: ((Item?)->())) throws
}

class AnyRetriveDataManager<Item>: RetriveDataManager{
    var next: AnyRetriveDataManager<Item>?
    
    func retriveData(onComplete: ((Item?) -> ())) {
        do {
            try retriveFunction?(onComplete)
        } catch  {
            if let action = next{
                action.retriveData(onComplete: onComplete)
            }else{
                onComplete(nil)
            }
        }
    }
    
    typealias callback = ((Item?) -> ())
    private var retriveFunction : ((callback) throws->())?
    
    
    required init<DataManager: RetriveDataManager>( _ manager: DataManager, next: AnyRetriveDataManager<Item>?) where DataManager.Item == Item{
        retriveFunction = manager.retriveData
        self.next = next
    }
}

class APIManager<MovieItem>:RetriveDataManager{
    
    func retriveData(onComplete: ((MovieItem?) -> ())) throws{
        print("api")
        let model = MovieModel(movieID: 1, title: "123", synopsis: "hhhh", year: 2019)
        onComplete(model as? MovieItem)
//        throw RetriveDataError.NotFound
    }
}

class DBManager<Item>:RetriveDataManager{
    func retriveData(onComplete: ((Item?) -> ())) throws{
//        onComplete(nil)
        throw RetriveDataError.NotFound
    }
}

protocol MovieItem {
    var movieID: Int { get }
    var title: String { get }
    var synopsis: String { get}
    var year: Int { get }
}

struct MovieModel: MovieItem{
    var movieID: Int
    
    var title: String
    
    var synopsis: String
    
    var year: Int
}

struct DataRetriveBuilder{
    
    var dataRetriveManager: AnyRetriveDataManager<MovieItem>{
        let api = AnyRetriveDataManager<MovieItem>(APIManager(), next: nil)
        let db = AnyRetriveDataManager<MovieItem>(DBManager(), next: api)
        return db
    }
}


let manager = DataRetriveBuilder().dataRetriveManager
manager.retriveData(){
    value in
    guard let value = value else{
        print("no data found")
        return
    }
    print(value)
}


