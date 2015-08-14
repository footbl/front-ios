//
//  SPTemplateViewControllerProtocol.h
//  SPHipster iOS Example
//
//  Created by Fernando Saragoça on 1/23/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SPTemplateViewControllerProtocol <NSObject, NSFetchedResultsControllerDelegate>

@optional
- (UITableView *)tableView;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (NSFetchedResultsController *)fetchedResultsController;

@end
