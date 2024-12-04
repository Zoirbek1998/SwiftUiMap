//
//  ContentView.swift
//  SwiftUiMap
//
//  Created by Zoirbek Muxtorov on 04/12/24.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @State private var cameraPosition: MapCameraPosition = .region(.userRegion)
    @State private var searchText:String = ""
    @State private var results = [MKMapItem]()
    @State private var mapSelection: MKMapItem?
    @State private var showDetails = false
    @State private var getDirections = false
    @State private var routeDisplaying = false
    @State private var route : MKRoute?
    @State private var routeDistination : MKMapItem?
    
    
    
    var body: some View {
        Map(position: $cameraPosition,selection: $mapSelection){
//            Marker("My Location",systemImage: "paperplane",coordinate: .userLocation).tint(.blue) - >  bu orqali systemni markerni sozlashingiz mumkkin
            
            Annotation("My Location",coordinate: .userLocation){
                ZStack{
                    Circle()
                        .frame(width: 32,height:32)
                        .foregroundColor(.blue.opacity(0.25))
                    Circle()
                        .frame(width: 20,height:20)
                        .foregroundColor(.white)
                    Circle()
                        .frame(width: 12,height:12)
                        .foregroundColor(.blue)
                }
            }
            
            ForEach(results, id: \.self){ item in
                if routeDisplaying {
                    if item == routeDistination{
                        
                    }
                }else{
                    let plaseMark = item.placemark
                    Marker(plaseMark.name ?? "",coordinate: plaseMark.coordinate)
                }
            
            }
            
            if let route {
                MapPolyline(route.polyline).stroke(.blue, lineWidth: 6)
            }
        }
        .overlay(alignment:.top){
            TextField("Search for a location...",text: $searchText)
                .textFieldStyle(.roundedBorder)
                .font(.subheadline)
                .padding(12)
                .shadow(radius: 10)
        }
        .onSubmit(of:.text) {
            Task{await searchPlaces()}
        }
        .onChange(of: getDirections, { oldValue,newValue in
            if newValue {
                fetchRoute()
            }
        })
        .onChange(of: mapSelection, { oldValue,newValue in
            showDetails = newValue != nil
        })
        .sheet(isPresented: $showDetails, content:{
            LocationDetailView(mapSelection: $mapSelection, show: $showDetails,getDirections: $getDirections)
                .presentationDetents([.height(340)])
                .presentationBackgroundInteraction(.enabled(upThrough: .height(340)))
                .presentationCornerRadius(12)
                    
        })
        .mapControls{
            MapCompass()
            MapPitchToggle()
            MapUserLocationButton()
        }
    }
}

extension ContentView {
    func searchPlaces() async{
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = .userRegion
        
        let results = try? await MKLocalSearch(request: request).start()
        self.results = results?.mapItems ?? []
    }
    
    func fetchRoute(){
        if let mapSelection {
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: .init(coordinate: .userLocation))
            request.destination = mapSelection
            
            Task{
                let result = try? await MKDirections (request: request) .calculate()
                route = result?.routes.first
                routeDistination = mapSelection
                
                withAnimation(.snappy){
                    routeDisplaying = true
                    showDetails = false
                    
                    if let rect =
                        route?.polyline.boundingMapRect, routeDisplaying {
                        cameraPosition = .rect(rect)
                        
                    }
                    
                }
                
            }
        }
    }
}


extension CLLocationCoordinate2D {
    static var userLocation: CLLocationCoordinate2D{
        return . init(latitude: 25.7602, longitude: -80.1959)
    }
    //    Toshkent ->latitude: 41.2995, longitude: 69.2401
}

extension MKCoordinateRegion {
    static var userRegion:MKCoordinateRegion {
        return .init(center: .userLocation,latitudinalMeters: 10000,longitudinalMeters: 10000)
    }
}

#Preview {
    ContentView()
}
