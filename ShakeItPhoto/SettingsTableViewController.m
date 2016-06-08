//
//  SettingsTableViewController.m
//  BananaCamera
//
//  Created by Isaac Ruiz on 9/28/14.
//
//

#import "SettingsTableViewController.h"
#import "BananaCameraConstants.h"
#import "ShakeItPhotoConstants.h"
#import "WebViewController.h"

@interface SettingsTableViewController ()

@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"%@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"%@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    
    switch (indexPath.row) {
        case 0:
        case 1:
        case 2:
        case 3:
            cell.accessoryView = [[UISwitch alloc] init];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
        default:
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            break;
    }
    
    if(indexPath.row <= 3) {
        
        NSUserDefaults*     defaults = [NSUserDefaults standardUserDefaults];
        UISwitch*           aSwitch  = (UISwitch*)cell.accessoryView;
        aSwitch.tag = indexPath.row;
        
        [aSwitch addTarget:self action:@selector(onSwitch:) forControlEvents:UIControlEventValueChanged];
        
        switch (indexPath.row) {
            case 0:
                aSwitch.on = [defaults boolForKey: kShakeItPhotoPolaroidBorderKey];
                break;
            case 1:
                aSwitch.on = [defaults boolForKey: kShakeItPhotoFasterShakingKey];
                break;
            case 2:
                aSwitch.on = [defaults boolForKey: kBananaCameraSaveOriginalKey];
                break;
            case 3:
                aSwitch.on = [defaults boolForKey: kShakeItPhotoMakeSquareKey];
                break;
        }
    }
    
    switch (indexPath.row) {
        case 0:
        {
            NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"Polaroid Photo"];
            [str addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:cell.textLabel.font.pointSize] range:NSMakeRange(0, 8)];
            cell.textLabel.attributedText = str;
        }
            
            break;
        case 1:
            cell.textLabel.text = @"Fast Processing";
            break;
        case 2:
            cell.textLabel.text = @"Keep Original";
            break;
        case 3:
            cell.textLabel.text = @"MakeSquare™";
            break;
        case 4:
            cell.textLabel.text = @"More Apps";
            break;
      
        default:
            break;
    }
    
    return cell;
}

-(void)onSwitch:(id)sender {
    
    UISwitch* aSwitch  = (UISwitch*)sender;
   
    NSUserDefaults*     defaults = [NSUserDefaults standardUserDefaults];
    BOOL isOn = aSwitch.on;
    switch (aSwitch.tag) {
        case 0:
            [defaults setBool:isOn forKey:kShakeItPhotoPolaroidBorderKey];
            break;
        case 1:
            [defaults setBool:isOn forKey:kShakeItPhotoFasterShakingKey];
            break;
        case 2:
            [defaults setBool:isOn forKey:kBananaCameraSaveOriginalKey];
            break;
        case 3:
            [defaults setBool:isOn forKey:kShakeItPhotoMakeSquareKey];
            break;
            
            
        default:
            break;
    }
    
    [defaults synchronize];
}



#pragma mark -
#pragma mark UITableViewDelegate

- (UIView*) tableView: (UITableView*) tableView viewForHeaderInSection: (NSInteger) section
{
    return nil;
}

- (CGFloat) tableView: (UITableView*) tableView heightForFooterInSection: (NSInteger) section
{
    return _footerView.frame.size.height;
}

- (UIView*) tableView: (UITableView*) tableView viewForFooterInSection: (NSInteger) section
{
    CGRect frame = _footerView.frame;
    frame.size.width = self.view.frame.size.width;
    [_footerView setFrame:frame];
    
    return _footerView;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    
    
    //NSURL *url;
    switch (indexPath.row) {
        case 4:
            //url = [NSURL URLWithString:kBananaCameraMoreAppsURL];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kBananaCameraMoreAppsURL]];
            //return;
            break;
        default:
            return;
            break;
    }

    //UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //WebViewController *webview = [[WebViewController alloc] init];
    //webview.url = url;
    //webview.title = cell.textLabel.text;
    //[self.navigationController pushViewController:webview animated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
