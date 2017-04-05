//
//  ViewController.h
//  Map
//
//  Created by INDOBYTES on 05/04/17.
//  Copyright © 2017 sai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface ViewController : UIViewController<MKAnnotation>
{
    CLLocationCoordinate2D  coordinate;
    NSString*               title;
    NSString*               subtitle;
    
    ViewController * myAnnotation;
    NSMutableArray *annotations;
    float source_lat,source_lon,Destination_lat,Destination_lon;
}
@property (strong, nonatomic) IBOutlet MKMapView *map;
@property (nonatomic, assign)CLLocationCoordinate2D coordinate;
@property (nonatomic, copy)NSString *title;
@property (nonatomic, copy)NSString *subtitle;

@property (strong, nonatomic) MKPlacemark *destination;
@property (strong,nonatomic) MKPlacemark *source;

@end

