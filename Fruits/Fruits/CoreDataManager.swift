//
//  CoreDataManager.swift
//  Fruits
//
//  Created by Dmitry Zasenko on 26.04.23.
//

import CoreData
import Foundation

class CoreDataManager: ObservableObject {
    
    let container: NSPersistentContainer
    @Published var fruits: [Fruit] = []
    
    init() {
        container = NSPersistentContainer (name: "FruitsModel")
        container.loadPersistentStores { [weak self] descriptoin, error in
            if let error = error {
                print ("Core Data failed to load: \(error.localizedDescription)")
            } else {
                self?.fetchFruits()
            }
        }
    }
    
    func fetchFruits() {
        let request = NSFetchRequest<Fruit>(entityName: "Fruit")
        do {
            fruits = try container.viewContext.fetch(request)
        } catch let error {
            print ("fetchUser error: \(error.localizedDescription)")
        }
    }
    
    func addFruit(text: String) {
        let fruit = Fruit(context: container.viewContext)
        fruit.id = UUID()
        fruit.name = text
        saveData()
    }
    
    func updateFruit(fruit: Fruit) {
        guard let name = fruit.name else {return}
        let newName = name + " {...}"
        fruit.name = newName
        saveData()
    }
    
    func deleteFruit(indexSex: IndexSet) {
        guard let index = indexSex.first else {return}
        let fruit = fruits[index]
        container.viewContext.delete(fruit)
        saveData()
    }
    
    func saveData() {
        do {
            try container.viewContext.save()
            fetchFruits()
        } catch let error {
            print("Error Saving. \(error)")
        }
    }
}
