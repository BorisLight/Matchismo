//
//  CardGameViewController.m
//  Matchismo
//
//  Created by Boris Talesnik on 07/03/2016.
//
//

#import "CardGameViewController.h"
#import "CardMatchingGame.h"
#import "GameHistoryViewController.h"

@interface CardGameViewController ()
@property (strong, nonatomic) CardMatchingGame * game;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *gameState;
@property (weak, nonatomic) IBOutlet UILabel *matchResult;
@property (nonatomic) BOOL needsMatchDisplay;
@end

@implementation CardGameViewController

static const NSString * keyForGameCount = @"game.turnCount";

static const NSInteger kDefaultMatchType = 2;

- (NSUInteger) matchType
{
  return kDefaultMatchType;
}

- (CardMatchingGame *) game
{
  if (!_game){
    _game = [[CardMatchingGame alloc] initWithCardCount:[self.cardButtons count]
                                              usingDeck:[self newDeck]];
    _game.matchType = self.matchType;
    [self addObserver:self forKeyPath:keyForGameCount options:NSKeyValueObservingOptionNew context:NULL];
  }
  
  return _game;
}

-(id<CardContentMaker>)cardContentMaker
{
  if (!_cardContentMaker) _cardContentMaker = [self newCardContentMaker];
  return _cardContentMaker;
}

- (void)viewDidLoad
{
  for (UIButton *cardButton in self.cardButtons) {
    cardButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cardButton.titleLabel.textAlignment = NSTextAlignmentCenter;
  }
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self updateUI];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:sender
{
  
  if ([segue.identifier isEqualToString:@"ShowHistory"]) {
    if ([segue.destinationViewController isKindOfClass:[GameHistoryViewController class]]) {
      GameHistoryViewController * historyController = (GameHistoryViewController *)segue.destinationViewController;
      historyController.cardContentMaker = self.cardContentMaker;
      historyController.gameHistory = self.game.history;
    }
  }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
  if ([keyPath isEqualToString:keyForGameCount]) {
    self.needsMatchDisplay = YES;
  }
}

- (IBAction)touchCardButton:(UIButton *)sender
{
  NSUInteger chosenButtonIndex = [self.cardButtons indexOfObject:sender];
  [self.game chooseCardAtIndex:chosenButtonIndex];
  [self updateUI];
}

- (IBAction)touchResetButton:(UIButton *)sender
{
  [self resetGame];
  [self updateUI];
}

- (void)updateUI
{
  NSMutableAttributedString * gameState = [[NSMutableAttributedString alloc] init];
  for (UIButton *cardButton in self.cardButtons) {
    NSUInteger cardButtonIndex = [self.cardButtons indexOfObject:cardButton];
    Card * card = [self.game cardAtIndex:cardButtonIndex];
    [cardButton setAttributedTitle:[self titleForCard:card] forState:UIControlStateNormal];
    [cardButton setBackgroundImage:[self imageForCard:card] forState:UIControlStateNormal];
    cardButton.enabled = !card.isMatched;
    
    if(card.chosen && !card.isMatched){
      [gameState appendAttributedString:[self.cardContentMaker contentsForCard:card]];
      [gameState appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    }
  }
  
   self.gameState.attributedText = gameState;
  [self updateMatchingResult];
  
  self.scoreLabel.text = [NSString stringWithFormat:@"Score: %ld", self.game.score];
}

- (void)updateMatchingResult
{
  NSAttributedString * result = [[NSAttributedString alloc] init];
  if (self.needsMatchDisplay){
    GameTurn *turn = [self.game.history lastObject];
    result = [self matchResultForTurn:turn];
    self.needsMatchDisplay = NO;
  }
  
  self.matchResult.attributedText = result;
}

- (NSAttributedString *)matchResultForTurn:(GameTurn *)turn
{
  NSMutableAttributedString * result = [[NSMutableAttributedString alloc] init];
    for (Card * card in turn.matchedCards) {
      [result appendAttributedString:[self.cardContentMaker contentsForCard:card]];
      [result appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    }
    [result appendAttributedString:
     [[NSAttributedString alloc] initWithString:turn.score > 0 ? @"Match! " : @"Mismatch! "]];
    [result appendAttributedString:
     [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld Points!", turn.score]]];
  
  return result;
}

- (void)resetGame
{
  [self removeObserver:self forKeyPath:keyForGameCount];
  self.game = nil;
}

//Abstract functions.

- (NSAttributedString *)titleForCard:(Card *)card
{
  return nil;
}



- (UIImage *)imageForCard:(Card *)card
{
  return nil;
}

-(id<CardContentMaker>)newCardContentMaker
{
  return nil;
}

- (Deck *) newDeck
{
  return nil;
}

@end
