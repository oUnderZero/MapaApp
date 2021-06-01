 

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, UISearchBarDelegate, MKMapViewDelegate {

    @IBOutlet weak var buscador: UISearchBar!
    
    
    @IBOutlet weak var mapamk: MKMapView!
    var latitud: CLLocationDegrees?
    var longitud: CLLocationDegrees?
    var altitud: Double?
    var manager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        buscador.delegate = self
        manager.delegate = self
        mapamk.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
        
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation()
        
    }
    func trazarRuta(coordenadasDestino: CLLocationCoordinate2D)   {
        guard let coordOrigen = manager.location?.coordinate else {
            return
        }
        
        let origenPlaceMark = MKPlacemark(coordinate: coordOrigen)
        let destinoPlaceMark = MKPlacemark(coordinate: coordenadasDestino)
        
        
       
        let origenItem = MKMapItem(placemark: origenPlaceMark)
        let destinoItem = MKMapItem(placemark: destinoPlaceMark)
        
        
        let solicitudDestino = MKDirections.Request()
        solicitudDestino.source = origenItem
        solicitudDestino.destination = destinoItem
        
        solicitudDestino.transportType = .automobile
        solicitudDestino.requestsAlternateRoutes = true
        
        let direcciones = MKDirections(request: solicitudDestino)
        direcciones.calculate { (respuesta, error) in
            guard let respuestaSegura = respuesta else{
                if let error = error {
                    print("No se pudó calcular la ruta \(error.localizedDescription)")
                }
                return
            }
            print(respuestaSegura.routes.count)
            let ruta = respuestaSegura.routes[0]
           
            
            let kilometros = (ruta.distance)/1000
            let alerta2 = UIAlertController(title: "Distancia", message: "El destino se encuentra a:  \(kilometros) kilometros de ti", preferredStyle: .alert)
            
            let accionAceptar2 = UIAlertAction(title: "Aceptar", style: .default, handler: nil)
            
            alerta2.addAction(accionAceptar2)
            self.present(alerta2, animated: true)
            
            
            
            self.mapamk.addOverlay(ruta.polyline)
            self.mapamk.setVisibleMapRect(ruta.polyline.boundingMapRect, animated: true)
        }
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderizado = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderizado.strokeColor = .cyan
        return renderizado
    }
    @IBAction func ubicacionButton(_ sender: UIBarButtonItem) {
        guard let alt = altitud else{
            return
            
        }
        let alerta = UIAlertController(title: "Ubicación", message: "Las coordenadas son: \(latitud ?? 0) \(longitud ?? 0) \(alt )", preferredStyle: .alert)
        
        let accionAceptar = UIAlertAction(title: "Aceptar", style: .default, handler: nil)
        
        alerta.addAction(accionAceptar)
        present(alerta, animated: true)
        
        let localizacion = CLLocationCoordinate2D(latitude: latitud!, longitude: longitud!)
        
        let spanMapa = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        
        let region = MKCoordinateRegion(center: localizacion, span: spanMapa)
        mapamk.setRegion(region, animated: true)
        mapamk.showsUserLocation = true
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        buscador.resignFirstResponder()
        
       
        
      //  buscador.resignFirstResponder()
        
        let geocoder = CLGeocoder()
        if let direccion = buscador.text{
            geocoder.geocodeAddressString(direccion) { (places: [CLPlacemark]?, error: Error?) in
                
                guard let destinoRuta = places?.first?.location else{
                    return
                }
                
                if error == nil{
                    let lugar = places?.first
                    let anotacion = MKPointAnnotation()
                    anotacion.coordinate = (lugar?.location?.coordinate)!
                    anotacion.title = direccion
                    
                    let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    
                    let region = MKCoordinateRegion(center: anotacion.coordinate, span: span)
                    
                    self.mapamk.setRegion(region, animated: true)
                    self.mapamk.addAnnotation(anotacion)
                    self.mapamk.selectAnnotation(anotacion, animated: true)
                    
                   
                    
                    self.trazarRuta(coordenadasDestino: destinoRuta.coordinate)
                    
                   
                }else{
                    print("No se encontró el lugar")
                  //  print("No se encontró \(error?.localizedDescription)")
                    let alerta2 = UIAlertController(title: "Error", message: "Lugar no encontrado", preferredStyle: .alert)
                    
                    let accionAceptar2 = UIAlertAction(title: "Aceptar", style: .default, handler: nil)
                    
                    alerta2.addAction(accionAceptar2)
                    self.present(alerta2, animated: true)
                }
            }
        }
    }
}

extension ViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let ubicacion = locations.first else{
            return
        }
        latitud = ubicacion.coordinate.latitude
       longitud = ubicacion.coordinate.longitude
        altitud = ubicacion.altitude
        
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error \(error.localizedDescription)")
    }
 
    
}
