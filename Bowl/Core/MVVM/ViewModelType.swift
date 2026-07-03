//
//  ViewModelType.swift
//  Bowl
//
//  Contract for all view models. Each view model declares an `Input`
//  (user-driven events) and an `Output` (state the view observes), and
//  wires them together in `transform(input:)`. This keeps the data flow
//  unidirectional and testable, in line with the RxSwift + MVVM pattern.
//

import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output

    func transform(input: Input) -> Output
}
