//
//  SettingsViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/24/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <SPHipster/SPHipster.h>
#import "SettingsTableViewCell.h"
#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

#pragma mark SettingsViewController

@implementation SettingsViewController

NSString * const kSettingsDataSourceTitleKey = @"kSettingsDataSourceTitleKey";
NSString * const kSettingsDataSourceValueKey = @"kSettingsDataSourceValueKey";
NSString * const kSettingsDataSourceActionKey = @"kSettingsDataSourceActionKey";
NSString * const kSettingsDataSourceItemsKey = @"kSettingsDataSourceItemsKey";
NSString * const kSettingsDataSourceSelectorKey = @"kSettingsDataSourceSelectorKey";
NSString * const kChangelogUrlString = @"https://rink.hockeyapp.net/apps/5ab6b4328d609707f1f9eb28b90c61b6";

#pragma mark - Class Methods

#pragma mark - Getters/Setters

- (NSArray *)dataSource {
    if (!_dataSource) {
        NSMutableArray *commits = [NSMutableArray new];
        for (NSString *commit in [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CommitHistory"] componentsSeparatedByString:@"\n"]) {
            NSString *text = [[commit componentsSeparatedByString:@" - "].lastObject componentsSeparatedByString:@"("].firstObject;
            [commits addObject:@{kSettingsDataSourceTitleKey : text, kSettingsDataSourceValueKey : @""}];
        }
        
        _dataSource = @[@{kSettingsDataSourceTitleKey : SPGetApplicationName(),
                          kSettingsDataSourceItemsKey : @[@{kSettingsDataSourceTitleKey : @"Build type",
                                                            kSettingsDataSourceValueKey : NSStringFromBuildType(SPGetBuildType())},
                                                          @{kSettingsDataSourceTitleKey : @"Changelog",
                                                            kSettingsDataSourceValueKey : @"HockeyApp",
                                                            kSettingsDataSourceActionKey : @YES,
                                                            kSettingsDataSourceSelectorKey : NSStringFromSelector(@selector(openChangelog:))},
                                                          @{kSettingsDataSourceTitleKey : @"Commit history",
                                                            kSettingsDataSourceValueKey : @"",
                                                            kSettingsDataSourceActionKey : @YES,
                                                            kSettingsDataSourceItemsKey : @[@{kSettingsDataSourceTitleKey : @"",
                                                                                              kSettingsDataSourceItemsKey : commits}]},
                                                          @{kSettingsDataSourceTitleKey : @"Version",
                                                            kSettingsDataSourceValueKey : SPGetApplicationVersion()}]}];
    }
    return _dataSource;
}

#pragma mark - Instance Methods

- (void)openChangelog:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kChangelogUrlString]];
}

#pragma mark - Delegates & Data sources

#pragma mark - UITableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource[section][kSettingsDataSourceItemsKey] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsCell" forIndexPath:indexPath];
    cell.textLabel.text = self.dataSource[indexPath.section][kSettingsDataSourceItemsKey][indexPath.row][kSettingsDataSourceTitleKey];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.detailTextLabel.text = self.dataSource[indexPath.section][kSettingsDataSourceItemsKey][indexPath.row][kSettingsDataSourceValueKey];
    if ([self.dataSource[indexPath.section][kSettingsDataSourceItemsKey][indexPath.row][kSettingsDataSourceActionKey] boolValue]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.dataSource[section][kSettingsDataSourceTitleKey];
}

#pragma mark - UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.dataSource[indexPath.section][kSettingsDataSourceItemsKey][indexPath.row][kSettingsDataSourceActionKey] boolValue]) {
        SettingsViewController *settingsViewController = [SettingsViewController new];
        settingsViewController.title = self.dataSource[indexPath.section][kSettingsDataSourceItemsKey][indexPath.row][kSettingsDataSourceTitleKey];
        if (self.dataSource[indexPath.section][kSettingsDataSourceItemsKey][indexPath.row][kSettingsDataSourceSelectorKey]) {
            SEL selector = NSSelectorFromString(self.dataSource[indexPath.section][kSettingsDataSourceItemsKey][indexPath.row][kSettingsDataSourceSelectorKey]);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self performSelector:selector withObject:[tableView cellForRowAtIndexPath:indexPath]];
#pragma clang diagnostic pop
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        } else {
            settingsViewController.dataSource = self.dataSource[indexPath.section][kSettingsDataSourceItemsKey][indexPath.row][kSettingsDataSourceItemsKey];
            [self.navigationController pushViewController:settingsViewController animated:YES];
        }
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    if (self.title.length == 0) {
        self.title = NSLocalizedString(@"Settings", @"Settings");
    }
    
    if (self.dataSource.count == 1 && [self.dataSource[0][kSettingsDataSourceTitleKey] length] == 0) {
        self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    } else {
        self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    }
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:[SettingsTableViewCell class] forCellReuseIdentifier:@"SettingsCell"];
    [self.view addSubview:self.tableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.tableView.indexPathForSelectedRow) {
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
