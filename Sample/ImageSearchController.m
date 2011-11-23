//
//  ImageSearchController.m
//  MoViCoKit
//
//  Created by Igor Fedorov on 8/13/11.
//  Copyright 2011. All rights reserved.
//

#import "ImageSearchController.h"
#import "ImageSearchRequest.h"
#import "FlickrPhoto.h"
#import "LinkImageCell.h"
#import "LinkImage.h"

@interface ImageSearchController()

@property (nonatomic, strong) UITableView *resultsTable;
@property (nonatomic, strong) ImageSearchRequest *searchRequest;
@property (nonatomic, strong) NSMutableDictionary *imageCache;
@property (nonatomic, strong) NSOperationQueue *upQueue;

@end


@implementation ImageSearchController

@synthesize upQueue;
@synthesize imageCache;
@synthesize resultsTable;
@synthesize searchRequest;

#pragma mark -
#pragma mark Initialization

- (id)init {
	self = [super init];
	self.upQueue = [[NSOperationQueue alloc] init];
	self.searchRequest = [[ImageSearchRequest alloc] init];
	return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	UISearchBar *searchBar = [[UISearchBar alloc] init];
	searchBar.delegate = (id<UISearchBarDelegate>)self;
	[searchBar sizeToFit];
	searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[self.view addSubview:searchBar];
	CGRect tableFrame = CGRectInset(self.view.bounds, 0, searchBar.bounds.size.height / 2);
	tableFrame = CGRectOffset(tableFrame, 0, searchBar.bounds.size.height / 2);
	UITableView *tableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
	tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	tableView.dataSource = (id<UITableViewDataSource>)self;
	tableView.delegate = (id<UITableViewDelegate>)self;
	[self.view addSubview:tableView];
	self.resultsTable = tableView;
}

#pragma mark -
#pragma mark UISearchBarDelegate methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	[self.upQueue cancelAllOperations];
	self.imageCache = [NSMutableDictionary dictionary];
	self.searchRequest.searchText = searchText;
	[self.searchRequest searchWithLimit:4];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	if ([searchBar isFirstResponder]) {
		[searchBar resignFirstResponder];
	}
	[self.searchRequest searchWithLimit:1000];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.searchRequest.results count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    LinkImageCell *cell = (LinkImageCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[LinkImageCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    FlickrPhoto *photo = [self.searchRequest.results objectAtIndex:indexPath.row];
    cell.textLabel.text = photo.title;
	NSURL *imageURL = [photo smallImageURl];
	if ([self.imageCache objectForKey:imageURL] == nil) {
		LinkImage *image = [LinkImage imageWithLink:imageURL];
		[self.imageCache setObject:image forKey:imageURL];
	}
	
	cell.linkImage = [self.imageCache objectForKey:imageURL];
    
	return cell;
}


#pragma mark -
#pragma mark Memory management

- (void)viewDidUnload {
	self.resultsTable = nil;
}

- (void)didReceiveMemoryWarning {
	[self.imageCache removeAllObjects];
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	[self.upQueue cancelAllOperations];
    self.searchRequest = nil;
}

#pragma mark -
#pragma mark ModelControllerDelegate methods

- (NSArray*)interestedModels {
	NSArray *models = [super interestedModels];
	IF_NOT_NIL_ADD_TO_ARRAY(self.searchRequest, &models);
	return models;
}

- (void)modelDidUpdate:(id)aModel {
	[super modelDidUpdate:aModel];
	[self.upQueue setMaxConcurrentOperationCount:[self.searchRequest.results count]];
	[self.resultsTable reloadData];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)modelWillUpdate:(id)aModel {
	[super modelWillUpdate:aModel];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

@end

