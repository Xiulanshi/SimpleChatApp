//
//  ViewController.m
//  MiniChatApp
//
//  Created by Xiulan Shi on 10/30/15.
//  Copyright © 2015 Xiulan Shi. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
<
UITextFieldDelegate,
UITableViewDataSource,
UITableViewDelegate
>
@property (weak, nonatomic) IBOutlet UITableView *messageTableView;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dockViewHeightConstraint;

@property (nonatomic) NSMutableArray *messageArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.messageTextField.delegate = self;
    self.messageTableView.dataSource = self;
    self.messageTableView.delegate = self;
    
    
    
    // Add a tap gesture recognizer to the tableview
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableViewTapped)];
    [self.messageTableView addGestureRecognizer:tapGesture];
    
    // Retrieve messages from Parse
    [self retrieveMessage];
    
    
}

- (void)retrieveMessage {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Message"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        // Clear the messageArray
        self.messageArray = nil;
        // Loop through the objects array
        for (PFObject *object in objects) {
            
            //Retrieve the Text Column value of each PFObject
            NSString *messageText = object[@"Text"];
            
            // Assign it into messageArray
            
            if (messageText != nil) {
                [self.messageArray addObject:messageText];
            }
        }
        
       // reload the tableview
        [self.messageTableView reloadData];
        
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)sendButtonTapped:(UIButton *)sender {
    [self.messageTextField endEditing:YES];
    
    self.messageTextField.enabled = NO;
    self.sendButton.enabled = NO;
    
    //Create a PFObject
    PFObject *newMessageObject = [PFObject objectWithClassName:@"Message"];
    
    //Set the Text key to the text of the messageTextField
    newMessageObject[@"Text"] = self.messageTextField.text;
    
    //Save the PFObject
    [newMessageObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            [self retrieveMessage];
            NSLog(@"Message saved successfully.");
        } else {
            // There was a problem, check error.description
            NSLog(@"error!");
        }
        
        // Enable the textfield and send button
        self.sendButton.enabled = YES;
        self.messageTextField.enabled = YES;
        self.messageTextField.text = @"";
    }];

    
    

    
}

- (void)tableViewTapped {
    [self.messageTextField endEditing:YES];

}


#pragma Mark - Text Field Delegate Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.5 animations:^{
        
        self.dockViewHeightConstraint.constant = 350;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        nil;
    }];
    
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.5 animations:^{
        
        self.dockViewHeightConstraint.constant = 60;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        nil;
    }];
}

#pragma Mark - TableView Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell" forIndexPath:indexPath];
    
    cell.textLabel.text = self.messageArray[indexPath.row];
    
    return cell;
}


@end


