//
//  MasterViewController.m
//  MicroPDF
//
//  Created by Varun Mulloli on 10/11/12.
//  Copyright (c) 2012 Varun Mulloli. All rights reserved.
//

#import "MasterViewController.h"

@implementation MasterViewController

@synthesize connection, filePath, fileStream;

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    isDownloading = NO;
    
    //Top navigation bar configuration
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    //Bottom toolbar configuration
    progressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    progressBar.progress = 0.0;
    progressBar.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *progBar = [[UIBarButtonItem alloc] initWithCustomView:progressBar];
    cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(cancelDownload:)];
    cancelButton.enabled = NO;
    
    toolbarItems = [NSArray arrayWithObjects:flex,progBar,flex,cancelButton,flex,nil];
    
    ////////////////////////////////////////////////////////////////////////////////////////
     //FOR TESTING PURPOSES ONLY
     NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
     NSUserDomainMask, YES);
     NSString *path = [[pathArray objectAtIndex:0] stringByAppendingPathComponent:@"Test PDF.pdf"];
     BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:path];
     if (!fileExists)
     {
     NSString *originalPath = [[NSBundle mainBundle] pathForResource:@"Test PDF"
     ofType:@"pdf"];
     NSData *items = [NSData dataWithContentsOfFile:originalPath];
     [items writeToFile:path atomically:YES];
     }
     ////////////////////////////////////////////////////////////////////////////////////////
    
    // restore search settings if they were saved in didReceiveMemoryWarning.
    if (savedSearchTerm)
	{
        [self.searchDisplayController setActive:searchWasActive];
        [self.searchDisplayController.searchBar setText:savedSearchTerm];
        
        savedSearchTerm = nil;
    }
    
    [self.tableView reloadData];
	self.tableView.scrollEnabled = YES;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (isDownloading)
        self.toolbarItems = toolbarItems;
    [self loadFilesFromDocumentDirectory];
    [self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    // save the state of the search UI so that it can be restored if the view is re-created
    searchWasActive = [self.searchDisplayController isActive];
    savedSearchTerm = [self.searchDisplayController.searchBar text];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void) loadFilesFromDocumentDirectory
{
    listPathContent = nil;
    listContent = nil;
    filteredListContent = nil;
    
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
    listPathContent = [[[NSBundle bundleWithPath:[pathArray objectAtIndex:0]] pathsForResourcesOfType:@"pdf" inDirectory:nil] mutableCopy];
    
    listContent = [NSMutableArray new];
    
    for (NSInteger i=0; i<listPathContent.count; i++)
    {
        NSString *thefilename = [[listPathContent objectAtIndex:i] lastPathComponent];
        
        [listContent addObject:thefilename];
    }
    
    // create a filtered list that will contain products for the search results table.
    filteredListContent = [NSMutableArray arrayWithCapacity:[listContent count]];
}

#pragma mark - Table View

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //If the requesting table view is the search display controller's table view, return the count of the filtered list, otherwise return the count of the main list.
	if (tableView == self.searchDisplayController.searchResultsTableView)
        return [filteredListContent count];
	else
        return self.editing ? [listContent count]+1 : [listContent count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Configure Cell Identifier
    NSString *cellID = @"Cell";
    if (indexPath.row == 0 && self.editing && tableView != self.searchDisplayController.searchResultsTableView)
        cellID = @"AddCell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellID];
    
    //If the cell is the "Add New PDF" cell
    if (indexPath.row == 0 && self.editing && tableView != self.searchDisplayController.searchResultsTableView)
    {
        ((UITextField *)[cell viewWithTag:1]).delegate = self;
        return cell;
    }
    
    //If the table is in editing mode
    if(self.editing && indexPath.row!=0 && tableView != self.searchDisplayController.searchResultsTableView)
    {
        NSString *object = [listContent objectAtIndex:indexPath.row-1];
        
        cell.textLabel.text = object;
        return cell;
    }
    
    NSString *object = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView)
        object = [filteredListContent objectAtIndex:indexPath.row];
    else
        object = [listContent objectAtIndex:indexPath.row];
    
    cell.textLabel.text = object;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.editing;
}

- (UITableViewCellEditingStyle) tableView: (UITableView *) tableView
            editingStyleForRowAtIndexPath: (NSIndexPath *) indexPath
{
    if (indexPath.row == 0 && self.editing)
        return UITableViewCellEditingStyleInsert;
    else
        return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        //Delete the PDF from the Documents folder
        [[NSFileManager defaultManager] removeItemAtPath:[listPathContent objectAtIndex:indexPath.row-1] error:nil];
        
        //Remove its data from the table
        [listContent removeObjectAtIndex:indexPath.row-1];
        [listPathContent removeObjectAtIndex:indexPath.row-1];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView reloadData];
    
    //Animate the "Add New PDF" cell
    if(editing)
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showPDF"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        PDFPageViewController *readerViewController = [segue destinationViewController];
        readerViewController.bookName = [listContent objectAtIndex:indexPath.row];
    }
}

#pragma mark - Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	
    [filteredListContent removeAllObjects];
	
	//Search the main list for products whose name matches searchText; add items that match to the filtered array.
	for (NSString *product in listContent)
	{
        if ([product rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound)
            [filteredListContent addObject:product];
	}
}

#pragma mark - UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:nil];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

