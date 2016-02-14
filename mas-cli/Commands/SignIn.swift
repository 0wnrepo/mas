//
//  SignIn.swift
//  mas-cli
//
//  Created by Andrew Naylor on 14/02/2016.
//  Copyright © 2016 Andrew Naylor. All rights reserved.
//

struct SignInCommand: CommandType {
    typealias Options = SignInOptions
    let verb = "signin"
    let function = "Sign in to the Mac App Store"
    
    func run(options: Options) -> Result<(), MASError> {
        
        guard ISStoreAccount.primaryAccount == nil else {
            return .Failure(MASError.init(code: .AlreadySignedIn))
        }
        
        do {
            print("==> Signing in to Apple ID: \(options.username)")
            try ISStoreAccount.signIn(username: options.username, password: options.password)
        } catch let error as NSError {
            return .Failure(MASError(code: .SignInError, sourceError: error))
        }
        
        return .Success(())
    }
}

struct SignInOptions: OptionsType {
    let username: String
    let password: String
    
    static func evaluate(m: CommandMode) -> Result<SignInOptions, CommandantError<MASError>> {
        return curry(SignInOptions.init)
            <*> m <| Argument(usage: "Apple ID")
            <*> m <| Argument(usage: "Password")
    }
}
