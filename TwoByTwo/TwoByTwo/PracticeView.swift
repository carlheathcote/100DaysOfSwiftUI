//
//  NewPracticeView.swift
//  TwoByTwo
//
//  Created by Vitali Tatarintev on 01.02.20.
//  Copyright © 2020 Vitali Tatarintev. All rights reserved.
//

import SwiftUI

struct Question {
  var multiplier: Int
  var multiplicant: Int

  var product: Int {
    multiplier * multiplicant
  }

  var toString: String {
    "\(multiplier) X \(multiplicant) = ?"
  }
}

struct NewAnswerButton: View {
  let label: String
  let width: CGFloat
  let backgroundColor: Color
  let action: () -> Void

  var body: some View {
    Button(action: self.action) {
      Text(self.label)
        .font(.largeTitle)
        .frame(width: self.width, height: 50)
        .padding(35)
        .foregroundColor(.white)
        .background(self.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .animation(.easeInOut)
    }
  }
}

struct PracticeView: View {
  @Environment(\.presentationMode) var presentationMode
  @Environment(\.horizontalSizeClass) var sizeClass

  let questionsPerTable = 11

  @EnvironmentObject var settings: PracticeSettings

  @State private var questionsAnswered = 0
  @State private var currentQuestion = Question(multiplier: 2, multiplicant: 2)
  @State private var currentAnswerSuggestions = [
    (value: 0, isCorrect: false),
    (value: 0, isCorrect: false),
    (value: 0, isCorrect: false),
    (value: 0, isCorrect: false)
  ]
  @State private var questions: [Question] = []
  @State private var nextButtonDisabled = true
  @State private var buttonColors = Array(repeating: Color.orange, count: 4)
  @State private var buttonDidTap = false
  @State private var isPracticeFinished = false

  var totalQuestions: Int {
    let numberOfQuestions = Int(self.settings.selectedNumberOfQuestions) ?? 0

    return numberOfQuestions == 0
      ? questionsPerTable * self.settings.practiceRange
      : numberOfQuestions
  }

  var body: some View {
    GeometryReader { geo in
      VStack {
        HStack {
          Text("\(self.questionsAnswered)/\(self.totalQuestions)")

          Spacer()

          Button(action: {
            self.presentationMode.wrappedValue.dismiss()
          }) {
            Image(systemName: "xmark")
              .foregroundColor(.red)
          }
        }
        .font(.headline)
        .frame(width: self.screenWidth(geo))
        .padding()

        GeometryReader { _ in
          VStack {
            Text(self.currentQuestion.toString)
              .font(.largeTitle)
              .padding(.bottom, 30)

            if self.sizeClass == .compact {
              VStack(alignment: .center) {
                HStack {
                  NewAnswerButton(label: "\(self.currentAnswerSuggestions[0].value)", width: self.answerButtonWidth(geo, 2), backgroundColor: self.buttonColors[0], action: {
                    self.tapAnswerButton(index: 0)
                  })

                  NewAnswerButton(label: "\(self.currentAnswerSuggestions[1].value)", width: self.answerButtonWidth(geo, 2), backgroundColor: self.buttonColors[1], action: {
                    self.tapAnswerButton(index: 1)
                  })

                }
                .padding(.bottom, 10)

                HStack {
                  NewAnswerButton(label: "\(self.currentAnswerSuggestions[2].value)", width: self.answerButtonWidth(geo, 2), backgroundColor: self.buttonColors[2], action: {
                    self.tapAnswerButton(index: 2)
                  })

                  NewAnswerButton(label: "\(self.currentAnswerSuggestions[3].value)", width: self.answerButtonWidth(geo, 2), backgroundColor: self.buttonColors[3], action: {
                    self.tapAnswerButton(index: 3)
                  })
                }
              }
            } else {
              HStack(alignment: .center) {
                ForEach(0..<4, id: \.self) { index in
                  NewAnswerButton(label: "\(self.currentAnswerSuggestions[index].value)", width: self.answerButtonWidth(geo, 4), backgroundColor: self.buttonColors[index], action: {
                    self.tapAnswerButton(index: index)
                  })
                }
              }
            }
          }
        }

        VStack {
          if !self.isPracticeFinished {
            Button(action: {
              self.questionsAnswered += 1

              if self.questionsAnswered < self.totalQuestions {
                self.currentQuestion = self.pickNewQuestion()
                self.currentAnswerSuggestions = self.generateAnswerSuggestions(question: self.currentQuestion)
                self.nextButtonDisabled = true
                self.buttonDidTap = false
                self.buttonColors = Array(repeating: Color.orange, count: 4)
              } else {
                self.isPracticeFinished = true
              }
            }) {
              Image(systemName: "forward.fill")
                .padding(25)
                .frame(width: self.screenWidth(geo))
                .background(self.nextButtonDisabled ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .disabled(self.nextButtonDisabled)
          } else {
            VStack {
              Text("Good job!")
                .font(.title)
                .foregroundColor(.green)
                .padding()

              Button(action: {
                self.presentationMode.wrappedValue.dismiss()
              }) {
                Image(systemName: "stop.fill")
                  .padding(25)
                  .frame(width: self.screenWidth(geo))
                  .background(Color.green)
                  .foregroundColor(.white)
                  .clipShape(RoundedRectangle(cornerRadius: 10))
              }
            }
          }
        }
        .padding()
      }
      .onAppear(perform: {
        self.generateQuestions()
        self.currentQuestion = self.pickNewQuestion()
        self.currentAnswerSuggestions = self.generateAnswerSuggestions(question: self.currentQuestion)
      })
    }
  }

  func screenWidth(_ geo: GeometryProxy) -> CGFloat {
    geo.size.width * 0.9
  }

  func answerButtonWidth(_ geo: GeometryProxy, _ buttonsPerLine: CGFloat) -> CGFloat {
    self.screenWidth(geo) / buttonsPerLine - 76 // 76 here calculated in the experimental way
  }

  func pickNewQuestion() -> Question {
    self.questions.shuffle()

    return self.questions.popLast() ?? Question(multiplier: 2, multiplicant: 2)
  }

  func generateQuestions() {
    for multiplier in 1...self.settings.practiceRange {
      for multiplicant in 0..<self.questionsPerTable {
        self.questions.append(Question(multiplier: multiplier, multiplicant: multiplicant))
      }
    }

    self.questions.shuffle()
  }

  func generateAnswerSuggestions(question: Question) -> [(value: Int, isCorrect: Bool)] {
    let diff = question.multiplier == 0 ? 1 : question.multiplier

    var answers = [
      (value: question.product, isCorrect: true),
      (value: question.product + diff, isCorrect: false),
      (value: question.product - diff, isCorrect: false),
      (value: question.product + diff + 1, isCorrect: false)
    ]

    answers.shuffle()

    return answers
  }

  func calculateButtonColor(buttonIndex: Int) -> Color {
    guard self.buttonDidTap else { return Color.orange }

    guard self.currentAnswerSuggestions[buttonIndex].isCorrect else { return Color.red }

    return Color.green
  }

  func tapAnswerButton(index: Int) {
    self.nextButtonDisabled = false
    self.buttonDidTap = true
    self.buttonColors[index] = self.calculateButtonColor(buttonIndex: index)
  }
}

struct NewPracticeView_Previews: PreviewProvider {
  static var previews: some View {
    PracticeView().environmentObject(PracticeSettings())
  }
}
