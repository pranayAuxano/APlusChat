//
//  Cancellable.swift
//  agsChat
//
//  Created by MAcBook on 07/07/22.
//

import Foundation

protocol Cancellable
{
    // MARK: - Methods
    func cancel()
}

extension URLSessionTask: Cancellable
{   }
