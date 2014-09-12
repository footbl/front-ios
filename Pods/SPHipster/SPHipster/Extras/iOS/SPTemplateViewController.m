//
//  SPTemplateViewController.m
//  SPHipster
//
//  Created by Fernando Saragoça on 1/23/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "SPTemplateViewController.h"

@interface SPTemplateViewController ()

// NSFetchedResultsController updates done right: http://www.fruitstandsoftware.com/blog/2013/02/uitableview-and-nsfetchedresultscontroller-updates-done-right/
@property (nonatomic, strong) NSMutableIndexSet *deletedSectionIndexes;
@property (nonatomic, strong) NSMutableIndexSet *insertedSectionIndexes;
@property (nonatomic, strong) NSMutableArray *deletedRowIndexPaths;
@property (nonatomic, strong) NSMutableArray *insertedRowIndexPaths;
@property (nonatomic, strong) NSMutableArray *updatedRowIndexPaths;

@end

#pragma mark SPTemplateViewController

@implementation SPTemplateViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

- (NSMutableIndexSet *)deletedSectionIndexes {
    if (_deletedSectionIndexes == nil) {
        self.deletedSectionIndexes = [NSMutableIndexSet new];
    }
    
    return _deletedSectionIndexes;
}

- (NSMutableIndexSet *)insertedSectionIndexes {
    if (_insertedSectionIndexes == nil) {
        self.insertedSectionIndexes = [NSMutableIndexSet new];
    }
    
    return _insertedSectionIndexes;
}

- (NSMutableArray *)deletedRowIndexPaths {
    if (_deletedRowIndexPaths == nil) {
        self.deletedRowIndexPaths = [NSMutableArray new];
    }
    
    return _deletedRowIndexPaths;
}

- (NSMutableArray *)insertedRowIndexPaths {
    if (_insertedRowIndexPaths == nil) {
        self.insertedRowIndexPaths = [NSMutableArray new];
    }
    
    return _insertedRowIndexPaths;
}

- (NSMutableArray *)updatedRowIndexPaths {
    if (_updatedRowIndexPaths == nil) {
        self.updatedRowIndexPaths = [NSMutableArray new];
    }
    
    return _updatedRowIndexPaths;
}

#pragma mark - Instance Methods

#pragma mark - Delegates & Data sources

#pragma mark - UITableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
    return sectionInfo.numberOfObjects;
}

#pragma mark - NSFetchedResultsController delegate

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    if (![self respondsToSelector:@selector(tableView)]) {
        return;
    }
    
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[self.insertedSectionIndexes addIndex:sectionIndex];
			break;
		case NSFetchedResultsChangeDelete:
			[self.deletedSectionIndexes addIndex:sectionIndex];
			break;
        default:
            break;
	}
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    if (![self respondsToSelector:@selector(tableView)]) {
        return;
    }
    
    if (type == NSFetchedResultsChangeInsert) {
        if ([self.insertedSectionIndexes containsIndex:newIndexPath.section]) {
            return;
        }
        
        [self.insertedRowIndexPaths addObject:newIndexPath];
    } else if (type == NSFetchedResultsChangeDelete) {
        if ([self.deletedSectionIndexes containsIndex:indexPath.section]) {
            return;
        }
        
        [self.deletedRowIndexPaths addObject:indexPath];
    } else if (type == NSFetchedResultsChangeMove) {
        if ([self.insertedSectionIndexes containsIndex:newIndexPath.section] == NO) {
            [self.insertedRowIndexPaths addObject:newIndexPath];
        }
        
        if ([self.deletedSectionIndexes containsIndex:indexPath.section] == NO) {
            [self.deletedRowIndexPaths addObject:indexPath];
        }
    } else if (type == NSFetchedResultsChangeUpdate) {
        [self.updatedRowIndexPaths addObject:indexPath];
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (![self respondsToSelector:@selector(tableView)]) {
        return;
    }
    
    NSInteger totalChanges = self.deletedSectionIndexes.count + self.insertedSectionIndexes.count + self.deletedRowIndexPaths.count + self.insertedRowIndexPaths.count + self.updatedRowIndexPaths.count;
    
    if (totalChanges > 50) {
        self.insertedSectionIndexes = nil;
        self.deletedSectionIndexes = nil;
        self.insertedRowIndexPaths = nil;
        self.deletedRowIndexPaths = nil;
        self.updatedRowIndexPaths = nil;
        [self.tableView reloadData];
        return;
    }
    
    [self.tableView beginUpdates];
    
    [self.tableView deleteRowsAtIndexPaths:[self deletedRowIndexPaths] withRowAnimation:UITableViewRowAnimationLeft];
    [self.tableView deleteSections:[self deletedSectionIndexes] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView insertSections:[self insertedSectionIndexes] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView insertRowsAtIndexPaths:[self insertedRowIndexPaths] withRowAnimation:UITableViewRowAnimationLeft];
    
    @try {
        for (NSIndexPath *indexPath in self.updatedRowIndexPaths) {
            [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
        }
    }
    @catch (NSException *exception) {
        [self.tableView reloadRowsAtIndexPaths:self.updatedRowIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    [self.tableView endUpdates];
    
    self.insertedSectionIndexes = nil;
    self.deletedSectionIndexes = nil;
    self.insertedRowIndexPaths = nil;
    self.deletedRowIndexPaths = nil;
    self.updatedRowIndexPaths = nil;
}

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
