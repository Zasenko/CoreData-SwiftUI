//
//  CoreDataRelationshipViewModel.swift
//  Fruits
//
//  Created by Dmitry Zasenko on 26.04.23.
//

import SwiftUI
import CoreData

class CoreDataRelationshipManager {
    static let shared = CoreDataRelationshipManager()
    
    let container: NSPersistentContainer
    let context: NSManagedObjectContext
    
    init() {
        container = NSPersistentContainer (name: "RelationshipContainer")
        container.loadPersistentStores { descriptoin, error in
            if let error = error {
                print ("Core Data failed to load: \(error.localizedDescription)")
            }
        }
        context = container.viewContext
    }
    
    func saveData() {
        do {
            try context.save()
        } catch let error {
            print("Error Saving. \(error.localizedDescription)")
        }
    }
}

class CoreDataRelationshipViewModel: ObservableObject {
    
    let manager = CoreDataRelationshipManager.shared
    @Published var businesses: [BusinessEntity] = []
    @Published var departments: [DepartmentEntity] = []
    @Published var employees: [EmployeeEntity] = []
    
    init() {
        getBusinesses()
        getDepartments()
        getEmployees()
    }
    
    func getBusinesses() {
        let request = NSFetchRequest<BusinessEntity>(entityName: "BusinessEntity")
        
        let sort = NSSortDescriptor(keyPath: \BusinessEntity.name, ascending: true)
        request.sortDescriptors = [sort]
        
//        let filter = NSPredicate(format: "name == %@", "Apple")
//        request.predicate = filter
        
        do {
            businesses = try manager.context.fetch(request)
        } catch let error {
            print ("fetch error: \(error.localizedDescription)")
        }
    }
    
    func getDepartments() {
        let request = NSFetchRequest<DepartmentEntity>(entityName: "DepartmentEntity")
        do {
            departments = try manager.context.fetch(request)
        } catch let error {
            print ("fetch error: \(error.localizedDescription)")
        }
    }
    
    func getEmployees() {
        let request = NSFetchRequest<EmployeeEntity>(entityName: "EmployeeEntity")
        do {
            employees = try manager.context.fetch(request)
        } catch let error {
            print ("fetch error: \(error.localizedDescription)")
        }
    }
    
    func getEmployees(forBusiness business: BusinessEntity) {
        let request = NSFetchRequest<EmployeeEntity>(entityName: "EmployeeEntity")
        
        let filter = NSPredicate(format: "business == %@", business)
        request.predicate = filter
        
        do {
            employees = try manager.context.fetch(request)
        } catch let error {
            print ("fetch error: \(error.localizedDescription)")
        }
    }
    
    func addBusiness() {
        let newBusiness = BusinessEntity(context: manager.context)
        newBusiness.name = "Apple"
        save()
    }
    
    func addDepartment() {
        let newDepartment = DepartmentEntity(context: manager.context)
        newDepartment.name = "Engineering"
        // newDepartment.businesses = [businesses[0]]
        
        newDepartment.addToEmployees(employees[2])
        // or: newDepartment.employees = [employees[1]]
        save()
    }
    
    func updateBusiness() {
        let existingBusiness = businesses[2]
        existingBusiness.addToDepartments(departments[4])
        save()
    }
    
    func addEmployee() {
        let newEmployee = EmployeeEntity(context: manager.context)
        newEmployee.name = "Dima"
        newEmployee.age = 40
        newEmployee.dateJoined = Date()
        newEmployee.business = businesses[0]
        newEmployee.department = departments[3]
        save()
    }
    
    func deliteDepartment() {
        let department = departments[1]
        manager.context.delete(department)
        save()
    }
    
    func save() {
        //для проверки?
        businesses.removeAll()
        departments.removeAll()
        employees.removeAll()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.manager.saveData()
            self.getBusinesses()
            self.getDepartments()
            self.getEmployees()
        }
    }
    
}

struct CoreDataRelationshipView: View {
    @StateObject var vm = CoreDataRelationshipViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Button {
                        vm.deliteDepartment()
                    //    vm.getEmployees(forBusiness: vm.businesses[0])
                    } label: {
                        Text("Add Business")
                            .foregroundColor(.white)
                            .frame(height: 55)
                            .padding(.horizontal)
                            .background(Color.blue.cornerRadius(10))
                    }
                    .padding(.trailing)
                }
                
                ScrollView(.horizontal, showsIndicators: true) {
                    HStack(alignment: .top) {
                        ForEach(vm.businesses) { business in
                            BusinessView(entity: business)
                        }
                    }
                }
                
                ScrollView(.horizontal, showsIndicators: true) {
                    HStack(alignment: .top) {
                        ForEach(vm.departments) { department in
                            DepartmentView(entity: department)
                        }
                    }
                }
                
                ScrollView(.horizontal, showsIndicators: true) {
                    HStack(alignment: .top) {
                        ForEach(vm.employees) { employee in
                            EmployeeView(entity: employee)
                        }
                    }
                }
                
            }
            .navigationTitle("Relationships")
        }
        
    }
}

struct CoreDataRelationshipView_Previews: PreviewProvider {
    
    static var previews: some View {
        CoreDataRelationshipView()
    }
}


struct BusinessView: View {
    
    let entity: BusinessEntity
    
    var body: some View {
        VStack {
            Text(entity.name ?? "")
                .bold()
            
            if let departments = entity.departments?.allObjects as? [DepartmentEntity] {
                Text("Departments:")
                    .bold()
                
                ForEach(departments) { department in
                    Text(department.name ?? "")
                }
            }
            
            if let employees = entity.employees?.allObjects as? [EmployeeEntity] {
                Text("Employees:")
                    .bold()
                
                ForEach(employees) { employee in
                    Text(employee.name ?? "")
                }
            }
        }
        .padding()
        .frame(maxWidth: 300, alignment: .leading)
        .background(Color.gray.opacity(0.5))
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}


struct DepartmentView: View {
    
    let entity: DepartmentEntity
    
    var body: some View {
        VStack {
            Text(entity.name ?? "")
                .bold()
            
            if let businesses = entity.businesses?.allObjects as? [BusinessEntity] {
                Text("Departments:")
                    .bold()
                
                ForEach(businesses) { business in
                    Text(business.name ?? "")
                }
            }
            
            if let employees = entity.employees?.allObjects as? [EmployeeEntity] {
                Text("Employees:")
                    .bold()
                
                ForEach(employees) { employee in
                    Text(employee.name ?? "")
                }
            }
        }
        .padding()
        .frame(maxWidth: 300, alignment: .leading)
        .background(Color.green.opacity(0.5))
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}

struct EmployeeView: View {
    
    let entity: EmployeeEntity
    
    var body: some View {
        VStack {
            Text(entity.name ?? "")
                .bold()
            Text("Age: \(entity.age)")
            Text("Date joined: \(entity.dateJoined ?? Date())")
            Text("Business:")
            Text(entity.business?.name ?? "")
            Text("Department:")
            Text(entity.department?.name ?? "")
            
        }
        .padding()
        .frame(maxWidth: 300, alignment: .leading)
        .background(Color.blue.opacity(0.5))
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}
