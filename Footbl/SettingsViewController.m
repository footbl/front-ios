//
//  SettingsViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/24/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <SPHipster/SPHipster.h>
#import "LogsViewController.h"
#import "SettingsTableViewCell.h"
#import "SettingsTextViewController.h"
#import "SettingsViewController.h"

typedef NS_ENUM(NSInteger, SettingsType) {
    SettingsTypeTinyInfo,
    SettingsTypeInfo,
    SettingsTypeAction,
    SettingsTypeMore
};

@interface SettingsViewController ()

@end

#pragma mark SettingsViewController

@implementation SettingsViewController

NSString * const kSettingsDataSourceTitleKey = @"kSettingsDataSourceTitleKey";
NSString * const kSettingsDataSourceValueKey = @"kSettingsDataSourceValueKey";
NSString * const kSettingsDataSourceItemsKey = @"kSettingsDataSourceItemsKey";
NSString * const kSettingsDataSourceExtraKey = @"kSettingsDataSourceExtraKey";
NSString * const kSettingsDataSourceTypeKey = @"kSettingsDataSourceTypeKey";
NSString * const kChangelogUrlString = @"https://rink.hockeyapp.net/apps/5ab6b4328d609707f1f9eb28b90c61b6";

#pragma mark - Class Methods

#pragma mark - Getters/Setters

- (NSArray *)dataSource {
    if (!_dataSource) {
        NSMutableString *commitText = [NSMutableString new];
        for (NSString *commit in [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CommitHistory"] componentsSeparatedByString:@"\n"]) {
            [commitText appendFormat:@"- %@\n\n", commit];
        }
        
        NSMutableArray *logs = [NSMutableArray new];
        NSString *logsFolder = SPLogFilePath();
        for (NSString *logFile in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:logsFolder error:nil]) {
            if ([logFile.lowercaseString rangeOfString:@"ds_store"].location != NSNotFound) {
                continue;
            }
            
            [logs insertObject:@{kSettingsDataSourceTitleKey : logFile, kSettingsDataSourceTypeKey : @(SettingsTypeAction), kSettingsDataSourceExtraKey : NSStringFromSelector(@selector(openLogs:))} atIndex:0];
        }
        
        NSMutableArray *acknowledgements = [NSMutableArray new];
        NSArray *pods = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Pods-acknowledgements" ofType:@"plist"]][@"PreferenceSpecifiers"];
        for (NSInteger i = 0; i < [pods count] - 1; i++) {
            if (i == 0) {
                continue;
            }
            
            [acknowledgements addObject:@{kSettingsDataSourceTitleKey : pods[i][@"Title"], kSettingsDataSourceExtraKey : pods[i][@"FooterText"], kSettingsDataSourceTypeKey : @(SettingsTypeInfo)}];
        }
        
        _dataSource = @[@{kSettingsDataSourceTitleKey : SPGetApplicationName(),
                          kSettingsDataSourceItemsKey : @[@{kSettingsDataSourceTitleKey : NSLocalizedString(@"Acknowledgements", @""),
                                                            kSettingsDataSourceValueKey : @"",
                                                            kSettingsDataSourceTypeKey : @(SettingsTypeMore),
                                                            kSettingsDataSourceExtraKey : @[@{kSettingsDataSourceTitleKey : NSLocalizedString(@"Acknowledgements", @""),
                                                                                              kSettingsDataSourceItemsKey : acknowledgements}]},
                                                          @{kSettingsDataSourceTitleKey : NSLocalizedString(@"Build type", @""),
                                                            kSettingsDataSourceValueKey : NSStringFromBuildType(SPGetBuildType()),
                                                            kSettingsDataSourceTypeKey : @(SettingsTypeTinyInfo)},
                                                          @{kSettingsDataSourceTitleKey : NSLocalizedString(@"Changelog", @""),
                                                            kSettingsDataSourceValueKey : @"",
                                                            kSettingsDataSourceTypeKey : @(SettingsTypeInfo),
                                                            kSettingsDataSourceExtraKey : NSLocalizedString(@"Changelog text", @"")},
                                                          @{kSettingsDataSourceTitleKey : @"Commit history",
                                                            kSettingsDataSourceValueKey : @"",
                                                            kSettingsDataSourceTypeKey : @(SettingsTypeInfo),
                                                            kSettingsDataSourceExtraKey : commitText},
                                                          @{kSettingsDataSourceTitleKey : NSLocalizedString(@"Logs", @""),
                                                            kSettingsDataSourceValueKey : @"",
                                                            kSettingsDataSourceTypeKey : @(SettingsTypeMore),
                                                            kSettingsDataSourceExtraKey : @[@{kSettingsDataSourceTitleKey : NSLocalizedString(@"Logs", @""),
                                                                                              kSettingsDataSourceItemsKey : logs}]},
                                                          @{kSettingsDataSourceTitleKey : NSLocalizedString(@"Version", @""),
                                                            kSettingsDataSourceValueKey : SPGetApplicationVersion(),
                                                            kSettingsDataSourceTypeKey : @(SettingsTypeTinyInfo)}]}];
    }
    return _dataSource;
}

