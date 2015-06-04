//
//  QuestionViewController.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/29/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import "QuestionViewController.h"
#import "Connection.h"
#import "Analitcs.h"
#import "Messages.h"
#import "TalkDAO.h"

@interface QuestionViewController ()

@property (weak, nonatomic) IBOutlet UITextView *questionTextView;

@end

@implementation QuestionViewController

- (void)viewDidLoad {
    
    
    [super viewDidLoad];
    
    self.questionTextView.delegate = self;
    
    if (self.talkObject != nil) {
        [Analitcs saveDataAnalitcsWithUser:[PFUser currentUser] typeOperation:@"Acessou" screenAccess:@"Tela de Pergunta" description:@"O usuário acessou a tela de perguntas da palestra" event:self.eventObject talk:self.talkObject];
    } else {
        [Analitcs saveDataAnalitcsWithUser:[PFUser currentUser] typeOperation:@"Acessou" screenAccess:@"Tela de Pergunta" description:@"O usuário acessou a tela de perguntas da palestra, mas não foi possível realizar a pergunta, pois ele estava sem acesso a rede de dados."];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    if (![Connection existConnection]) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Delegate Text View

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSRange resultRange = [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet] options:NSBackwardsSearch];
    if ([text length] == 1 && resultRange.location != NSNotFound) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

#pragma mark - Action

- (IBAction)tapSendQuestion:(id)sender {
    
    [MRProgressOverlayView showOverlayAddedTo:self.view title:@"Enviando mensagem." mode:MRProgressOverlayViewModeIndeterminateSmallDefault animated:YES];
    
    PFObject *question = [PFObject objectWithClassName:@"Questions"];
    question[@"question"] = self.questionTextView.text;
    question[@"talk"] = self.talkObject;
    question[@"questioning"] = [PFUser currentUser];
    question[@"active"] = [NSNumber numberWithBool:YES];
    [question saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Pergunta salva com sucesso");
            [Messages successMessageWithTitle:@"Sucesso" andMessage:@"Sua pergunta foi enviada com com sucesso"];
            
            [Analitcs saveDataAnalitcsWithUser:[PFUser currentUser] typeOperation:@"Perguntou" screenAccess:@"Tela de Perguntas" description:@"O usuário realizou uma pergunta na palestra" event:self.eventObject talk:self.talkObject question:question];
            
            [self dismissViewControllerAnimated:NO completion:nil];
        } else {
            NSLog(@"Ocorreu um erro ao salvar a pergunta = %@", error.localizedDescription);
            
            [Analitcs saveDataAnalitcsWithUser:[PFUser currentUser] typeOperation:@"Perguntou" screenAccess:@"Tela de Perguntas" description:[NSString stringWithFormat:@"Ocoreu um erro ao tentar realizar uma pergunta: Erro: %@",error.localizedDescription]  event:self.eventObject talk:self.talkObject question:question];
            
            [Messages failMessageWithTitle:@"Alerta" andMessage:@"Ocorreu um erro no envio de sua menssagem"];
            [self dismissViewControllerAnimated:NO completion:nil];
        }
    }];
    [MRProgressOverlayView dismissOverlayForView:self.view animated:YES];

}

- (IBAction)tapCancelSendQuestion:(id)sender {
    [Analitcs saveDataAnalitcsWithUser:[PFUser currentUser] typeOperation:@"Cancelou" screenAccess:@"Tela de Palestras" description:@"Usuário cancelou a realização de perguntas" event:self.eventObject talk:[TalkDAO fetchTalkByTalkId:self.talk]];
    [self dismissViewControllerAnimated:NO completion:nil];
}


@end
