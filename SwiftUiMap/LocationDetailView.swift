//
//  LocationDetailView.swift
//  SwiftUiMap
//
//  Created by Zoirbek Muxtorov on 04/12/24.
//

import SwiftUI
import MapKit


struct LocationDetailView: View {
    @Binding var mapSelection:MKMapItem?
    @Binding var show:Bool
    @State private var lookAroundScene: MKLookAroundScene?
    @Binding var getDirections:Bool
    
    var body: some View {
        VStack{
            HStack{
                VStack(alignment: .leading){
                    Text(mapSelection?.placemark.name ?? "")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(mapSelection?.placemark.title ?? "")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                        .lineLimit(2)
                        .padding(.trailing)
                }
                Spacer()
                
                Button{
                    show.toggle()
                    mapSelection = nil
                }label: {
                    Image (systemName:"xmark.circle.fill")
                        .resizable()
                        .frame(width: 24,height: 24)
                        .foregroundStyle(.gray,Color(.systemGray6))
                }
            }
            .padding(.horizontal)
            .padding(.top)
            
            
            if let scene = lookAroundScene {
                LookAroundPreview(initialScene: scene)
                    .frame(height: 200)
                    .cornerRadius(12)
                    .padding()
            } else {
                ContentUnavailableView("No preview available", systemImage: "eye.slash")
            }
            
            HStack(spacing:24){
                Button{
                    if let mapSelection{
                        mapSelection.openInMaps()
                    }
                }label: {
                    Text("Open is Map")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 170,height: 48)
                        .background(.green)
                        .cornerRadius(12)
                }
                Button{
                    show = true
                    getDirections = true
                }label: {
                    Text("Get Directions")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 170,height: 48)
                        .background(.blue)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal)
        }
        .onAppear{
            fetchLookAroundPreview()
        }
        .onChange(of: mapSelection){ oldValue, newValue in
            fetchLookAroundPreview()
        }
    }
}


extension LocationDetailView {
    func fetchLookAroundPreview() {
        if let mapSelection {
            lookAroundScene = nil
            Task {
                let request = MKLookAroundSceneRequest(mapItem: mapSelection)
                lookAroundScene = try? await request.scene
            }
        }
    }
}

#Preview {
    LocationDetailView(mapSelection: .constant(nil),show: .constant(false),getDirections:.constant(false))
}
