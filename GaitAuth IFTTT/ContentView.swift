//
//  ContentView.swift
//  GaitAuth IFTTT
//
//  Created by Ryan Peden on 2020-12-17.
//

import SwiftUI
import UnifyID
import GaitAuth

/*
 Note: To run training and authtication when your app is not running in the
 foreground, consider scheduling GaitAuth operations in a Background Task:
 https://developer.apple.com/documentation/backgroundtasks/bgtaskscheduler
*/
class GaitAuthHelper {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var _gaitAuth: GaitAuth? = nil
    var _gaitModel: GaitModel? = nil
    var _gaitFeatures: [GaitFeature] = []
    let _defaults: UserDefaults = UserDefaults.standard
    
    init() {
        self._gaitAuth = appDelegate.unifyid.gaitAuth
    }
    
    private func loadModel(completion: (() -> Void)? = nil) {
        // Don't re-load the model if it's already loaded.
        if (_gaitModel != nil) {
            completion?()
            return
        }
        
        // If we've already created a model, load it. Otherwise,
        // create a new model.
        let existingModelId = _defaults.string(forKey: "gaitModelId");
        if (existingModelId != nil) {
            _gaitAuth?.loadModel(withIdentifier: existingModelId!) { result in
                switch result {
                case .success(let gaitModel):
                    self._gaitModel = gaitModel
                    print("Loaded model with ID: \(existingModelId!)")
                    completion?()
                case.failure(_):
                    print("Failed to existing model with ID: \(existingModelId!)")
                }
            }
        } else {
            _gaitAuth?.createModel { result in
                switch result {
                case .success(let gaitModel):
                    self._gaitModel = gaitModel
                    self._defaults.setValue(gaitModel.id, forKey: "gaitModelId")
                    print("Successfully created new GaitAuth model.")
                    completion?()
                case .failure(_):
                    print("Unable to create model.")
                }
            }
        }
    }
    
    // Start gathering features to train the app's GaitAuth model.
    func startTraining() {
        _gaitAuth?.startFeatureUpdates(to: DispatchQueue.main) { result in
            switch result {
            case .success(let features):
                self._gaitFeatures = features
            case .failure(_):
                print("Unable to start training")
            }
        }
        return
    }
    
    // Stop gathering features and submit them to UnifyID for model training.
    func finishTraining() {
        _gaitAuth?.stopFeatureUpdates()
        
        _gaitModel?.add(_gaitFeatures) { error in
            if let error = error {
                print("Error adding features to model:")
                print(error)
                return
            }
            print("Features added to model.")
        }
           
        _gaitModel?.train() { error in
            if let error = error {
                print("Error training model:")
                print(error)
                return
            }
            print("Features uploaded to UnifyID. Training is in progress.")
        }
            
        return
    }
    
    // Check to determine if the person operating the device is the same person
    // the GaitAuth model is trained to recognize.
    func checkAuthentication(completion: @escaping GaitAuth.Callback<AuthenticationResult>) {
        
        if (_gaitModel == nil) {
            print("Can't authenticate without a model.")
            return
        }
        
        if (_gaitModel?.status.name != GaitModel.Status.ready.name) {
            print("Model exists, but is not ready for scoring.")
            return
        }
        
        let authenticator = _gaitAuth?.authenticator(
            config: GaitQuantileConfig(threshold: 0.0)!,
            model: _gaitModel!)
        
        authenticator?.status(completion: completion)
    }
}

struct ContentView: View {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var gaitAuthHelper: GaitAuthHelper = GaitAuthHelper()
    
    var body: some View {
        VStack() {
            Text("GaitAuth + IFTTT")
                .padding()
            
            Button(action: {
                self.gaitAuthHelper.startTraining()
            }) {
                Text("Start Training")
                    .padding(10.0)
            }
            
            Button(action: {
                self.gaitAuthHelper.finishTraining()
            }) {
                Text("Finish Training")
                    .padding(10.0)
            }
            
            Button(action: {
                self.gaitAuthHelper.checkAuthentication() { result in
                    switch result {
                    case .success(let authenticationResult):
                        print("Authentication Succeeded")
                    case .failure(let error):
                        print("Authentication Failed")
                    }
                }
            }) {
                Text("Check Authentication")
                    .padding(10.0)
            }
            
            Spacer()
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            
    }
}
