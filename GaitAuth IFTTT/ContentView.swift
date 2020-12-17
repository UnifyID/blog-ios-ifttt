//
//  ContentView.swift
//  GaitAuth IFTTT
//
//  Created by Ryan Peden on 2020-12-17.
//

import SwiftUI
import UnifyID
import GaitAuth

class GaitAuthHelper {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var gaitAuth: GaitAuth? = nil
    var gaitModel: GaitModel? = nil
    var gaitFeatures: [GaitFeature] = []
    
    init() {
        self.gaitAuth = appDelegate.unifyid.gaitAuth
    }
    
    func startTraining() {
        gaitAuth?.createModel { result in
            switch result {
            case .success(let gaitModel):
                self.gaitModel = gaitModel
            case .failure(_):
                print("Unable to create model.")
            }
        }
        
        gaitAuth?.startFeatureUpdates(to: DispatchQueue.main) { result in
            switch result {
            case .success(let features):
                self.gaitFeatures = features
            case .failure(_):
                print("Unable to start training")
            }
        }
        return
    }
    
    func finishTraining() {
        gaitAuth?.stopFeatureUpdates()
        
        gaitModel?.add(gaitFeatures) { error in
            if let error = error {
                print("Error adding features to model:")
                print(error)
                return
            }
        }
           
        gaitModel?.train() { error in
            if let error = error {
                print("Error training model:")
                print(error)
                return
            }
        }
            
        return
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
            Button(action: {}) {
                Text("Finish Training")
                    .padding(10.0)
            }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            
    }
}
