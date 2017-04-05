//
//  ViewController.m
//  Map
//
//  Created by INDOBYTES on 05/04/17.
//  Copyright © 2017 sai. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize title;
@synthesize subtitle;
@synthesize coordinate;
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //For Travelling Time
    //steeloncall
//    source_lat=17.443041;
//    source_lon=78.383932;

    //karachi bakery
    source_lat=17.445029;
    source_lon=78.385676;
    
    //cyber towers
    Destination_lat=17.450415;
    Destination_lon=78.381095;
    
    NSString *strUrl = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&sensor=false&mode=%@", Destination_lat,  Destination_lon, source_lat,  source_lon, @"DRIVING"];
    NSURL *url = [NSURL URLWithString:[strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSData *jsonData = [NSData dataWithContentsOfURL:url];
    if(jsonData != nil)
    {
        NSError *error = nil;
        id result = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        NSMutableArray *arrDistance=[result objectForKey:@"routes"];
        if ([arrDistance count]==0)
        {
            NSLog(@"N.A.");
        }
        else
        {
            NSMutableArray *arrLeg=[[arrDistance objectAtIndex:0]objectForKey:@"legs"];
            NSMutableDictionary *dictleg=[arrLeg objectAtIndex:0];
            NSLog(@"%@",[NSString stringWithFormat:@"Estimated Time %@",[[dictleg   objectForKey:@"duration"] objectForKey:@"text"]]);
        }
    }
    else
    {
        NSLog(@"N.A.");
    }
    //for showing two points
    _map.showsUserLocation = YES;
    _map.delegate = self;
    
    annotations = [[NSMutableArray alloc] init];
    NSString *lat1=[NSString stringWithFormat:@"%f",source_lat];
    NSString *lat2=[NSString stringWithFormat:@"%f",Destination_lat];
    NSString *lon1=[NSString stringWithFormat:@"%f",source_lon];
    NSString *lon2=[NSString stringWithFormat:@"%f",Destination_lon];
    
    NSArray * arrayLatitude = [[NSArray alloc]initWithObjects:lat1,lat2,nil];
    NSArray * arrayLongitude = [[NSArray alloc]initWithObjects:lat1,lat2,nil];
    NSArray * arrayName = [[NSArray alloc]initWithObjects:@"SteelonCall",@"Cyber Towers",nil];

    for (int i=0; i<[arrayLatitude count]; i++)
    {
        CLLocationCoordinate2D theCoordinate1;
        
        theCoordinate1.latitude  = [[arrayLatitude objectAtIndex:i] floatValue];
        theCoordinate1.longitude = [[arrayLongitude objectAtIndex:i] floatValue];
        
        myAnnotation = [[ViewController alloc] init];
        myAnnotation.coordinate = theCoordinate1;
        myAnnotation.title      = [arrayName objectAtIndex:i];
        [_map addAnnotation:myAnnotation];
        [annotations addObject:myAnnotation];
    }
    
    
    NSLog(@"%lu",(unsigned long)[annotations count]);
    
    
    MKMapRect flyTo = MKMapRectNull;
    for (id <MKAnnotation> annotation in annotations)
    {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
        if (MKMapRectIsNull(flyTo))
        {
            flyTo = pointRect;
        }
        else
        {
            flyTo = MKMapRectUnion(flyTo, pointRect);
        }
    }
    
    /*
    // center map
    CLLocationCoordinate2D startCoord = CLLocationCoordinate2DMake(17.443041, 78.383932);
    MKCoordinateRegion adjustedRegion = [_map regionThatFits:MKCoordinateRegionMakeWithDistance(startCoord, 3000000, 3000000)];
    [_map setRegion:adjustedRegion animated:YES];
    [self showLines];
     */
    [self getDirections];

    _map.visibleMapRect = flyTo;

}

//for annotations
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    static NSString* AnnotationIdentifier = @"AnnotationIdentifier";
    MKPinAnnotationView* pinView = [[MKPinAnnotationView alloc]
                                     initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier];
    pinView.animatesDrop   = NO;
    pinView.canShowCallout = YES;
    pinView.pinColor = MKPinAnnotationColorRed;
    
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%i.jpg",rand()%3908+1]]];
    pinView.leftCalloutAccessoryView = icon;
    
    UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [rightButton setTitle:nil forState:UIControlStateNormal];
    [rightButton addTarget:self
                    action:@selector(myMethod:)
          forControlEvents:UIControlEventTouchUpInside];
    pinView.rightCalloutAccessoryView = rightButton;
    
    return pinView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    NSLog(@"Title     : %@",view.annotation.title);
    NSLog(@"Latitude  : %f", view.annotation.coordinate.latitude);
    NSLog(@"Longitude : %f", view.annotation.coordinate.longitude);
}
//for route
-(void)getDirections {
    
    CLLocationCoordinate2D sourceCoords = CLLocationCoordinate2DMake(source_lat, source_lon);
    
    MKCoordinateRegion region;
    //Set Zoom level using Span
    MKCoordinateSpan span;
    region.center = sourceCoords;
    
    span.latitudeDelta = 1;
    span.longitudeDelta = 1;
    region.span=span;
    [_map setRegion:region animated:TRUE];
    
    MKPlacemark *placemark  = [[MKPlacemark alloc] initWithCoordinate:sourceCoords addressDictionary:nil];
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = sourceCoords;
    annotation.title = @"SteelonCall";
    [_map addAnnotation:annotation];
    //[self.myMapView addAnnotation:placemark];
    
    _destination = placemark;
    
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:_destination];
    
    CLLocationCoordinate2D destCoords = CLLocationCoordinate2DMake(Destination_lat,Destination_lon);
    MKPlacemark *placemark1  = [[MKPlacemark alloc] initWithCoordinate:destCoords addressDictionary:nil];
    
    MKPointAnnotation *annotation1 = [[MKPointAnnotation alloc] init];
    annotation1.coordinate = destCoords;
    annotation1.title = @"Cyber Towers";
    [_map addAnnotation:annotation1];
    
    //[self.myMapView addAnnotation:placemark1];
    
    _source = placemark1;
    
    MKMapItem *mapItem1 = [[MKMapItem alloc] initWithPlacemark:_source];
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = mapItem1;
    request.destination = mapItem;
    //request.requestsAlternateRoutes = NO;
    request.requestsAlternateRoutes = YES;

    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:
     ^(MKDirectionsResponse *response, NSError *error)
    {
         if (error)
         {
             NSLog(@"ERROR");
             NSLog(@"%@",[error localizedDescription]);
         }
         else
         {
             [self showRoute:response];
         }
     }];
}

-(void)showRoute:(MKDirectionsResponse *)response
{
    for (MKRoute *route in response.routes)
    {
        [_map
         addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
        
        for (MKRouteStep *step in route.steps)
        {
            NSLog(@"%@", step.instructions);
        }
    }
}

#pragma mark - MKMapViewDelegate methods
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    renderer.strokeColor = [UIColor colorWithRed:0.0/255.0 green:171.0/255.0 blue:253.0/255.0 alpha:1.0];
    renderer.lineWidth = 10.0;
    return  renderer;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