#pragma mark - UITextField Delegate Methods

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    url = [[NetworkManager sharedInstance] smartURLForString:textField.text];
    
    if (!isDownloading)
        [self startReceive];
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Download queue full"
                              message:@"There's already an active download in progress."
                              delegate:nil
                              cancelButtonTitle:@"Dismiss"
                              otherButtonTitles:nil, nil];
        [alert show];
    }
    
    return YES;
}

#pragma mark - Download Manager

- (void)startReceive
{
    assert(connection == nil);         // don't tap receive twice in a row!
    assert(fileStream == nil);         // ditto
    assert(filePath == nil);           // ditto
    
    isDownloading = YES;
    cancelButton.enabled = YES;
    [self.navigationController.toolbar setItems:toolbarItems animated:YES];
    
    //Check the URL.
    if (url != nil)
    {
        // Open a connection for the URL.
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        assert(request != nil);
        
        connection = [NSURLConnection connectionWithRequest:request delegate:self];
        assert(connection != nil);
        
        cancelButton.enabled = YES;
        
        [[NetworkManager sharedInstance] didStartNetworkOperation];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Error"
                              message:@"Invalid URL."
                              delegate:nil
                              cancelButtonTitle:@"Dismiss"
                              otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void) connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
{
#pragma unused(theConnection)
    assert(theConnection == connection);
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    
    if ((httpResponse.statusCode / 100) != 2)
    {
        [self stopReceiveWithStatus:[NSString stringWithFormat:@"HTTP error : %zd", (ssize_t) httpResponse.statusCode]];
    }
    else
    {
        totalDownloadSize = [httpResponse expectedContentLength];
        currentDownloadSize = 0;
        
        // -MIMEType strips any parameters, strips leading or trailer whitespace, and lower cases
        // the string, so we can just use -isEqual: on the result.
        NSString *contentTypeHeader = [httpResponse MIMEType];
        
        if (contentTypeHeader == nil)
        {
            [self stopReceiveWithStatus:@"No Content-Type!"];
        }
        else if ( ! [contentTypeHeader isEqual:@"application/pdf"])
        {
            [self stopReceiveWithStatus:[NSString
                                         stringWithFormat:@"Unsupported Content-Type (%@)", contentTypeHeader]];
        }
        else
        {
            //Create the file's path
            NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                     NSUserDomainMask, YES);
            NSString *documentDirectory = [pathArray objectAtIndex:0];
            filePath = [documentDirectory stringByAppendingPathComponent:[url lastPathComponent]];
            
            //If the file already exists, get a new filename
            BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
            NSInteger i = 1;
            while (fileExists)
            {
                NSString *fileName = [[url URLByDeletingPathExtension] lastPathComponent];
                NSString *newFileName = [NSString stringWithFormat:@"%@-%d.%@",fileName,i,[url pathExtension]];
                i += 1;
                filePath = [documentDirectory stringByAppendingPathComponent:newFileName];
                fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
            }
            
            assert(filePath != nil);
            
            fileStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
            assert(fileStream != nil);
            
            [fileStream open];
            
            progressBar.progress = 0.0;
        }
    }
}

- (void) connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data
{
#pragma unused(theConnection)
    assert(theConnection == connection);
    
    NSInteger dataLength = [data length];
    const uint8_t *dataBytes = [data bytes];
    
    NSInteger bytesWritten, bytesWrittenSoFar;
    
    currentDownloadSize += dataLength;
    progressBar.progress = (float)currentDownloadSize / (float)totalDownloadSize;
    
    bytesWrittenSoFar = 0;
    do
    {
        bytesWritten = [fileStream write:&dataBytes[bytesWrittenSoFar] maxLength:dataLength - bytesWrittenSoFar];
        assert(bytesWritten != 0);
        if (bytesWritten == -1)
        {
            [self stopReceiveWithStatus:@"File write error"];
            break;
        }
        else
        {
            bytesWrittenSoFar += bytesWritten;
        }
    } while (bytesWrittenSoFar != dataLength);
}

- (void) connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
{
#pragma unused(theConnection)
#pragma unused(error)
    assert(theConnection == connection);
    
    [self stopReceiveWithStatus:@"Connection failed"];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)theConnection
{
#pragma unused(theConnection)
    assert(theConnection == connection);
    
    [self stopReceiveWithStatus:nil];
}

- (void) stopReceiveWithStatus:(NSString *)statusString
{
    if (connection != nil)
    {
        [connection cancel];
        connection = nil;
    }
    if (fileStream != nil)
    {
        [fileStream close];
        fileStream = nil;
    }
    
    if (statusString == nil)
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Download Complete"
                              message:@"File added to Library."
                              delegate:nil
                              cancelButtonTitle:@"Okay"
                              otherButtonTitles:nil, nil];
        [alert show];
        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Error"
                              message:statusString
                              delegate:nil
                              cancelButtonTitle:@"Dismiss"
                              otherButtonTitles:nil, nil];
        [alert show];
        
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
        if (fileExists)
        {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
    }
    
    filePath = nil;
    
    progressBar.progress = 0.0;
    cancelButton.enabled = NO;
    isDownloading = NO;
    [self.navigationController.toolbar setItems:nil animated:YES];
    
    [self loadFilesFromDocumentDirectory];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [[NetworkManager sharedInstance] didStopNetworkOperation];
}

- (void)cancelDownload:(id)sender
{
    [self stopReceiveWithStatus:@"Download aborted by user."];
}

@end