#pragma mark - Instance Methods

- (void)openLogs:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    LogsViewController *textViewController = [LogsViewController new];
    textViewController.title = self.dataSource[indexPath.section][kSettingsDataSourceItemsKey][indexPath.row][kSettingsDataSourceTitleKey];
    NSString *text = [[NSString alloc] initWithContentsOfFile:[SPLogFilePath() stringByAppendingPathComponent:textViewController.title] encoding:NSUTF8StringEncoding error:nil];
    text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@"\n\n"];
    textViewController.text = text;
    [self.navigationController pushViewController:textViewController animated:YES];
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
    
    switch ((SettingsType)[self.dataSource[indexPath.section][kSettingsDataSourceItemsKey][indexPath.row][kSettingsDataSourceTypeKey] boolValue]) {
        case SettingsTypeMore:
        case SettingsTypeInfo:
        case SettingsTypeAction:
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        default:
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = self.dataSource[section][kSettingsDataSourceTitleKey];
    if ([title isEqualToString:self.title]) {
        return @"";
    } else {
        return title;
    }
}

#pragma mark - UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch ((SettingsType)[self.dataSource[indexPath.section][kSettingsDataSourceItemsKey][indexPath.row][kSettingsDataSourceTypeKey] integerValue]) {
        case SettingsTypeMore: {
            SettingsViewController *settingsViewController = [SettingsViewController new];
            settingsViewController.title = self.dataSource[indexPath.section][kSettingsDataSourceItemsKey][indexPath.row][kSettingsDataSourceTitleKey];
            settingsViewController.dataSource = self.dataSource[indexPath.section][kSettingsDataSourceItemsKey][indexPath.row][kSettingsDataSourceExtraKey];
            [self.navigationController pushViewController:settingsViewController animated:YES];
            break;
        }
        case SettingsTypeInfo: {
            SettingsTextViewController *textViewController = [SettingsTextViewController new];
            textViewController.title = self.dataSource[indexPath.section][kSettingsDataSourceItemsKey][indexPath.row][kSettingsDataSourceTitleKey];
            textViewController.text = self.dataSource[indexPath.section][kSettingsDataSourceItemsKey][indexPath.row][kSettingsDataSourceExtraKey];
            [self.navigationController pushViewController:textViewController animated:YES];
            break;
        }
        case SettingsTypeAction: {
            SettingsViewController *settingsViewController = [SettingsViewController new];
            settingsViewController.title = self.dataSource[indexPath.section][kSettingsDataSourceItemsKey][indexPath.row][kSettingsDataSourceTitleKey];
            SEL selector = NSSelectorFromString(self.dataSource[indexPath.section][kSettingsDataSourceItemsKey][indexPath.row][kSettingsDataSourceExtraKey]);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self performSelector:selector withObject:[tableView cellForRowAtIndexPath:indexPath]];
#pragma clang diagnostic pop
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            break;
        }
        default:
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            break;
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
