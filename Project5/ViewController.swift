//
//  ViewController.swift
//  Project5
//
//  Created by Subhrajyoti Chakraborty on 11/06/20.
//  Copyright © 2020 Subhrajyoti Chakraborty. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    var allWords = [String]()
    var usedWords = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(restartGame))
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
        
        startGame()
    }
    
    func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    func isPossible(word: String) -> Bool {
        print(usedWords.contains(word), word)
        return !usedWords.contains(word)
    }
    
    func isOriginal(word: String) -> Bool {
        
        if var safeTempWord = title?.lowercased() {
            if safeTempWord == word {
                return false
            } else {
                for letter in word {
                    if let pos = safeTempWord.firstIndex(of: letter) {
                        safeTempWord.remove(at: pos)
                    } else {
                        return false
                    }
                }
            }
        } else {
            return false
        }
        
        return true
    }
    
    func showErrorMessage(title: String, message: String){
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(ac, animated: true)
    }
    
    func isReal(word: String) -> Bool {
        if word.count < 3 {
            return false
        } else {
            let checker = UITextChecker()
            let range = NSRange(location: 0, length: word.count)
            let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
            
            return misspelledRange.location == NSNotFound
        }
    }
    
    func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard isPossible(word: lowerAnswer) else {
            showErrorMessage(title: "Word used already", message: "Be more original")
            return
        }
        
        guard isReal(word: lowerAnswer) else {
            showErrorMessage(title: "Word not possible", message: "That isn't a real word.")
            return
        }
        
        guard isOriginal(word: lowerAnswer) else {
            showErrorMessage(title: "Word not recognised", message: "You can't just make them up, you know!")
            return
        }
        
        usedWords.insert(lowerAnswer, at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] action in
            guard let answer = ac?.textFields?[0].text else {return}
            self?.submit(answer)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    @objc func restartGame(){
        startGame()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row].uppercased()
        return cell
    }
    
}

