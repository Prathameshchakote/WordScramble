//
//  ContentView.swift
//  WordScramble
//
//  Created by Prathamesh on 3/16/24.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Enter your wprd", text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                
                Section {
                    ForEach(usedWords, id: \.self) {word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                       
                        
                    }
                }
            }
            .navigationTitle(rootWord)
            .toolbar(content: {
                Button {
                    usedWords = []
                    startGame()
                } label: {
                    Text("restart")
                }

            })
            .onSubmit {
                addNewWord()
            }
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("ok") {}
            } message: {
                Text(errorMessage)
            }
        }
        
        withAnimation {
            Text("total score : \(usedWords.count)")
                .font(.title)
                .bold()
        }
        
    }
    func startGame() {
        if let startwordTextURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startword = try? String(contentsOf: startwordTextURL) {
                let allword = startword.components(separatedBy: "\n")
                rootWord = allword.randomElement() ?? "apple"
                return
            }
            usedWords = []
        }
        
        fatalError("Could not load start.txt from bundle")
    }
    
    func addNewWord() {
        let ans = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard ans.count > 0 else {
            return
        }
        
        guard isOriginal(word: ans) else {
            wordError(title: "word used already", message: "Be more original!")
            return
        }
        
        guard isPossible(word: ans) else {
            wordError(title: "word not possible", message: "You cant spell that word from \(rootWord) !! ")
            return
        }
        
        guard isReal(word: ans) else {
            wordError(title: "word not recognised", message: "give meaningful full word don't make it up")
            return
        }
        
        withAnimation {
            usedWords.insert(ans, at: 0)
        }
        
        newWord = ""
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let mispelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return mispelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
}

#Preview {
    ContentView()
}
