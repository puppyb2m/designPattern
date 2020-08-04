import UIKit

// api
// db
// log


protocol Command{
    func exctue()->FoodResult
    func undo()->FoodResult
}

// food model
struct FoodModel{
    var id: Int
    var name: String
}

// command
enum CommandExctueType{
    case addFood(FoodModel)
    case delete(Int)
    case fetchFood(Int)
}

enum FoodResult{
    case fetchFood(FoodModel)
    case result(Bool)
    case none
}

// api
struct ApiManager{
    func addNewFood(model: FoodModel){
        print("add new food")
        print(model)
    }
    
    func deleteFood(id: Int){
        print("delete food \(id)")
    }
    
    func fetchFood(id: Int)->FoodModel{
        return FoodModel(id: 1, name: "food name 1")
    }
}

struct ApiCommand: Command{
    private var actionType: CommandExctueType
    
    func undo()->FoodResult {
        switch actionType {
        case .delete(let value):
            apiManager.deleteFood(id: value)
            return .result(true)
        default :
            break
        }
        
        return .none
    }
    
    func exctue()->FoodResult {
        switch actionType {
        case .addFood(let value):
            apiManager.addNewFood(model: value)
            return .result(true)
        case .fetchFood(let value):
            return .fetchFood(apiManager.fetchFood(id: value))
        default:
            break
        }
        return .none
    }
    
    private var apiManager: ApiManager
    
    init(apiManager: ApiManager , type: CommandExctueType) {
        self.apiManager = apiManager
        self.actionType = type
    }
}

// transaction command


// invoker
protocol Invoker{
    func addCommand(command: Command)
}

class BatchInvoker: Invoker{
    private var todoList: [Command] = []
    private var finishList: [Command] = []
    private var failedList: [Command] = []
    
    func addCommand(command: Command) {
        todoList.append(command)
    }
    
    func doBatch(){
        todoList.forEach(){
            value in
            print(value)
            switch value.exctue(){
            
            case .result(let result):
                if result{
                    finishList.append(value)
                }else{
                    failedList.append(value)
                }
                break
            default :
                break
            }
        }
        
        todoList.removeAll()
    }
}

let batchInvoker = BatchInvoker()
let apiManager = ApiManager()

let addFoodCommand = ApiCommand(apiManager: apiManager, type: .addFood(FoodModel(id: 2, name: "food name 2")))
let deleteFoodCommand = ApiCommand(apiManager: apiManager, type: .delete(3))

batchInvoker.addCommand(command: addFoodCommand)
batchInvoker.addCommand(command: deleteFoodCommand)

batchInvoker.doBatch()

