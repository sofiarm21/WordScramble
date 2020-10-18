//
//  ContentView.swift
//  WordScramble
//
//  Created by Sofia Rodriguez Morales on 10/17/20.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords:[String] =  []
    @State private var newWord = ""
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showAlert = false
    @State private var generatedWord = ""
    var body: some View {
        NavigationView{
            VStack{
                Text("\(errorTitle)")
                TextField("Enter your word", text: $newWord, onCommit:{addWord(add: newWord)})
                    .autocapitalization(.none)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                List(usedWords, id:\.self){
                    Image(systemName: "\($0.count).circle")
                    Text("\($0)")
                }
            }
            .navigationTitle("\(generatedWord)")
            .onAppear(perform: startGame)
            .navigationBarItems(leading:
                Button("Generate word", action: {
                    startGame()
                })
            )
//            .alert(isPresented: $showAlert) {
//                Alert(title: Text("\(errorTitle)"), message: Text("\(errorMessage)"), dismissButton: .default(Text("Ok")))
//            }
        }
    }
    
    func isAlredyUsed(word: String) -> Bool {
        return usedWords.contains(word)
    }
    
    func isContainedInRootWord(word: String) -> Bool {
        var rootWord = generatedWord
        for letter in word {
            if rootWord.contains(letter){
                rootWord.remove(at: rootWord.firstIndex(of: letter)!
                )
            }else{
                return false
                
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound
    }
    
    
    func addWord (add word: String) {
        let word = word.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard word.count > 0 else {
            return
        }
        
        guard !isAlredyUsed(word: newWord) else {
            showError(title: "Repeated word", message: "You must enter a not repeated word")
            return
        }
        guard isContainedInRootWord(word: newWord) else {
            showError(title: "Not found", message: "The word must be contained in the showed word")
            return
        }
        guard isReal(word: newWord) else {
            showError(title: "Fake!", message: "You cannot just write random text")
            return
        }
        showError(title: "", message: "")
        
        usedWords.insert(word, at: 0)
        newWord = ""
    }
    
    func startGame() {
        usedWords.removeAll()
        if let wordFileURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let allWords = try?
                String(contentsOf: wordFileURL){
                let words = allWords.components(separatedBy: "\n")
                let randomWord = words.randomElement() ?? ""
                generatedWord = randomWord
            }
        }else {
            fatalError("Error fetching bundle file")
        }
    }
    
    func showError(title: String, message:String) {
        errorTitle = title
        errorMessage = message
        showAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
