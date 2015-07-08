# Makadu iOS App

<p align="center" >
  <img src="https://cloud.githubusercontent.com/assets/1221152/8562825/7df53c78-250d-11e5-9fb1-f56e1237e48d.png" alt="Screen Shot" title="Makadu">
</p>




Makadu é um aplicativo para eventos que permite aos participantes acessar a programação atualizada, tirar dúvidas a qualquer momento da palestra e ter acesso ao conteúdo do palestrante.

#Setup 

Primeiramente crie uma conta no [Parse](http://parse.com), caso ainda não tenha. Após acessar o [Parse](http://parse.com) crie uma app e importe os arquivos .json que se localizam dentro da pasta data, que se localiza na estrutura do projeto. Crie alguns dados no parse.

A segunda parte que você deve realizar é pegar as chaves Application ID e Client Key de sua conta no [Parse](http://parse.com). Para saber quais são as suas chaves acesse o Parse com a sua conta, selecione a sua app, vá em Settings->Keys.

Para concluir, no Xcode abra o arquivo AppDelegate.m no método didFinishLaunchingWithOptions, cole as chaves em seus respectivos lugares. Deve ficar algo parecido com isso:

```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //Production
    [Parse setApplicationId:@"COLOQUE A APPLICATION ID AQUI"
                  clientKey:@"COLOQUE A CLIENT KEY AQUI"];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:(121.0/255.0) green:(175.0/255.0) blue:(168.0/255.0) alpha:1]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    return YES;
}
```

Pronto agora você já pode utilizar o código da Makadu.

#Observação

Pedimos que se você for utilizar o código para fins comerciais ou para testes, sempre mencione o nosso nome e o link de onde foi retirado o código base.

E se estiver disposto a contribuir para melhorar o app, sempre estamos dispostos receber críticas e opiniões sobre o código e o projeto em si, para podermos melhorar.

Obrigado!




