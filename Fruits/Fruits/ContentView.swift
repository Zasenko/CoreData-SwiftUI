//
//  ContentView.swift
//  Fruits
//
//  Created by Dmitry Zasenko on 26.04.23.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var vm = CoreDataManager()
    @State private var text = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                HStack {
                    TextField("Add fruit here...", text: $text)
                        .font(.headline)
                        .padding(.leading)
                        .frame(height: 55)
                        .background(Color.secondary.opacity(0.5))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    
                    Button {
                        guard !text.isEmpty else {return}
                        vm.addFruit(text: text)
                    } label: {
                        Text("Add")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(height: 55)
                            .padding(.horizontal)
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                    .padding(.trailing)
                }
                
                List {
                    ForEach(vm.fruits) { fruit in
                        VStack {
                            Text(fruit.name ?? "")
                                .onTapGesture {
                                    vm.updateFruit(fruit: fruit)
                                }
                        }
                        
                    }
                    .onDelete(perform: vm.deleteFruit)
                }
            }
            .navigationTitle("Fruits")
        }
        
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
