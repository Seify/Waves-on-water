//
//  DetailSettingsTableViewController.m
//  Water
//
//  Created by Roman Smirnov on 21.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DetailSettingsTableViewController.h"
#import "WaveTypeSelectorTableViewController.h"

@implementation DetailSettingsTableViewController

@synthesize delegate;
@synthesize wave = _wave;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    
    int retValue;
    switch (self.wave.type) {
        case WAVE_TYPE_HARMONIC:
            retValue = 6;
            break;
        case WAVE_TYPE_SPHERICAL:
            retValue = 7;
            break;
        case WAVE_TYPE_SPIRAL:
            retValue = 7;
            break;
            
        default:
            retValue = 0;
            break;
    }
    return retValue;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
//    Wave *wave = [self.delegate.waves objectAtIndex:section
    switch (section) {
        case 0:
            return @"Type";
        case 1:
            return @"Amplitude";
//            return [NSString stringWithFormat:@"Amplitude = %f", self.wave.amplitude];
            break;
        case 2:
            return @"Wavenumber";
            break;
        case 3: 
            return @"Angular frequency";
            break;
        case 4:
            return @"Phase";
            break;
        case 5:
            switch (self.wave.type) {
                case WAVE_TYPE_HARMONIC:
                    return @"Direction";
                    break;
                case WAVE_TYPE_SPHERICAL:
                case WAVE_TYPE_SPIRAL:
                    return @"Center X position";
                    break;
                    
                default:
                    break;
            }
            break;
        case 6:
            return @"Center Y position";
            break;
        default:
            break;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    CGRect frame = CGRectMake(0, 
                              0, 
                              cell.contentView.frame.size.width - 20, 
                              cell.contentView.frame.size.height);

    
    if (indexPath.section == 0) {
//        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
//        cell.textLabel.textAlignment = UITextAlignmentCenter;

        switch (self.wave.type) {
            case WAVE_TYPE_HARMONIC:
//                cell.imageView.image = [UIImage imageNamed:@"waterTexture1024.jpg"];
                cell.textLabel.text = @"Harmonic";
                break;
            case WAVE_TYPE_SPHERICAL:
//                cell.imageView.image = [UIImage imageNamed:@"Icon-72.png"];
                cell.textLabel.text = @"Spherical";
                break;
            case WAVE_TYPE_SPIRAL:
//                cell.imageView.image = [UIImage imageNamed:@"spiral_small.png"];
                cell.textLabel.text = @"Spiral";
                break;
                
            default:
                break;
        }
        
    } else {
        NSArray *subs = cell.contentView.subviews;
        if ([[subs lastObject] isKindOfClass:[UISlider class]]) {
            [[subs lastObject] removeFromSuperview]; 
        }
        UISlider *slider = [[UISlider alloc] initWithFrame:frame];
        slider.tag = indexPath.section;
        [slider addTarget:self action:@selector(sliderUpdate:) 
         forControlEvents:UIControlEventValueChanged];    
        
        
        switch (indexPath.section) {
            case 1: //Amplitude
                slider.minimumValue =  0.0f;
                slider.maximumValue =  1.0f;
                slider.value = self.wave.amplitude;
    //            cell.textLabel.text = self.wave.name;
                break;
            case 2: //Wavenumber
                slider.minimumValue = 0.0f;
                slider.maximumValue = 2.5f;
                slider.value = self.wave.wavenumber;
    //            cell.textLabel.text = [NSString stringWithFormat:@"%f", self.wave.amplitude];
                break;
            case 3: //Angular frequency
                slider.minimumValue = 0.0f;
                slider.maximumValue = 5.0f;
                slider.value = self.wave.angularFrequency;
                slider.continuous = NO;
                break;
            case 4: //Phase
                slider.minimumValue = 0;
                slider.maximumValue = 2 * M_PI;
                slider.value = self.wave.phase;
                break;
            case 5: //Direction OR PositionX
                switch (self.wave.type) {
                    case WAVE_TYPE_HARMONIC:
                        slider.minimumValue = 0;
                        slider.maximumValue = 2 * M_PI;
                        slider.value = self.wave.direction;                        
                        break;
                    case WAVE_TYPE_SPHERICAL:
                    case WAVE_TYPE_SPIRAL:
                        slider.minimumValue = -10.0;
                        slider.maximumValue = 10.0;
                        slider.value = self.wave.positionX;                        
                        break;
                    default:
                        break;
                }
                break;
            case 6: //PositionY
                slider.minimumValue = -10.0;
                slider.maximumValue = 10.0;
                slider.value = self.wave.positionY;                   
                break;
                
            default:
                break;
        }
        
        [cell.contentView addSubview:slider];    
        
    }
    
    cell.tag = indexPath.section;
        
        
    
    return cell;
}

- (void)sliderUpdate:(UISlider *)slider
{
    
    switch (slider.tag) {
        case 1: {
            self.wave.amplitude = slider.value;
//            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:slider.tag] ];
            break;
        }
        case 2:
            self.wave.wavenumber = slider.value;
            break;
        case 3:
            self.wave.angularFrequency = slider.value;
            break;
        case 4:
            self.wave.phase = slider.value;
            break;
        case 5:
            switch (self.wave.type) {
                case WAVE_TYPE_HARMONIC:
                    self.wave.direction = slider.value;
                    NSLog(@"sliderValue = %f", slider.value);
                    break;
                case WAVE_TYPE_SPHERICAL:
                case WAVE_TYPE_SPIRAL:
                    self.wave.positionX = slider.value;
                    break;
                    
                default:
                    break;
            }
            break;
        case 6:
            self.wave.positionY = slider.value;
            break;
        default:
            break;
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    WaveTypeSelectorTableViewController *detailViewController = [[WaveTypeSelectorTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    detailViewController.delegate = self.delegate;
    detailViewController.parentDelegate = self;
    detailViewController.wave = self.wave;
    
    detailViewController.tableView.scrollEnabled = NO;
    [self.navigationController pushViewController:detailViewController animated:YES];
    
}

@end
